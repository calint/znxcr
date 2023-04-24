module RAM (
  input clock,
  input [7:0] address,
  input we,
  input [15:0] data_input,
  output [15:0] data_output
);

reg [15:0] memory [0:255];

assign data_output = memory[address];

always @(posedge clock) begin
  if (we == 1) begin
    memory[address] <= data_input;
  end
end

endmodule