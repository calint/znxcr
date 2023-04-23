module RegisterFile_2r1w(
    input clk,
    input [3:0] ra1,
    input [3:0] ra2,
    input [3:0] wa,
    input [15:0] wd,
    output reg [15:0] rd1,
    output reg [15:0] rd2
    );

reg [15:0] regs [15:0];

always @(posedge clk) begin
  rd1 <= regs[ra1];
  rd2 <= regs[ra2];
  if (wa !== 4'b0000)
    regs[wa] <= wd;
end

endmodule
