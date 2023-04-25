`timescale 1ns / 1ps

module TB_ALU;
    reg clk_tb = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk_tb = ~clk_tb;

    // Inputs
    reg signed [15:0] a_tb;
    reg signed [15:0] b_tb;
    reg [3:0] op_tb;

    // Outputs
    wire signed [15:0] result_tb;
    wire zf_tb;
    wire nf_tb;
    
    ALU dut (
        .op(op_tb),
        .a(a_tb),
        .b(b_tb),
        .result(result_tb),
        .zf(zf_tb),
        .nf(nf_tb)
    );

    initial begin
        // Test case 1 - Add
        a_tb = 5;
        b_tb = 3;
        op_tb = 4'b0000; // Add operation
        #clk_tk;
        
        if (result_tb == 8) $display("case 1 passed");
        else $display("case 1 failed - Expected 8, got %d", result_tb);

        a_tb = 1;
        b_tb = -1;
        op_tb = 4'b0011; // shift
        #clk_tk;

        if (result_tb == 2) $display("case 2 passed");
        else $display("case 2 failed - Expected 2, got %d", result_tb);
                
        a_tb = 2;
        b_tb = 1;
        op_tb = 4'b0011; // shift
        #clk_tk;

        if (result_tb == 1) $display("case 3 passed");
        else $display("case 3 failed - Expected 1, got %d", result_tb);
        
        a_tb = -1;
        b_tb = 1;
        op_tb = 4'b0011; // shift
        #clk_tk;

        if (result_tb == -1) $display("case 4 passed");
        else $display("case 4 failed - Expected -1, got %d", result_tb);

        $finish;
        
    end
    
endmodule
