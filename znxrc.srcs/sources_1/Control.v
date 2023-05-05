`timescale 1ns / 1ps
//`define DBG

module Control(
    input rst,
    input clk,
    output debug1 //,
//    output [15:0] pc_out
    );

localparam ROM_ADDR_WIDTH = 14; // 2**14 instructions
localparam RAM_ADDR_WIDTH = 14; // 2**14 data addresses
localparam REGISTERS_ADDR_WIDTH = 4; // 2**4 registers
localparam LOOP_STACK_ADDR_WIDTH = 4; // 2**4 stack
localparam CALL_STACK_ADDR_WIDTH = 4; // 2**4 stack
localparam REGISTERS_WIDTH = 16; // 16 bit

// c,r != 1,1
localparam OP_XOR = 3'b000;
localparam OP_ADDI = 3'b100;
localparam OP_COPY = 3'b010;
localparam OP_ADD = 3'b101;
localparam OP_SUB = 3'b001;
localparam OP_SHIFT = 3'b110; // also 'not' when 'rega'==0
localparam OP_LOAD = 3'b011;
localparam OP_STORE = 3'b111;

// c,r == 1,1
localparam OP_LOADI = 3'b010;
localparam OP_SKIP = 3'b001;
localparam OP_LOOP = 12'b0000_0001_10;

localparam ALU_ADD = OP_ADD;
localparam ALU_SHIFT = OP_SHIFT;
localparam ALU_NOT = 3'b111;

reg [ROM_ADDR_WIDTH-1:0] pc; // program counter
reg [ROM_ADDR_WIDTH-1:0] pc_nxt; // 'pc' is set to 'pc_nxt' at beginning of a cycle

// LOADI related registers
reg is_loadi; // enabled if instruction data copy to register 'loadi_reg'
reg do_loadi; // enabled if the 'loadi' was a 'is_do_op'
reg [REGISTERS_ADDR_WIDTH-1:0] loadi_reg; // register to write when doing 'loadi'

wire [15:0] instr; // instruction
wire instr_z = instr[0]; // if enabled execute instruction if z-flag is on (also considering instr_n)
wire instr_n = instr[1]; // if enabled execute instruction if n-flag is on (also considering instr_z)
wire instr_x = instr[2]; // if enabled execute instruction and step an iteration in current loop
wire instr_r = instr[3]; // if enabled execute instruction and return from current sub-routine (if instr_x and loop not finished then ignored)
wire instr_c = instr[4]; // if enabled call a sub-routine (instr_r && instr_c is illegal and instead enables more instructions)
wire [3:0] op = instr[7:5];
wire [REGISTERS_ADDR_WIDTH-1:0] rega = instr[11:8];
wire [REGISTERS_ADDR_WIDTH-1:0] regb = is_loadi ? loadi_reg : instr[15:12];
wire [7:0] imm8 = instr[15:8];
wire [10:0] imm11 = instr[15:5];

wire zn_zf, zn_nf; // zero- and negative flags wired to Zn
wire is_do_op = !is_loadi && ((instr_z && instr_n) || (zn_zf==instr_z && zn_nf==instr_n)); // enabled if instruction will execute

// LoopStack related wiring
wire ls_new_loop = is_do_op && instr[11:2] == OP_LOOP; // creates new loop with counter set from regs[regb]
wire ls_done; // LoopStack enables this if it is the last iteration in current loop, stable during negative edge
wire ls_done_ack = is_do_op && instr_x && ls_done; // if current loop is in final iteration and 'next' instruction then acknowledge to LoopStack that loop has been exited
wire is_ls_nxt = is_do_op && instr_x && !ls_done; // enabled if instruction has 'next' and loop is not finished
wire [ROM_ADDR_WIDTH-1:0] ls_pc_out; // wired to LoopStack: address to set 'pc' to if loop is not done

