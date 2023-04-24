module Registers(
    input clk,
    input [3:0] ra1,
    input [3:0] ra2,
    input we, // write 'wd' to address 'ra1'
    input [15:0] wd, // data to write when 'we' is true
    input inca, // if true increases value of ra1
    output reg [15:0] rd1,
    output reg [15:0] rd2
    );

reg [15:0] regs [0:15];

always @(posedge clk) begin
  rd1 <= regs[ra1];
  rd2 <= regs[ra2];
  if (inca)
    regs[ra1] <= regs[ra1] + 1;
  if (we)
    regs[ra1] <= wd;
end

endmodule
