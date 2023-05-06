`timescale 1ns / 1ps

module System(
    input reset,
    input clk_in_100MHz,
    output debug1
    );

wire clk_locked;
wire clk_out_33MHz;

Clocks clks(
    .reset(reset),
    .locked(clk_locked),
    .clk_in_100MHz(clk_in_100MHz),
    .clk_out_33MHz(clk_out_33MHz)
);

Control ctrl(
    .rst(!clk_locked),
    .clk(clk_out_33MHz),
    .debug1(debug1)
);

endmodule