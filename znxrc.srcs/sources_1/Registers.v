`timescale 1ns / 1ps
`default_nettype none

module Registers(
    input wire clk,
    input wire [3:0] ra1, // register address 1
    input wire [3:0] ra2, // register address 2
    input wire we, // write 'wd' to address 'ra1'
    input wire [15:0] wd, // data to write when 'we' is enabled
    output wire [15:0] rd1, // register data 1
    output wire [15:0] rd2 // register data 2
    );

reg signed [15:0] mem [0:15];

assign rd1 = mem[ra1];
assign rd2 = mem[ra2];

always @(posedge clk) begin
  if (we)
    mem[ra2] = wd;
end

endmodule
