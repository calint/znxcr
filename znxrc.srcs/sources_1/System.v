`timescale 1ns / 1ps

module System(
    input reset,
    input clk_in1,
    output debug1
    );

wire clk_out;
wire clk_locked;

Clock clk(
    .reset(reset),
    .locked(clk_locked),
    .clk_in1(clk_in1),
    .clk_out1(clk_out)
);

Control ctrl(
    .rst(!clk_locked),
    .clk(clk_out),
    .debug1(debug1)
);

endmodule