`timescale 1ns / 1ps
`default_nettype none

module Top(
    input wire clk,
    input wire sw, // switch[0}
    output wire ld // led[0]
);
    
assign ld = clk;

endmodule
