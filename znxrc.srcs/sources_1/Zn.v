`timescale 1ns / 1ps

module Zn(
    input rst,
    input clk,
    input cs_zf,
    input cs_nf,
    input alu_zf,
    input alu_nf,
    output reg zf,
    output reg nf,
    input we, // depending on 'sel' copy 'CallStack' or 'ALU' zn flags
    input sel // enabled alu, disabled cs 
    );
    
    always @(posedge clk) begin
        $display("  clk: Zn");
        if (rst) begin
            zf <= 0;
            nf <= 0;
        end else begin
            if (we) begin
                zf <= sel ? alu_zf : cs_zf;
                nf <= sel ? alu_nf : cs_nf;
            end
        end
    end    
    
endmodule
