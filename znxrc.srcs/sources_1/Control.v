`timescale 1ns / 1ps

module Control(
    input rst,
    input clk,
    input [15:0] instruction, // [reg2] [reg1] [op]ic rxnz
    output reg [15:0] program_counter_nxt,
    output [15:0] debug1,
    output [15:0] debug2
    );

reg [15:0] program_counter;

reg [3:0] state = 0;

wire cs_zf,cs_nf,alu_zf,alu_nf;
wire [15:0] alu_res;
wire [15:0] reg1_val;
wire [15:0] reg2_val;
wire ls_loop_finished;
wire [15:0] ls_jmp_address;
wire [15:0] cs_program_counter_nxt;

wire ifz = state == 0 ? instruction[0] : 0;
wire ifn = state == 0 ? instruction[1] : 0;
wire ls_next = state == 0 ? instruction[2] : 0;
wire cs_pop = state == 0 ? instruction[3] : 0;
wire cs_push = state == 0 ? instruction[4] : 0;
wire [3:0] op = state == 0 ? instruction[7:4] : 0;
wire [3:0] reg1 = instruction[11:8];
wire [3:0] reg2 = state == 1 ? reg_to_write : instruction[15:12];
wire [2:0] alu_op = instruction[7:5] == 3'b011 && reg1 == 0 ? 3'b111 : instruction[7:5];
wire [15:0] alu_operand_1 = alu_op == 3'b011 && reg1 != 0 ? {{12{reg1[3]}}, reg1} : reg1_val;
//wire [15:0] alu_operand_1 = reg1_val;
wire [9:0] imm10 = state == 0 ? instruction[15:6] : 0;
wire is_alu_op = op == 4'b1010 || op == 4'b0010 || op == 4'b0110; // 'add','inc','shf' or 'not':
wire regs_we = state == 1 || is_alu_op ? 1 : 0;
wire [15:0] regs_wd = state == 1 ? instruction : 
                      is_alu_op ? alu_res :
                      0;
                 
assign debug1 = regs.regs[1];
assign debug2 = regs.regs[2];

reg [3:0] reg_to_write = 0;

always @(posedge clk) begin
    if (rst) begin
        program_counter <= 0;
        state <= 0;
    end else begin
        case(state)
        4'd0: // state 0: decode instruction
        begin
            if (cs_push) begin // 'call': calls immediate imm10
                program_counter_nxt = {{6{0}}, imm10};            
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
        4'd1: // state 1: write 'reg_to_write' with current 'instruction'
        begin
            state = 0;            
        end
        endcase
    end
end

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
    .count(reg1_val), // number of iterations in loop when creating new loop with 'new_loop'
    .loop_address(program_counter), // the address to which to jump at next
    .next(ls_next), // true if current loop is at instruction that is 'next'
    .loop_finished(ls_loop_finished), // true if current loop is finished
    .jmp_address(ls_jmp_address) // the address to jump to if loop is not finished
    );

Registers regs(
    .clk(clk),
    .ra1(reg1),
    .ra2(reg2),
    .we(regs_we), // write 'wd' to address 'ra1'
    .wd(regs_wd), // data to write when 'we' is true
    .rd1(reg1_val),
    .rd2(reg2_val)
    );

ALU alu(
//    .clk(clk),
    .op(alu_op),
    .a(alu_operand_1),
    .b(reg2_val),
    .result(alu_res),
    .zf(alu_zf),
    .nf(alu_nf)
);

endmodule
