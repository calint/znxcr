`timescale 1ns / 1ps
`default_nettype none

module Control(
    input wire rst,
    input wire clk,
    output wire [15:0] debug1,
    output wire [15:0] debug2
    );

assign debug1 = regs.mem[1];
assign debug2 = regs.mem[2];

reg state = 0;
reg [15:0] program_counter = 0;
reg [3:0] reg_to_write = 0;

wire cs_zf,cs_nf,alu_zf,alu_nf;
wire [15:0] alu_res;
wire [15:0] reg1_dat;
wire [15:0] reg2_dat;
wire ls_loop_finished;
wire ls_new_loop = 0;
wire [15:0] ls_jmp_address;
wire [15:0] cs_program_counter_nxt;

wire [15:0] instruction;
wire instr_z = state == 0 ? instruction[0] : 0;
wire instr_n = state == 0 ? instruction[1] : 0;
wire instr_x = state == 0 ? instruction[2] : 0;
wire instr_r = state == 0 ? instruction[3] : 0;
wire instr_c = state == 0 ? instruction[4] : 0;

wire cs_pop = state == 0 ? instruction[3] : 0;
wire cs_push = state == 0 ? instruction[4] : 0;
wire [3:0] op = state == 0 ? instruction[7:4] : 0;
wire [3:0] reg1 = instruction[11:8];
wire [3:0] reg2 = state == 1 ? reg_to_write : instruction[15:12];
wire [2:0] alu_op = instruction[7:5] == 3'b011 && reg1 == 0 ? 3'b111 : instruction[7:5];
wire [15:0] alu_operand_1 = alu_op == 3'b011 && reg1 != 0 ? {{12{reg1[3]}}, reg1} : reg1_dat;
wire [9:0] imm10 = state == 0 ? instruction[15:6] : 0;
wire is_alu_op = op == 4'b1010 || op == 4'b0010 || op == 4'b0110; // 'add','inc','shf' or 'not':
wire regs_we = state == 1 || is_alu_op ? 1 : 0;
wire [15:0] regs_wd = state == 1 ? instruction : 
                      is_alu_op ? alu_res :
                      0;

always @(posedge clk) begin
    if (rst) begin
        state <= 0;
        program_counter <= 0;
    end else begin
        case(state)
        0: // state 0: decode instruction
        begin
            if (cs_push) begin // 'call': calls immediate imm10
                program_counter = {2'b00, imm10<<4};            
            end else begin // operation
                case(op)
                4'b0000: begin // 'ld': load register with data from the next instruction 
                    state = 1;
                    reg_to_write = reg2;
                end
                default: state=0;
                endcase
            end
        end
        1: // state 1: write 'reg_to_write' with current 'instruction'
        begin
            state = 0;            
        end
//        default: state = 0;
        endcase
        program_counter = program_counter + 1;
    end
end

ROM rom(
    .addr(program_counter),
    .data(instruction)
    );

CallStack cs(
    .rst(rst),
    .clk(clk),
    .program_counter_in(program_counter),
    .zero_flag_in(alu_zf),
    .negative_flag_in(alu_nf),
    .push(cs_push),
    .pop(cs_pop),
    .program_counter_out(cs_program_counter_nxt),
    .zero_flag_out(cs_zf),
    .negative_flag_out(cs_zf)
    );

LoopStack ls(
    .rst(rst),
    .clk(clk),
    .new_loop(ls_new_loop), // true to create a new loop using 'loop_address' for the jump and 'count' for the number of iterations
    .count(reg1_dat), // number of iterations in loop when creating new loop with 'new_loop'
    .loop_address(program_counter), // the address to which to jump at next
    .next(instr_x), // true if current loop is at instruction that is 'next'
    .loop_finished(ls_loop_finished), // true if current loop is finished
    .jmp_address(ls_jmp_address) // the address to jump to if loop is not finished
    );

Registers regs(
    .clk(clk),
    .ra1(reg1),
    .ra2(reg2),
    .we(regs_we), // write 'wd' to address 'ra1'
    .wd(regs_wd), // data to write when 'we' is true
    .rd1(reg1_dat),
    .rd2(reg2_dat)
    );

ALU alu(
    .op(alu_op),
    .a(alu_operand_1),
    .b(reg2_dat),
    .result(alu_res),
    .zf(alu_zf),
    .nf(alu_nf)
);

endmodule
