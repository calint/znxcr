`timescale 1ns / 1ps

module ROM (
  input [7:0] address,
  output [15:0] data_out
);
  
  reg [15:0] rom_array [0:255];

  initial begin
    rom_array[0] = 16'h01;
    rom_array[1] = 16'h02;
    rom_array[2] = 16'h03;
  end

  assign data_out = rom_array[address];

endmodule