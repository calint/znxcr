`timescale 1ns / 1ps

module Top(
    input clk,
    input sw, // switch[0}
    output ld // led[0]
);
    
assign ld = clk;

endmodule
