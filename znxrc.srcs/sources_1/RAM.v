`timescale 1ns / 1ps

module RAM (
  input clk,
  input [15:0] addr,
  input we,
  input [15:0] dat_in,
  output [15:0] dat_out
);

reg [15:0] mem [0:65535];

always @(posedge clk) begin
    if (we)
        mem[addr] = dat_in;
end

assign dat_out = mem[addr];

endmodule