`timescale 1ns / 1ps

module Control(
    input rst,
    input clk,
    input [15:0] instruction, // [reg2] [reg1] [op]ic rxnz
    output reg [15:0] program_counter_nxt,
    output [15:0] alu_res
    );

reg [15:0] program_counter;
//wire [15:0] program_counter_nxt;

wire cs_zf,cs_nf,alu_zf,alu_nf,cs_push,cs_pop,ls_next,ifz,ifn;
wire [3:0] alu_op;
wire [3:0] reg1;
wire [3:0] reg2;
wire regs_we,regs_inca;
wire [15:0] regs_wd;
wire [15:0] reg1_val;
wire [15:0] reg2_val;
wire ls_loop_finished;
wire [15:0] ls_jmp_address;
wire [15:0] cs_program_counter_nxt;

assign ifz = instruction[0];
assign ifn = instruction[1];
assign ls_next = instruction[2];
assign cs_pop = instruction[3];
assign cs_push = instruction[4];
assign alu_op = instruction[7:5];
assign reg1 = instruction[11:8];
assign reg2 = instruction[15:12];
assign regs_wd = alu_res;

reg [3:0] state;

always @(posedge clk) begin
    if (rst) begin
        program_counter <= 0;
        state <= 0;
    end else begin
        if (cs_push) begin // call
            program_counter_nxt = {5'b00000,instruction[15:5]};            
        end
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
    .op(alu_op),
    .a(reg1_val),
    .b(reg2_val),
    .result(alu_res),
    .zf(alu_zf),
    .nf(alu_nf)
);

endmodule
