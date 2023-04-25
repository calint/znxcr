`timescale 1ns / 1ps
module TB_Top;
reg sw_tb;
wire ld_tb;

// Clock
reg clk_tb = 0;
always #5 clk_tb = ~clk_tb;

Top dut(clk_tb,sw_tb,ld_tb);
initial begin
    sw_tb=1;
    #10
    sw_tb=0;
    #10
    sw_tb=1;
    #10
    sw_tb=0;
    #10
    $stop;
end
endmodule
