`timescale 1ns / 1ps
`default_nettype none

module Zn(
    input wire rst,
    input wire clk,
    input wire cs_zf,
    input wire cs_nf,
    input wire alu_zf,
    input wire alu_nf,
    output reg zf,
    output reg nf,
    input wire we, // depending on 'sel' copy 'CallStack' or 'ALU' zn flags
    input wire sel // enabled alu, disabled cs 
    );
    
    always @(posedge clk) begin
        if (rst) begin
            zf <= 0;
            nf <= 0;
        end else begin
            if (we) begin
                zf = sel ? alu_zf : cs_zf;
                nf = sel ? alu_nf : cs_nf;
            end
        end
    end    
    
endmodule
