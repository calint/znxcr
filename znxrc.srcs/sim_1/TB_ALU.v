`timescale 1ns / 1ps
`default_nettype none

module TB_ALU;

reg clk = 0;
parameter clk_tk = 10;
always #(clk_tk/2) clk = ~clk;

// Inputs
reg signed [15:0] a;
reg signed [15:0] b;
reg [2:0] op;

// Outputs
wire signed [15:0] result;
wire zf;
wire nf;

ALU dut (
    .op(op),
    .a(a),
    .b(b),
    .result(result),
    .zf(zf),
    .nf(nf)
);

initial begin
    // Test case 1 - Add
    a = 5;
    b = 3;
    op = 3'b101; // add a and b
    #clk_tk;
    
    if (result == 8 && !zf && !nf) $display("case 1 passed");
    else $display("case 1 failed - Expected 8, 0, 0 got %d", result, zf, nf);

    a = -1;
    b = 1;
    op = 3'b110; // shift b by a
    #clk_tk;

    if (result == 2) $display("case 2 passed");
    else $display("case 2 failed - Expected 2, got %d", result);
            
    a = 1;
    b = 2;
    op = 3'b110; // shift b by a
    #clk_tk;

    if (result == 1) $display("case 3 passed");
    else $display("case 3 failed - Expected 1, got %d", result);
    
    a = 1;
    b = -1;
    op = 3'b110; // shift b by a
    #clk_tk;

    if (result == -1) $display("case 4 passed");
    else $display("case 4 failed - Expected -1, got %d", result);

    a = 2;
    b = -1;
    op = 3'b010; // b = a
    #clk_tk;

    if (result == 2 && !zf && !nf) $display("case 5 passed");
    else $display("case 5 failed - Expected 2, 0, 0 got %d, %d", result, zf, nf);

    a = 0;
    b = 1;
    op = 3'b111; // not b
    #clk_tk;

    if (result == -2) $display("case 7 passed");
    else $display("case 7 failed - Expected -2, got %d", result);

    a = 1;
    b = 2;
    op = 3'b001; // b - a
    #clk_tk;

    if (result == 1) $display("case 8 passed");
    else $display("case 8 failed - Expected 1, got %d", result);

    a = 2;
    b = 2;
    op = 3'b001; // b - a
    #clk_tk;

    if (result == 0 && zf && !nf) $display("case 9 passed");
    else $display("case 9 failed - Expected 0, 1, 0 got %d, %d, %d", result, zf, nf);


    $finish;
    
end
    
endmodule

`default_nettype wire