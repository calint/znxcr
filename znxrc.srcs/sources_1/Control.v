`timescale 1ns / 1ps
`default_nettype none

module Control(
    input wire rst,
    input wire clk,
    output wire debug1
    );

localparam OP_LOADI = 3'b000;
localparam OP_ADDI = 3'b100;
localparam OP_ADD = 3'b101;
localparam OP_SHIFT = 3'b110;
localparam OP_LOAD = 3'b011;
localparam OP_STORE = 3'b111;
localparam OP_SKIP = 3'b001;

localparam ALU_ADD = OP_ADD;
localparam ALU_SHIFT = OP_SHIFT;
localparam ALU_NOT = 3'b111;

reg state = 0; // state == 1 => write the instruction to register 'reg_to_write'
reg [15:0] pc = 0; // program counter
reg [15:0] cs_pc_in; // program counter to call stack
wire [15:0] cs_pc_out; // program counter at top of the call stack
reg [3:0] reg_to_write = 0; // register to write when doing 'loadi'

wire cs_zf,cs_nf,alu_zf,alu_nf;
wire [15:0] alu_res; // result from alu
wire [15:0] reg1_dat; // regs[reg1]
wire [15:0] reg2_dat; // regs[reg2]

wire [15:0] instr; // instruction
wire instr_z = instr[0]; // if enabled execute command if z-flag is on
wire instr_n = instr[1]; // if enabled execute command if n-flag is on
wire instr_x = instr[2]; // if enabled execute command and step an iteration in current loop
wire instr_r = instr[3]; // if enabled execute command and return from current sub-routine
wire instr_c = instr[4]; // if enabled call a sub-routine (instr_r && instr_c is illegal and instead enables more commands)
wire [3:0] op = instr[7:5];
wire [3:0] reg1 = instr[11:8];
wire [3:0] reg2 = state == 1 ? reg_to_write : instr[15:12];
wire [9:0] imm8 = instr[15:8];
wire [9:0] imm11 = instr[15:5];

wire ls_done; // loop stack enables this if it is the last iteration in current loop
wire ls_new_loop = state == 0 ? instr[11:0] == 11'b0000_0100_0000 : 0; // creates new loop with counter set from regs[reg2]
wire [15:0] ls_pc_out; // loop stack jump to if loop is not done

wire is_cr = instr_c && instr_r; // enabled if illegal c && r op => enables 8 other commands
wire is_cs_op = state == 0 && !is_cr && (instr_c ^ instr_r) ? 1 : 0; // enabled if command operates on call stack
wire cs_push = is_cs_op ? instr_c : 0; // enabled if command is 'call'
wire cs_pop = is_cs_op ? instr_r : 0; // enabled if command also does 'return'

wire is_alu_op = op == OP_ADD || op == OP_ADDI || op == OP_SHIFT;
wire [2:0] alu_op = op == OP_SHIFT && reg1 == 0 ? ALU_NOT : // 'shift' with argument 0 is interpreted as a 'not'
                    op == OP_ADDI ? ALU_ADD : // 'addi' is add with 'reg1' as a signed value instead of regs[reg1]
                    op; // same as op
wire [15:0] alu_operand_1 = op == OP_SHIFT && reg1 != 0 ? {{12{reg1[3]}}, reg1} : // 'shift' with argument signed value of 'reg1' argument
                            op == OP_ADDI ? {{12{reg1[3]}}, reg1} : // 'addi' is add with 'reg1' argument as signed value instead of regs[reg1]
                            reg1_dat; // otherwise regs[reg1]

wire ram_we = op == OP_STORE; // connected to ram write enable input
wire [15:0] ram_dat_out; // connected to ram data output

// enables write to registers if 'loadi' or alu op or 'load'
wire regs_we = state == 1 || is_alu_op || op == OP_LOAD ? 1 : 0;
// data written to 'reg2' if 'regs_we' is enabled
wire [15:0] regs_wd = state == 1 ? instr : // write instruction into registers
                      is_alu_op ? alu_res : // write alu result to registers
                      op == OP_LOAD ? ram_dat_out : // write ram data output to registers
                      0; // otherwise don't write to registers

assign debug1 = alu_zf;

always @(posedge clk) begin
    if (rst) begin
        state <= 0;
        pc <= 0;
    end else begin
        case(state)
        //---------------------------------------------------------------------
        0: // state 0: decode instruction
        //---------------------------------------------------------------------
        begin
            if (cs_push) begin // 'call': calls imm11<<3
                cs_pc_in = pc;
                pc = {2'b00, imm11<<3};
            end else if (cs_pop) begin // 'ret' flag
                pc = cs_pc_out + 1;
            end else begin // operation
                case(op)
                //-------------------------------------------------------------
                OP_LOADI: begin // load register with data from the next instruction 
                    state = 1;
                    reg_to_write = reg2;
                end
                //-------------------------------------------------------------
                OP_SKIP: begin 
                    pc = pc + {8'd0, imm8};
                end
                //-------------------------------------------------------------
                default: state=0;
                endcase
                // if loop 'next' 
                if (instr_x) begin
                    // check if this was last iteration
                    if (ls_done) begin
                        // loop done
                        pc = pc + 1;
                    end else begin
                        // jump to start of loop
                        pc = ls_pc_out;        
                    end
                end else begin
                    // next 
                    pc = pc + 1;
                end        
            end
        end
        //---------------------------------------------------------------------
        1: // state 1: write 'reg_to_write' data of current 'instruction'
        //---------------------------------------------------------------------
        begin
            state = 0;
            pc = pc + 1;
        end
//        default: state = 0;
        endcase
    end
end

ROM rom(
    .addr(pc),
    .data(instr)
    );

CallStack cs(
    .rst(rst),
    .clk(clk),
    .pc_in(cs_pc_in),
    .zf_in(alu_zf),
    .nf_in(alu_nf),
    .push(cs_push),
    .pop(cs_pop),
    .pc_out(cs_pc_out),
    .zf_out(cs_zf),
    .nf_out(cs_zf)
    );

LoopStack ls(
    .rst(rst),
    .clk(clk),
    .new(ls_new_loop), // true to create a new loop using 'loop_address' for the jump and 'count' for the number of iterations
    .cnt_in(reg2_dat), // number of iterations in loop when creating new loop with 'new_loop'
    .pc_in(pc), // the address to which to jump at next
    .nxt(instr_x), // true if current loop is at instruction that is 'next'
    .pc_out(ls_pc_out), // the address to jump to if loop is not finished
    .done(ls_done) // true if current loop at last iteration
    );

Registers regs(
    .clk(clk),
    .ra1(reg1),
    .ra2(reg2),
    .we(regs_we), // write 'wd' to address 'ra2'
    .wd(regs_wd), // data to write when 'we' is enabled
    .rd1(reg1_dat), // data of register 'reg1'
    .rd2(reg2_dat) // data of register 'reg2'
    );

ALU alu(
    .op(alu_op),
    .a(alu_operand_1),
    .b(reg2_dat),
    .result(alu_res),
    .zf(alu_zf),
    .nf(alu_nf)
);

RAM ram(
  .clk(clk),
  .addr(reg1_dat),
  .we(ram_we),
  .dat_in(reg2_dat),
  .dat_out(ram_dat_out)
);

endmodule
