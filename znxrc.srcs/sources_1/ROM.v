`timescale 1ns / 1ps
`default_nettype none

module ROM (
    input wire [15:0] addr,
    output wire [15:0] data
);
  
  reg [15:0] mem [0:65535];

  initial begin
    $readmemh("rom.hex", mem);
  end

  assign data = mem[addr];

endmodule