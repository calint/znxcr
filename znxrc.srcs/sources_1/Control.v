`timescale 1ns / 1ps

module Control(
    input rst,
    input clk,
    output debug1
    );

localparam OP_LOADI = 3'b010;
localparam OP_ADDI = 3'b100;
localparam OP_COPY = 3'b010;
localparam OP_ADD = 3'b101;
localparam OP_SHIFT = 3'b110;
localparam OP_LOAD = 3'b011;
localparam OP_STORE = 3'b111;
localparam OP_SKIP = 3'b001;
localparam OP_LOOP = 12'b0000_0001_1000;

localparam ALU_ADD = OP_ADD;
localparam ALU_SHIFT = OP_SHIFT;
localparam ALU_NOT = 3'b111;

wire [3:0] step;
reg is_loadi; // enabled if instruction data copy to register 'reg_to_write'
reg [15:0] pc; // program counter
reg [15:0] cs_pc_in; // program counter as input to call stack
wire [15:0] cs_pc_out; // program counter at top of the call stack
reg [3:0] reg_to_write; // register to write when doing 'loadi'

wire [15:0] alu_res; // result from alu
wire [15:0] rega_dat; // regs[rega]
wire [15:0] regb_dat; // regs[regb]

wire [15:0] instr; // instruction
wire instr_z = instr[0]; // if enabled execute command if z-flag is on
wire instr_n = instr[1]; // if enabled execute command if n-flag is on
wire instr_x = instr[2]; // if enabled execute command and step an iteration in current loop
wire instr_r = instr[3]; // if enabled execute command and return from current sub-routine
wire instr_c = instr[4]; // if enabled call a sub-routine (instr_r && instr_c is illegal and instead enables more commands)
wire [3:0] op = instr[7:5];
wire [3:0] rega = instr[11:8];
wire [3:0] regb = is_loadi ? reg_to_write : instr[15:12];
wire [7:0] imm8 = instr[15:8];
wire [10:0] imm11 = instr[15:5];

wire cs_zf,cs_nf,alu_zf,alu_nf,zf,nf; // z- and n-flag connections between Zn, ALU and CallStack
wire ls_done; // loop stack enables this if it is the last iteration in current loop
wire ls_new_loop = !is_loadi && instr[11:0] == OP_LOOP; // creates new loop with counter set from regs[regb]
wire [15:0] ls_pc_out; // loop stack: address to set 'pc' to if loop is not done
reg [15:0] ls_pc_in;

wire is_cr = instr_c && instr_r; // enabled if illegal c && r op => enables 8 other commands that can't piggy back 'return'
wire is_do_op = !is_loadi && ((instr_z && instr_n) || (zf==instr_z && nf==instr_n));
wire is_cs_op = is_do_op && !is_cr && (instr_c ^ instr_r); // enabled if command operates on call stack
wire cs_push = is_cs_op ? instr_c : 0; // enabled if command is 'call'
wire cs_pop = is_cs_op ? instr_r : 0; // enabled if command also does 'return'

wire is_alu_op = !is_loadi && !is_cr && !cs_push && (op == OP_ADD || op == OP_ADDI || op == OP_COPY || op == OP_SHIFT);
wire [2:0] alu_op = op == OP_SHIFT && rega == 0 ? ALU_NOT : // 'shift' 0 interpreted as 'not'
                    op == OP_ADDI ? ALU_ADD : // 'addi' is add with signed immediate value 'rega'
                    op; // same as op
wire [15:0] alu_operand_a = op == OP_SHIFT && rega != 0 ? {{12{rega[3]}}, rega} : // 'shift' with signed immediate value 'rega'
                            op == OP_ADDI ? {{12{rega[3]}}, rega} : // 'addi' is add with signed immediate value 'rega'
                            rega_dat; // otherwise regs[rega]

wire zn_we = is_alu_op || cs_pop; // update flags if alu op or return
wire zn_sel = is_alu_op; // if alu op then enabled otherwise it is 'cs_pop'

wire ram_we = op == OP_STORE; // connected to ram write enable input
wire [15:0] ram_dat_out; // connected to ram data output

// enables write to registers
wire regs_we = is_loadi || (is_do_op && (is_alu_op || op == OP_LOAD));
// data written to 'regb' if 'regs_we' is enabled
wire [15:0] regs_wd = is_loadi ? instr : // write instruction into registers
                      is_alu_op ? alu_res : // write alu result to registers
                      op == OP_LOAD ? ram_dat_out : // write ram data output to registers
                      0; // otherwise don't write to registers

assign debug1 = alu_zf;

always @(posedge clk) begin
    $display("  clk: Control");
    if (rst) begin
        is_loadi <= 0;
        pc <= 0;
    end else begin
        case(is_loadi)
        //---------------------------------------------------------------------
        0: // instruction
        //---------------------------------------------------------------------
        begin
            if (cs_push) begin // 'call': calls imm11<<3
                cs_pc_in = pc;
                pc = {2'b00, (imm11<<3) - 14'd1}; // -1 because pc will be incremented by 1 in 'negedge clk'
            end else if (cs_pop) begin // 'ret' flag
                pc = cs_pc_out; // set pc to top of stack, will be incremented by 1 in 'negedge clk'
            end else begin // operation
                if (is_cr) begin // if instruction bits c and r are 11 then select the second page of operations
                    case(op)
                    //-------------------------------------------------------------
                    OP_LOADI: begin // load register with data from the next instruction 
                        is_loadi <= 1;
                        reg_to_write <= regb;
                    end
                    //-------------------------------------------------------------
                    OP_SKIP: begin
                        is_loadi <= 0;
                        if (is_do_op) begin
                            pc = pc + {8'd0, imm8};
                        end
                    end
                    //-------------------------------------------------------------
                    default: is_loadi <= 0;
                    endcase
                end else begin // instruction bits c and r are not 11
                    is_loadi <= 0;
                end
                // if loop 'next' 
                if (is_do_op && instr_x && !ls_done) begin
                    pc = ls_pc_out;        
                end        
            end
        end
        //---------------------------------------------------------------------
        1: // write instruction data to 'reg_to_write'
        //---------------------------------------------------------------------
        begin
            is_loadi <= 0;
        end
        endcase
        ls_pc_in = pc;
        pc = pc + 1;
    end
end

Stepper stepper(
    .rst(rst),
    .clk(clk),
    .step(step)
    );

ROM rom(
    .addr(pc),
    .data(instr)
    );

LoopStack ls(
    .rst(rst),
    .clk(clk),
    .new(ls_new_loop),
    .cnt_in(regb_dat),
    .pc_in(ls_pc_in),
    .nxt(instr_x),
    .pc_out(ls_pc_out),
    .done(ls_done)
    );

CallStack cs(
    .rst(rst),
    .clk(clk),
    .pc_in(cs_pc_in),
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
    .sel(zn_sel)
);

RAM ram(
  .clk(clk),
  .addr(rega_dat),
  .we(ram_we),
  .dat_in(regb_dat),
  .dat_out(ram_dat_out)
);

endmodule
