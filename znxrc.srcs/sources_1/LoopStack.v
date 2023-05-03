`timescale 1ns / 1ps

module LoopStack(
    input rst,
    input clk,
    input new, // enabled to create a new loop using 'pc_in' and 'cnt_in'
    input [15:0] cnt_in, // number of iterations in loop created when 'new'
    input [15:0] pc_in, // the program counter at 'loop' op
    input nxt, // enabled if instruction is also 'next'
    output reg [15:0] pc_out, // the 'pc_in' when the loop was created, stable during negative edge
    output reg done // enabled if loop is at last iteration, stable during negative edge
    );
    
    reg [3:0] idx;
    reg [15:0] stk_addr [0:15];
    reg [15:0] stk_cnt [0:15];

    always @(posedge clk) begin
        `ifdef DBG
            $display("  clk: LoopStack");
        `endif

        if (rst) begin
            idx <= 4'hf;
            done <= 0;
        end else begin
            if (new) begin
                done = cnt_in == 1;
                if (!done) begin
                    idx = idx + 1;
                    stk_addr[idx] <= pc_in;
                    stk_cnt[idx] <= cnt_in;
                    pc_out <= pc_in;
                end
            end else if (nxt) begin
                stk_cnt[idx] = stk_cnt[idx] - 1;
                done = stk_cnt[idx] == 1;
                pc_out <= stk_addr[idx];
                if (done) begin
                    idx = idx - 1;
                end
            end
        end
    end
    
endmodule
