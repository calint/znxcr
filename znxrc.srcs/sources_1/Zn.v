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
    input sel, // selector when 'we', enabled cs_*, disabled alu_* 
    input clr // selector when 'we', clears the flags, has precedence over 'sel'
    );
    
always @(posedge clk) begin
    `ifdef DBG
        $display("  clk: Zn");
    `endif

    if (rst) begin
        zf <= 0;
        nf <= 0;
    end else begin
        if (we) begin
            if (clr) begin
                zf <= 0;
                nf <= 0;
            end else begin
                zf <= sel ? cs_zf : alu_zf;
                nf <= sel ? cs_nf : alu_nf;
            end
        end
    end
end    
    
endmodule