// CallStack related wiring
wire is_cr = instr_c && instr_r; // enabled if illegal c && r op => enables 8 other instructions that can't piggy back 'return'
wire is_cs_op = is_do_op && !is_cr && (instr_c ^ instr_r); // enabled if instruction operates on CallStack
wire cs_push = is_cs_op && instr_c; // enabled if instruction is 'call'
wire cs_pop = is_cs_op && instr_r && !(is_ls_nxt && !ls_done); // enabled if 'return', disabled if also 'next' and loop not finished
wire [ROM_ADDR_WIDTH-1:0] cs_pc_out; // wired to program counter at top of the CallStack

// Register related wiring (part 1)
wire [REGISTERS_WIDTH-1:0] rega_dat; // operand a data
wire [REGISTERS_WIDTH-1:0] regb_dat; // operand b dat

// ALU related wiring
wire is_alu_op = !is_loadi && !is_cr && !cs_push && (op == OP_ADD || op == OP_SUB || op == OP_ADDI || op == OP_COPY || op == OP_SHIFT || op == OP_XOR);
wire [2:0] alu_op = op == OP_SHIFT && rega == 0 ? ALU_NOT : // 'shift' 0 interpreted as 'not'
                    op == OP_ADDI ? ALU_ADD : // 'addi' is add with signed immediate value 'rega'
                    op; // same as op
wire [REGISTERS_WIDTH-1:0] alu_operand_a = 
    op == OP_SHIFT && rega != 0 ? {{12{rega[3]}}, rega} : // 'shift' with signed immediate value 'rega'
    op == OP_ADDI ? {{12{rega[3]}}, rega} : // 'addi' is add with signed immediate value 'rega'
    rega_dat; // otherwise regs[rega]
wire [REGISTERS_WIDTH-1:0] alu_res; // result from alu

// Zn related wiring
wire zn_we = is_do_op && (is_alu_op || cs_pop || cs_push); // update flags if alu op, 'call' or 'return'
wire zn_sel = !cs_pop; // if 'zn_we': if not 'return' then select flags from alu otherwise from CallStack
wire zn_clr = cs_push; // if 'zn_we': clears the flags if it is a 'call'. has precedence over 'zn_sel' when 'zn_we'
wire cs_zf, cs_nf, alu_zf, alu_nf; // z- and n-flag wires between Zn, ALU and CallStack

// RAM related wiring
wire ram_we = op == OP_STORE; // wired to ram write enable input, enabled if 'store' instruction
wire [REGISTERS_WIDTH-1:0] ram_dat_out; // wired to ram data output, data to be read from ram

// Registers related wiring (part 2)
// enables write to registers if 'loadi' or 'load' or alu op
wire regs_we = (is_loadi && do_loadi) || (is_do_op && (is_alu_op || op == OP_LOAD));
// data written to 'regb' when 'regs_we' is enabled
wire [REGISTERS_WIDTH-1:0] regs_wd =
    is_loadi ? instr : // select instruction data
    op == OP_LOAD ? ram_dat_out : // select ram output
    alu_res; // otherwise select alu result

assign debug1 = alu_zf;

always @(negedge clk) begin
    pc <= pc_nxt; // this setup holds 'pc' stable during positive edge of clock
end

