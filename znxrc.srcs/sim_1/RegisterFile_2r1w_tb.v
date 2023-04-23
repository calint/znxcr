`timescale 1ns / 1ps

module RegisterFile_2r1w_tb;
    // Inputs
    reg [3:0] ra1_tb;
    reg [3:0] ra2_tb;
    reg wrt_tb;
    reg signed [15:0] wd_tb;
    reg inca_tb;

    // Outputs
    wire signed [15:0] rd1_tb;
    wire signed [15:0] rd2_tb;

    // Clock
    reg clk_tb = 0;
    always #5 clk_tb = ~clk_tb;

    RegisterFile_2r1w dut (
        .clk(clk_tb),
        .ra1(ra1_tb),
        .ra2(ra2_tb),
        .wrt(wrt_tb), // write 'wd' to address 'ra1'
        .wd(wd_tb),
        .inca(inca_tb), // if true increases value of ra1
        .rd1(rd1_tb),
        .rd2(rd2_tb)
    );

    initial begin
        wrt_tb = 1;
        // write reg[0]=1
        ra1_tb = 0;
        wd_tb = 1;
        #10;
        
        // write reg[1]=2
        ra1_tb = 1;
        wd_tb = 2;
        #10;
        
        wrt_tb = 0;

        // read reg[0] and reg[1]
        ra1_tb = 0;
        ra2_tb = 1;
        #10;

        if (rd1_tb !== 1 || rd2_tb !== 2) begin
            $display("case 1 failed - Expected 1 and 2, got %d and %d", rd1_tb, rd2_tb);
        end else begin
            $display("case 1 passed");
        end

        // read reg[0] and reg[1] then increment reg[0]
        ra1_tb = 0;
        inca_tb = 1;
        ra2_tb = 1;
        #10;

        if (rd1_tb !== 1 || rd2_tb !== 2) begin
            $display("case 2 failed - Expected 1 and 2, got %d and %d", rd1_tb, rd2_tb);
        end else begin
            $display("case 2 passed");
        end

        // read reg[0] and reg[1] then increment reg[0]
        ra1_tb = 0;
        inca_tb = 1;
        ra2_tb = 1;
        #10;

        if (rd1_tb !== 2 || rd2_tb !== 2) begin
            $display("case 3 failed - Expected 2 and 2, got %d and %d", rd1_tb, rd2_tb);
        end else begin
            $display("case 3 passed");
        end

        // read reg[0] and reg[1]
        ra1_tb = 0;
        inca_tb = 0;
        ra2_tb = 1;
        #10;

        if (rd1_tb !== 3 || rd2_tb !== 2) begin
            $display("case 4 failed - Expected 3 and 2, got %d and %d", rd1_tb, rd2_tb);
        end else begin
            $display("case 4 passed");
        end

    end
    
endmodule
