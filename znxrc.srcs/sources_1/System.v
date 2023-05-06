`timescale 1ns / 1ps

module System(
    input rst,
    input clk_100MHz,
    output debug1
    );

wire clk_out;
wire clk_locked;

Clock clk(
    .reset(rst),
    .locked(clk_locked),
    .clk_in1(clk_100MHz),
    .clk_out1(clk_out)
);

Control ctrl(
    .rst(!clk_locked),
    .clk(clk_out),
    .debug1(debug1)
);

endmodule