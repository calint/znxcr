module ALU(
  input [3:0] op,
  input signed [15:0] a,
  input signed [15:0] b,
  output reg [15:0] result,
  output reg zf,
  output reg nf
);

always @*
begin
  case(op)
    4'b0000: result = a + b;
    4'b0001: result = ~a;
    4'b0010: result = a + 1;
    4'b0011: 
        if (b < 0) 
            result = a << -b;
        else
            result = a >>> b;
            
    default: result = 0;
  endcase
  
  zf <= (result == 0);
  nf <= result[15];

end
endmodule