always @(posedge clk) begin
    `ifdef DBG
        $display("  clk: Control: %d:%h (op,zf,nf,z,n)=(%d,%d,%d,%d,%d)", pc, instr, is_do_op, zn_zf, zn_nf, instr_z, instr_n);
    `endif
    
    if (rst) begin
        is_loadi <= 0;
        pc_nxt <= 0;
    end else begin
        case(is_loadi)
        //---------------------------------------------------------------------
        0: // instruction
        //---------------------------------------------------------------------
        begin
            if (cs_push) begin // 'call': calls imm11<<3
                if (ROM_ADDR_WIDTH-11-3 == 0) begin
                    pc_nxt = {(imm11<<3) - 11'd1}; // -1 because pc will be incremented by 1
                end else begin
                    pc_nxt = {{(ROM_ADDR_WIDTH-11-3){1'b0}}, (imm11<<3) - 11'd1}; // -1 because pc will be incremented by 1
                end
            end else if (cs_pop) begin // 'ret' flag
                pc_nxt = cs_pc_out; // set pc to top of call stack, will be incremented by 1
            end else begin // operation
                if (is_cr) begin // if instruction bits c and r are 11 then select the second page of operations
                    case(op)
                    //-------------------------------------------------------------
                    OP_LOADI: begin // load register with data from the next instruction 
                        loadi_reg <= regb; // save the target register for next cycle
                        do_loadi = is_do_op; // save this for next cycle to determine whether data will be written to register
                        // save state for next cycle to indicate that next instruction is data
                        is_loadi <= 1; // 'is_loadi' must be set after 'do_loadi' because 'is_do_op' uses 'is_loadi' in condition
                    end
                    //-------------------------------------------------------------
                    OP_SKIP: begin
                        is_loadi <= 0; // reset flag that triggers write instruction to register
                        if (is_do_op) begin
                            pc_nxt = pc + {{(ROM_ADDR_WIDTH-8){imm8[7]}}, imm8}; // skip instructions, 'pc_nxt' will be incremented by 1
                        end
                    end
                    //-------------------------------------------------------------
                    default: begin
                        is_loadi <= 0;
                    end
                    endcase
                end else begin // instruction bits c and r are not 11
                    is_loadi <= 0;
                end
                // if 'next' and loop not done 
                if (is_ls_nxt) begin
                    pc_nxt = ls_pc_out; // get the address to jump to from LoopStack (will be incremented by 1)
                end  
            end
        end
        //---------------------------------------------------------------------
        1: // writes instruction data to 'loadi_reg'
        //---------------------------------------------------------------------
        begin
            is_loadi <= 0; // reset to regular instruction
        end
        endcase
        // next instruction
        pc_nxt = pc_nxt + 1;
    end
end

ROM #(ROM_ADDR_WIDTH) rom (
    .addr(pc),
    .data(instr)
    );

LoopStack #(LOOP_STACK_ADDR_WIDTH, ROM_ADDR_WIDTH, REGISTERS_WIDTH) ls(
    .rst(rst),
    .clk(clk),
    .new(ls_new_loop),
    .cnt_in(regb_dat),
    .pc_in(pc),
    .nxt(is_ls_nxt),
    .done_ack(ls_done_ack),
    .pc_out(ls_pc_out),
    .done(ls_done)
    );

CallStack #(CALL_STACK_ADDR_WIDTH, ROM_ADDR_WIDTH) cs(
    .rst(rst),
    .clk(clk),
    .pc_in(pc),
    .zf_in(zn_zf),
    .nf_in(zn_nf),
    .push(cs_push),
    .pop(cs_pop),
    .pc_out(cs_pc_out),
    .zf_out(cs_zf),
    .nf_out(cs_nf)
    );

Registers #(REGISTERS_ADDR_WIDTH, REGISTERS_WIDTH) regs(
    .clk(clk),
    .ra1(rega),
    .ra2(regb),
    .we(regs_we),
    .wd(regs_wd),
    .rd1(rega_dat),
    .rd2(regb_dat)
    );

ALU #(REGISTERS_WIDTH) alu(
    .op(alu_op),
    .a(alu_operand_a),
    .b(regb_dat),
    .result(alu_res),
    .zf(alu_zf),
    .nf(alu_nf)
    );

RAM #(RAM_ADDR_WIDTH, REGISTERS_WIDTH) ram(
    .clk(clk),
    .addr(rega_dat[ROM_ADDR_WIDTH-1:0]),
    .we(ram_we),
    .dat_in(regb_dat),
    .dat_out(ram_dat_out)
    );

Zn zn(
    .rst(rst),
    .clk(clk),
    .cs_zf(cs_zf),
    .cs_nf(cs_nf),
    .alu_zf(alu_zf),
    .alu_nf(alu_nf),
    .zf(zn_zf),
    .nf(zn_nf),
    .we(zn_we),
    .sel(zn_sel),
    .clr(zn_clr)
    );

endmodule
