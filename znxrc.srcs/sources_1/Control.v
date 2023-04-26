`timescale 1ns / 1ps

module Control(
    input rst,
    input clk,
    input [15:0] instruction, // [reg2] [reg1] [op]ic rxnz
    output reg [15:0] program_counter_nxt,
    output [15:0] alu_res
    );

reg [15:0] program_counter;

reg [3:0] state = 0;

wire cs_zf,cs_nf,alu_zf,alu_nf,cs_push,cs_pop,ls_next,ifz,ifn;
wire [3:0] op;
wire [2:0] alu_op;
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
wire regs_inca = 0;

assign ifz = state == 0 ? instruction[0] : 0;
assign ifn = state == 0 ? instruction[1] : 0;
assign ls_next = state == 0 ? instruction[2] : 0;
assign cs_pop = state == 0 ? instruction[3] : 0;
assign cs_push = state == 0 ? instruction[4] : 0;
assign op = state == 0 ? instruction[7:4] : 0;
assign alu_op = state == 0 ? instruction[7:5] : 0;
assign reg1 = state == 0 ? instruction[11:8] : reg_to_load;
assign reg2 = state == 0 ? instruction[15:12] : 0;
assign imm10 = state == 0 ? instruction[15:6] : 0;
assign regs_we = state == 1 ? 1 : 0;
assign regs_wd = state == 1 ? instruction : 0;

reg [3:0] reg_to_load = 0;

always @(posedge clk) begin
    if (rst) begin
        program_counter <= 0;
        state <= 0;
    end else begin
        case(state)
        4'd0: // state 0: decode instruction
        begin
            if (cs_push) begin // command 'call'
                program_counter_nxt = {6'b000000,instruction[15:6]};            
            end else begin // operation
                case(op)
                4'b0000: begin // load register with data from the next instruction 
                    state = 1;
                    reg_to_load = reg1;
                end
                default: state=0;
                endcase
            end
        end
        4'd1: // state 1: load next instruction as data into register 'reg_to_load'
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
    .op(alu_op),
    .a(reg1_val),
    .b(reg2_val),
    .result(alu_res),
    .zf(alu_zf),
    .nf(alu_nf)
);

endmodule
