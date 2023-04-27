`timescale 1ns / 1ps

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
        
        if (result == 8) $display("case 1 passed");
        else $display("case 1 failed - Expected 8, got %d", result);

        a = -1;
        b = 1;
        op = 3'b011; // shift b by a
        #clk_tk;

        if (result == 2) $display("case 2 passed");
        else $display("case 2 failed - Expected 2, got %d", result);
                
        a = 1;
        b = 2;
        op = 3'b011; // shift b by a
        #clk_tk;

        if (result == 1) $display("case 3 passed");
        else $display("case 3 failed - Expected 1, got %d", result);
        
        a = 1;
        b = -1;
        op = 3'b011; // shift b by a
        #clk_tk;

        if (result == -1) $display("case 4 passed");
        else $display("case 4 failed - Expected -1, got %d", result);

        a = 0;
        b = -1;
        op = 3'b001; // inc b
        #clk_tk;

        if (result == 0) $display("case 5 passed");
        else $display("case 5 failed - Expected 0, got %d", result);

        a = 0;
        b = 1;
        op = 3'b111; // not b
        #clk_tk;

        if (result == -1) $display("case 6 passed");
        else $display("case 6 failed - Expected -1, got %d", result);

        $finish;
        
    end
    
endmodule
