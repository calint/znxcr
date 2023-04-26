module ALU(
  input [2:0] op,
  input signed [15:0] a,
  input signed [15:0] b,
  output reg [15:0] result,
  output reg zf,
  output reg nf
);

always @(*) begin
  case(op)
    3'b101: result = a + b;
    3'b111: result = ~a;
    3'b001: result = a + 1;
    3'b011: 
        if (b < 0) 
            result = a <<< -b;
        else
            result = a >>> b;
    default: result = 0;
  endcase
  
  zf <= (result == 0);
  nf <= result[15];
end

endmodule