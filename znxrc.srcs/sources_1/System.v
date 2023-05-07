`timescale 1ns / 1ps
`default_nettype none

module System(
    input wire reset,
    input wire clk_in_12MHz,
    output wire [3:0] led
    );

wire clk_locked;
wire clk_out_33MHz;

Clocks clks(
    .reset(reset),
    .locked(clk_locked),
    .clk_in_12MHz(clk_in_12MHz),
    .clk_out_33MHz(clk_out_33MHz)
);

Control ctrl(
    .rst(!clk_locked),
    .clk(clk_out_33MHz),
    .led(led)
);

endmodule

`default_nettype wire
