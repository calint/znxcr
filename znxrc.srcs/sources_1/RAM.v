module RAM (
  input clk,
  input [7:0] addr,
  input we,
  input [15:0] dat_in,
  output [15:0] dat_out
);

reg [15:0] memory [0:255];

always @(posedge clk) begin
  if (we) memory[addr] <= dat_in;
  dat_out <= memory[addr];
end

endmodule