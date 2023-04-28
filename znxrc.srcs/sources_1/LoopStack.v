`timescale 1ns / 1ps
`default_nettype none

module LoopStack(
    input wire rst,
    input wire clk,
    input wire new_loop, // true to create a new loop using 'loop_address' for the jump and 'count' for the number of iterations
    input wire [15:0] count, // number of iterations in loop when creating new loop with 'new_loop'
    input wire [15:0] loop_address, // the address to which to jump at next
    input wire next, // true if current loop is at instruction that is 'next'
    output reg loop_finished, // true if current loop is finished
    output reg [15:0] jmp_address // the address to jump to if loop is not finished
    );
    
    reg [3:0] stack_idx;
    reg [15:0] stack_loop_address [0:15];
    reg [15:0] stack_loop_counter [0:15];

    always @(posedge clk) begin
        if (rst) begin
            stack_idx <= 0;
            loop_finished <= 0;
            jmp_address <= 0;
        end else begin
            if (new_loop) begin
                stack_idx = stack_idx + 1;
                stack_loop_address[stack_idx] = loop_address;
                stack_loop_counter[stack_idx] = count;
                loop_finished = 0;
            end else if (next) begin
                stack_loop_counter[stack_idx] = stack_loop_counter[stack_idx] - 1;
                if (stack_loop_counter[stack_idx] == 0) begin
                    loop_finished = 1;
                    stack_idx = stack_idx - 1;
                end else begin
                    loop_finished = 0;
                    jmp_address = stack_loop_address[stack_idx];
                end
            end
        end
    end
    
endmodule
