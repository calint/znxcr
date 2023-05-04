`timescale 1ns / 1ps

module Control(
    input rst,
    input clk,
    output debug1 //,
//    output [15:0] pc_out
    );

// c,r != 1,1
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

reg [15:0] pc; // program counter
reg [15:0] pc_nxt; // 'pc' is set to 'pc_nxt' at beginning of a cycle

reg is_loadi; // enabled if instruction data copy to register 'loadi_reg'
reg do_loadi; // enabled if the 'loadi' was a 'is_do_op'
reg [3:0] loadi_reg; // register to write when doing 'loadi'

wire [15:0] cs_pc_out; // connected to program counter at top of the CallStack

wire [15:0] alu_res; // result from alu
wire [15:0] rega_dat; // regs[rega]
wire [15:0] regb_dat; // regs[regb]

wire [15:0] instr; // instruction
wire instr_z = instr[0]; // if enabled execute instruction if z-flag is on (also considering instr_n)
wire instr_n = instr[1]; // if enabled execute instruction if n-flag is on (also considering instr_z)
wire instr_x = instr[2]; // if enabled execute instruction and step an iteration in current loop
wire instr_r = instr[3]; // if enabled execute instruction and return from current sub-routine (if instr_x and loop not finished then ignored)
wire instr_c = instr[4]; // if enabled call a sub-routine (instr_r && instr_c is illegal and instead enables more instructions)
wire [3:0] op = instr[7:5];
wire [3:0] rega = instr[11:8];
wire [3:0] regb = is_loadi ? loadi_reg : instr[15:12];
wire [7:0] imm8 = instr[15:8];
wire [10:0] imm11 = instr[15:5];

wire cs_zf, cs_nf, alu_zf, alu_nf, zf, nf; // z- and n-flag connections between Zn, ALU and CallStack

wire is_do_op = !is_loadi && ((instr_z && instr_n) || (zf==instr_z && nf==instr_n)); // enabled if instruction will execute

wire ls_new_loop = is_do_op && instr[11:2] == OP_LOOP; // creates new loop with counter set from regs[regb]
wire ls_done; // LoopStack enables this if it is the last iteration in current loop, stable during negative edge
wire is_ls_nxt = is_do_op && instr_x && !ls_done; // enabled if instruction has 'next' and loop is not finished
wire [15:0] ls_pc_out; // connected to LoopStack: address to set 'pc' to if loop is not done

wire is_cr = instr_c && instr_r; // enabled if illegal c && r op => enables 8 other instructions that can't piggy back 'return'
wire is_cs_op = is_do_op && !is_cr && (instr_c ^ instr_r); // enabled if instruction operates on CallStack
wire cs_push = is_cs_op && instr_c; // enabled if instruction is 'call'
wire cs_pop = is_cs_op && instr_r && !(is_ls_nxt && !ls_done); // enabled if 'return', disabled if also 'next' and loop not finished

wire is_alu_op = !is_loadi && !is_cr && !cs_push && (op == OP_ADD || op == OP_SUB || op == OP_ADDI || op == OP_COPY || op == OP_SHIFT);
wire [2:0] alu_op = op == OP_SHIFT && rega == 0 ? ALU_NOT : // 'shift' 0 interpreted as 'not'
                    op == OP_ADDI ? ALU_ADD : // 'addi' is add with signed immediate value 'rega'
                    op; // same as op
wire [15:0] alu_operand_a = op == OP_SHIFT && rega != 0 ? {{12{rega[3]}}, rega} : // 'shift' with signed immediate value 'rega'
                            op == OP_ADDI ? {{12{rega[3]}}, rega} : // 'addi' is add with signed immediate value 'rega'
                            rega_dat; // otherwise regs[rega]

wire zn_we = is_do_op && (is_alu_op || cs_pop || cs_push); // update flags if alu op, 'call' or 'return'
wire zn_sel = !cs_pop; // if 'zn_we': if not 'return' then select flags from alu otherwise from CallStack
wire zn_clr = cs_push; // if 'zn_we': clears the flags if it is a 'call'. has precedence over 'zn_sel' when 'zn_we'

wire ram_we = op == OP_STORE; // connected to ram write enable input, enabled if 'store' instruction
wire [15:0] ram_dat_out; // connected to ram data output, data to be read from ram

// enables write to registers if 'loadi' or 'load' or alu op
wire regs_we = (is_loadi && do_loadi) || (is_do_op && (is_alu_op || op == OP_LOAD));
// data written to 'regb' when 'regs_we' is enabled
wire [15:0] regs_wd = is_loadi ? instr : // select instruction data
                      op == OP_LOAD ? ram_dat_out : // select ram output
                      alu_res; // otherwise select alu result

assign debug1 = alu_zf;

always @(negedge clk) begin
    pc <= pc_nxt; // this setup holds 'pc' stable during positive edge of clock
end

always @(posedge clk) begin
    `ifdef DBG
        $display("  clk: Control: %d:%h (op,zf,nf,z,n)=(%d,%d,%d,%d,%d)", pc, instr, is_do_op, zf, nf, instr_z, instr_n);
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
                pc_nxt = {2'b00, (imm11<<3) - 11'd1}; // -1 because pc will be incremented by 1
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
                        if (is_do_op) begin // only do if zn-flags match instruction zn-flags or always if (z,n)=(1,1)
                            pc_nxt = pc + {8'd0, imm8}; // skip instructions, 'pc_nxt' will be incremented by 1
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

ROM rom(
    .addr(pc),
    .data(instr)
    );

LoopStack ls(
    .rst(rst),
    .clk(clk),
    .new(ls_new_loop),
    .cnt_in(regb_dat),
    .pc_in(pc),
    .nxt(is_ls_nxt),
    .pc_out(ls_pc_out),
    .done(ls_done)
    );

CallStack cs(
    .rst(rst),
    .clk(clk),
    .pc_in(pc),
    .zf_in(zf),
    .nf_in(nf),
    .push(cs_push),
    .pop(cs_pop),
    .pc_out(cs_pc_out),
    .zf_out(cs_zf),
    .nf_out(cs_nf)
    );

Registers regs(
    .clk(clk),
    .ra1(rega),
    .ra2(regb),
    .we(regs_we),
    .wd(regs_wd),
    .rd1(rega_dat),
    .rd2(regb_dat)
    );

ALU alu(
    .op(alu_op),
    .a(alu_operand_a),
    .b(regb_dat),
    .result(alu_res),
    .zf(alu_zf),
    .nf(alu_nf)
    );

RAM ram(
    .clk(clk),
    .addr(rega_dat),
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
    .zf(zf),
    .nf(nf),
    .we(zn_we),
    .sel(zn_sel),
    .clr(zn_clr)
    );

endmodule
