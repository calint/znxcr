`timescale 1ns / 1ps

module Control(
    input rst,
    input clk,
    input [15:0] instruction, // [reg2] [reg1] [op]ic rxnz
    output reg [15:0] program_counter_nxt,
    output [15:0] debug
    );

reg [15:0] program_counter;

reg [3:0] state = 0;

wire cs_zf,cs_nf,alu_zf,alu_nf,cs_push,cs_pop,ls_next,ifz,ifn;
wire [3:0] op;
wire [2:0] alu_op;
wire [15:0] alu_res;
wire [9:0] imm10;
wire [15:0] reg1_val;
wire [15:0] reg2_val;
wire ls_loop_finished;
wire [15:0] ls_jmp_address;
wire [15:0] cs_program_counter_nxt;
wire [3:0] reg1;
wire [3:0] reg2;
wire regs_we;
wire [15:0] regs_wd;
wire regs_inca;
wire [15:0] alu_operand_2;
wire is_alu_op;

assign ifz = state == 0 ? instruction[0] : 0;
assign ifn = state == 0 ? instruction[1] : 0;
assign ls_next = state == 0 ? instruction[2] : 0;
assign cs_pop = state == 0 ? instruction[3] : 0;
assign cs_push = state == 0 ? instruction[4] : 0;
assign op = state == 0 ? instruction[7:4] : 0;
assign reg1 = state == 1 || state == 2 ? reg_to_write : instruction[11:8];
assign reg2 = instruction[15:12];
assign alu_op = instruction[7:5] == 3'b011 && reg2 == 0 ? 3'b111 : instruction[7:5];
assign alu_operand_2 = alu_op == 3'b011 && reg2 != 0 ? {{12{reg2[3]}}, reg2} : reg2_val;
assign imm10 = state == 0 ? instruction[15:6] : 0;
assign is_alu_op = op == 4'b1010 || op == 4'b0010 || op == 4'b0110; // 'add','inc','shf' or 'not':
assign regs_we = state == 1 || is_alu_op ? 1 : 0;
assign regs_wd = state == 1 ? instruction : 
                 is_alu_op ? alu_res :
                 0;
                 
assign debug = regs.regs[1];

reg [3:0] reg_to_write = 0;
reg [15:0] reg_to_write_data = 0;

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
                    reg_to_write = reg1;
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
    .inca(regs_inca), // if true increases value of 'ra1' after the read or write is done
    .rd1(reg1_val),
    .rd2(reg2_val)
    );

ALU alu(
//    .clk(clk),
    .op(alu_op),
    .a(reg1_val),
    .b(alu_operand_2),
    .result(alu_res),
    .zf(alu_zf),
    .nf(alu_nf)
);

endmodule
