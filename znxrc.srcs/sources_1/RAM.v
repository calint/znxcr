`timescale 1ns / 1ps
`default_nettype none

module RAM (
  input wire clk,
  input wire [15:0] addr,
  input wire we,
  input wire [15:0] dat_in,
  output wire [15:0] dat_out
);

reg [15:0] mem [0:65535];

assign dat_out = mem[addr];

always @(posedge clk) begin
    if (we)
        mem[addr] <= dat_in;
end

endmodule