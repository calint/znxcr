`timescale 1ns / 1ps

module ALU(
  input [2:0] op, // operation
  input signed [15:0] a, // first operand
  input signed [15:0] b, // second operand
  output reg [15:0] result, // result of a op b
  output reg zf, // enabled if result is zero
  output reg nf // enabled if result is negative
);

always @(*) begin
//      $display("   * : ALU: (op,a,b)=(%d,%d,%d)", op, a, b);
    `ifdef DBG
        $display("   * : ALU");
    `endif

    case(op)
    3'b000: result = b ^ a;
    3'b010: result = a;
    3'b101: result = b + a;
    3'b001: result = b - a;
    3'b111: result = ~b;
    3'b110: result = a < 0 ? b <<< -a : b >>> a;
    default: result = 0;
    endcase
    
    zf = (result == 0);
    nf = result[15];
end

endmodule