`timescale 1ns / 1ps

module System(
    input rst,
    input clk_100MHz,
    output debug1
    );

wire clk_div_out;

ClockWize clkwiz(
    .reset(rst),
    .clk_in1(clk_100MHz),
    .clk_out1(clk_div_out)
);
/*
ClockDivider clkdiv(
    .clk(clk),
    .clk_out(clk_div_out)
);
*/
Control ctrl(
    .rst(rst),
    .clk(clk_div_out),
    .debug1(debug1)
);

endmodule