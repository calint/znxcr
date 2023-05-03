`timescale 1ns / 1ps

module RAM (
  input clk,
  input [15:0] addr,
  input we,
  input [15:0] dat_in,
  output [15:0] dat_out
);

reg [15:0] mem [0:8191];

assign dat_out = mem[addr];

always @(posedge clk) begin
    $display("  clk: RAM");
    if (we)
        mem[addr] <= dat_in;
end

endmodule