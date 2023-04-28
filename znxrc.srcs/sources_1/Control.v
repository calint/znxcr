`timescale 1ns / 1ps
`default_nettype none

module Control(
    input wire rst,
    input wire clk,
    output wire debug1
    );

reg state = 0;
reg [15:0] pc = 0; // program counter
reg [15:0] cs_pc_in; // program counter to call stack
wire [15:0] cs_pc_out; // program counter at top of the call stack
reg [3:0] reg_to_write = 0;

wire cs_zf,cs_nf,alu_zf,alu_nf;
wire [15:0] alu_res;
wire [15:0] reg1_dat;
wire [15:0] reg2_dat;

wire [15:0] instr; // instruction
wire instr_z = instr[0];
wire instr_n = instr[1];
wire instr_x = instr[2];
wire instr_r = instr[3];
wire instr_c = instr[4];
wire [3:0] op = instr[7:5];
wire [3:0] reg1 = instr[11:8];
wire [3:0] reg2 = state == 1 ? reg_to_write : instr[15:12];
wire [9:0] imm8 = instr[15:8];
wire [9:0] imm11 = instr[15:5];

wire ls_done;
wire ls_new_loop = state == 0 ? instr[11:0] == 11'b0000_0100_0000 : 0;
wire [15:0] ls_pc_out;

wire is_cr = instr_c && instr_r;
wire is_cs_op = state == 0 && !is_cr && (instr_c ^ instr_r) ? 1 : 0;
wire cs_push = is_cs_op ? instr_c : 0;
wire cs_pop = is_cs_op ? instr_r : 0;

wire is_alu_op = op == 3'b101 || op == 3'b100 || op == 3'b110; // 'add','inc','shf' or 'not':
wire [2:0] alu_op = op == 3'b110 && reg1 == 0 ? 3'b111 :
                    op == 3'b100 ? 3'b101 : // 'inc' is add 
                    op;
wire [15:0] alu_operand_1 = op == 3'b110 && reg1 != 0 ? {{12{reg1[3]}}, reg1} : // shift imm4
                            op == 3'b100 ? {{12{reg1[3]}}, reg1} : // increment imm4
                            reg1_dat;

wire is_ram_read = op == 3'b011;
wire is_ram_write = op == 3'b111;
wire [15:0] ram_addr = reg1_dat;
wire ram_we = is_ram_write;
wire [15:0] ram_dat_out;

// enables write to registers if is 'loadi' alu op or 'load'
wire regs_we = state == 1 || is_alu_op || is_ram_read ? 1 : 0;
// data written to 'reg2' if 'regs_we' is enabled
wire [15:0] regs_wd = state == 1 ? instr : 
                      is_alu_op ? alu_res :
                      is_ram_read ? ram_dat_out :
                      0;

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
                3'b000: begin // 'load': load register with data from the next instruction 
                    state = 1;
                    reg_to_write = reg2;
                end
                //-------------------------------------------------------------
                3'b001: begin // 'skip': jump forward 
                    pc = pc + {8'd0, imm8};
                end
                //-------------------------------------------------------------
//                3'b010: begin // 'loop': new loop with counter value from reg2
//                    ls_new_loop = 1;     
//                end
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
