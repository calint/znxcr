`timescale 1ns / 1ps

module System(
    input rst,
    input clk_100MHz,
    output debug1
    );

wire clk_out;

Clock clk(
    .reset(rst),
    .clk_in1(clk_100MHz),
    .clk_out1(clk_out)
);

Control ctrl(
    .rst(rst),
    .clk(clk_out),
    .debug1(debug1)
);

endmodule