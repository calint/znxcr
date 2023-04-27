`timescale 1ns / 1ps

module Top(
    input clk,
    input sw,
    output ld
);
    
assign ld = clk;

endmodule
