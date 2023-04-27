`timescale 1ns / 1ps

module ROM (
    input [7:0] addr,
    output [15:0] data
);
  
  reg [15:0] mem [0:255];

  initial begin
    $readmemh("rom.hex", mem);
  end

  assign data = mem[addr];

endmodule