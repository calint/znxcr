`timescale 1ns / 1ps
module top_tb;
reg sw;
wire ld;
top tp(sw,ld);
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
