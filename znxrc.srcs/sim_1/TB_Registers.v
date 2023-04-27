`timescale 1ns / 1ps

module TB_Registers;
    reg clk = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk = ~clk;

    // Inputs
    reg [3:0] ra1;
    reg [3:0] ra2;
    reg we;
    reg signed [15:0] wd;

    // Outputs
    wire signed [15:0] rd1;
    wire signed [15:0] rd2;

    Registers dut (
        .clk(clk),
        .ra1(ra1),
        .ra2(ra2),
        .we(we), // write 'wd' to address 'ra1'
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    initial begin
        we = 1;
        // write reg[0]=1
        ra2 = 0;
        wd = 1;
        #clk_tk;
        
        // write reg[1]=2
        ra2 = 1;
        wd = 2;
        #clk_tk;
        
        we = 0;

        // read reg[0] and reg[1]
        ra1 = 0;
        ra2 = 1;
        #clk_tk;

        if (rd1 == 1 && rd2 == 2) $display("case 1 passed");
        else $display("case 1 failed - Expected 1 and 2, got %d and %d", rd1, rd2);

        $finish;
    end

endmodule
