module ALU(
//  input clk,
  input [2:0] op,
  input signed [15:0] a,
  input signed [15:0] b,
  output reg [15:0] result,
  output reg zf,
  output reg nf
);

//always @(posedge clk) begin
always @(*) begin
  case(op)
    3'b101: result = a + b;
    3'b111: result = ~a;
    3'b001: result = a + 1;
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