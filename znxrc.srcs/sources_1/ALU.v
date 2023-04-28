`timescale 1ns / 1ps
`default_nettype none

module ALU(
  input wire [2:0] op, // operation
  input wire signed [15:0] a, // first operand
  input wire signed [15:0] b, // second operand
  output reg [15:0] result, // result of a op b
  output reg zf, // enabled if result is zero
  output reg nf // enabled if result is negative
);

always @(*) begin
  case(op)
    3'b101: result = a + b;
    3'b111: result = ~b;
    3'b001: result = b + a;
    3'b011: 
        if (a < 0) 
            result = b <<< -a;
        else
            result = b >>> a;
    default: result = 0;
  endcase
  
  zf <= (result == 0);
  nf <= result[15];
end

endmodule