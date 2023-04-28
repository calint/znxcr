`timescale 1ns / 1ps

module TB_CallStack;
    reg clk = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk = ~clk;

    reg rst = 1;
    reg [15:0] pc_in = 0;
    reg zf_in = 0;
    reg nf_in = 0;
    reg push = 0;
    reg pop = 0;
    wire [15:0] pc_out;
    wire zf_out;
    wire nf_out;

    CallStack dut(
        .rst(rst),
        .clk(clk),
        .pc_in(pc_in),
        .zf_in(zf_in),
        .nf_in(nf_in),
        .push(push),
        .pop(pop),
        .pc_out(pc_out),
        .zf_out(zf_out),
        .nf_out(nf_out)
    );
    
    initial begin
        #clk_tk;
        rst = 0;
    
        pc_in = 1;
        zf_in = 1;
        nf_in = 1;
        push = 1;
        pop = 0;
        #clk_tk;

        pc_in = 2;
        zf_in = 0;
        nf_in = 0;
        push = 1;
        pop = 0;
        #clk_tk;

        push = 0;        
        pop = 1;

        if (pc_out == 2 && zf_out == 0 && nf_out == 0) $display("case 1 passed");
        else  $display("case 1 failed - Expected 2, 0, 0, got %d, %d, %d", pc_out, zf_out, nf_out);

        #clk_tk;
        
        push = 0;        
        pop = 1;
        
        if (pc_out == 1 && zf_out == 1 && nf_out == 1) $display("case 2 passed");
        else $display("case 2 failed - Expected 1, 1, 1, got %d, %d, %d", pc_out, zf_out, nf_out);

        #clk_tk;        

        $finish;
    end
    
endmodule
