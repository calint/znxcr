`timescale 1ns / 1ps

module LoopStack(
    input rst,
    input clk,
    input new, // enabled to create a new loop using 'pc_in' and 'cnt_in'
    input [15:0] cnt_in, // number of iterations in loop created when 'new'
    input [15:0] pc_in, // the program counter at 'loop' op
    input nxt, // enabled if instruction is also 'next'
    input done_ack, // enabled if cpu acknowledged the 'done' at current 'next' instruction
    output reg [15:0] pc_out, // the 'pc_in' when the loop was created, stable during negative edge
    output reg done // enabled if loop is at last iteration, stable during negative edge
    );

reg [15:0] stk_addr [0:15]; // stack of loop begin addresses
reg [15:0] stk_cnt [0:15]; // stack of loop counters
reg [3:0] idx; // index in the stack
reg [15:0] cnt; // current loop counter

always @(posedge clk) begin
    `ifdef DBG
        $display("  clk: LoopStack:  cnt=%0d,idx=%0d,done=%d",cnt,idx,done);
    `endif

    if (rst) begin
        idx <= 4'hf;
        done <= 0;
    end else begin
        if (new) begin
            idx = idx + 1; // push stack
            stk_addr[idx] <= pc_in; // store jump address (-1)
            stk_cnt[idx] <= cnt_in; // store loop counter
            cnt <= cnt_in; // set active counter
            pc_out <= pc_in; // output jump address (-1)
            done <= cnt_in == 1; // if only iteration
        end else if (nxt) begin
            cnt = cnt - 1;
            done <= cnt == 1; // if next iteration is the last
        end else if (done_ack) begin
            idx = idx - 1; // pop values from the stacks
            cnt = stk_cnt[idx];
            stk_cnt[idx] <= cnt - 1; // decrease parent loop counter
            pc_out <= stk_addr[idx]; // update jump address
            done <= cnt == 1; // if next iteration is the last
        end
    end
end
    
endmodule
