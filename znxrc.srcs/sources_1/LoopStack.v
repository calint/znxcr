`timescale 1ns / 1ps

module LoopStack(
    input rst,
    input clk,
    input new, // enabled to create a new loop using 'pc_in' and 'cnt_in'
    input [15:0] cnt_in, // number of iterations in loop created when 'new'
    input [15:0] pc_in, // the program counter at 'loop' op
    input nxt, // enabled if instruction has 'next'
    output [15:0] pc_out, // the 'pc_in' when the loop was created
    output done // enabled if loop is at last iteration
    );
    
    reg [3:0] idx;
    reg [15:0] stk_addr [0:15];
    reg [15:0] stk_cnt [0:15];

    assign pc_out = stk_addr[idx];
    assign done = stk_cnt[idx] == 1 || idx == 15;

    always @(posedge clk) begin
        $display("  clk: LoopStack");
        if (rst) begin
            idx <= 4'hf;
        end else begin
            if (new) begin
                idx = idx + 1;
                stk_addr[idx] = pc_in;
                stk_cnt[idx] = cnt_in;
            end else if (nxt) begin
                stk_cnt[idx] = stk_cnt[idx] - 1;
                if (stk_cnt[idx] == 0) begin
                    idx = idx - 1;
                end
            end
        end
    end
    
endmodule
