module RegisterFile_2r1w(
    input clk,
    input [3:0] ra1,
    input [3:0] ra2,
    input wrt, // write 'wd' to address 'ra1'
    input [15:0] wd,
    input inca, // if true increases value of ra1
    output reg [15:0] rd1,
    output reg [15:0] rd2
    );

reg [15:0] regs [15:0];

always @(posedge clk) begin
  rd1 <= regs[ra1];
  rd2 <= regs[ra2];
  if (inca)
    regs[ra1] = regs[ra1] + 1;
  if (wrt)
    regs[ra1] <= wd;
end

endmodule
