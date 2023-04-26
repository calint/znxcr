`timescale 1ns / 1ps
module TB_Top;
reg sw;
wire ld;

// Clock
reg clk = 0;
always #5 clk = ~clk;

Top dut(clk,sw,ld);

initial begin
    sw=1;
    #10
    sw=0;
    #10
    sw=1;
    #10
    sw=0;
    #10
    $stop;
end
endmodule
