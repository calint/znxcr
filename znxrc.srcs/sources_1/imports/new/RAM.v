`timescale 1ns / 1ps

module RAM (
  input [7:0] address,
  input [15:0] data_input,
  input write_enable,
  input clock,
  output [15:0] data_output
);

reg [15:0] memory [255:0];

assign data_output = memory[address];

always @(posedge clock) begin
  if (write_enable == 1) begin
    memory[address] <= data_input;
  end
end

endmodule