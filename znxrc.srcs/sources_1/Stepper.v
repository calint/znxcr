`timescale 1ns / 1ps

module Stepper(
    input rst,
    input clk,
    output reg [3:0] step
    );
    
    always @(posedge clk) begin
        $display("  clk: Stepper");
        if (rst) begin
            step <= 4'b0001;
        end else begin
            if (step == 4'b1000) begin
                step <= 4'b0001;
            end else begin
                step <= step << 1;
            end
        end
    end
endmodule
