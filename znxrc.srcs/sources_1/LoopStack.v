`timescale 1ns / 1ps
`default_nettype none

module LoopStack(
    input wire rst,
    input wire clk,
    input wire new, // enabled to create a new loop using 'pc_in' + 1 for the jump at 'next' and 'cnt' for the number of iterations
    input wire [15:0] cnt_in, // number of iterations in loop created 'new'
    input wire [15:0] pc_in, // the address to which to jump at next
    input wire nxt, // true if current loop is at instruction that is 'next'
    output wire [15:0] cnt_out, // current loop counter
    output wire [15:0] pc_out, // the address to jump to if loop is not finished
    output reg done // true if loop is finished
    );
    
    reg [3:0] idx;
    reg [15:0] stk_addr [0:15];
    reg [15:0] stk_cnt [0:15];

    assign pc_out = stk_addr[idx];
    assign cnt_out = stk_cnt[idx];

    always @(posedge clk) begin
        if (rst) begin
            idx <= 4'hf;
            done <= 0;
        end else begin
            if (new) begin
                idx = idx + 1;
                stk_addr[idx] = pc_in; // pc_in has been incremented in 'Control always @(posedge clk)' // ? racing
                stk_cnt[idx] = cnt_in;
            end else if (nxt) begin
                stk_cnt[idx] = stk_cnt[idx] - 1;
                if (stk_cnt[idx] == 0) begin
                    idx = idx - 1;
                    done = 1;
                end else begin
                    done = 0;
                end
            end
        end
    end
    
endmodule
