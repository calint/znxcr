`timescale 1ns / 1ps

module TB_LoopStack;
    reg clk_tb = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk_tb = ~clk_tb;

    reg rst_tb = 1;
    reg new_loop_tb = 0;
    reg next_tb = 0;
    reg [15:0] count_tb = 0;
    reg [15:0] loop_address_tb = 0;
    wire loop_finished_tb;
    wire [15:0] jmp_address_tb;

    LoopStack dut(
        .rst(rst_tb),
        .clk(clk_tb),
        .new_loop(new_loop_tb),
        .count(count_tb),
        .loop_address(loop_address_tb),
        .next(next_tb),
        .loop_finished(loop_finished_tb),
        .jmp_address(jmp_address_tb)
    );
    
    initial begin
        #clk_tk;
        rst_tb = 0;
        
        new_loop_tb = 1;
        next_tb = 0;
        count_tb = 2;
        loop_address_tb = 1;
        #clk_tk;

        new_loop_tb = 1;
        next_tb = 0;
        count_tb = 2;
        loop_address_tb = 2;
        #clk_tk;
        
        new_loop_tb = 0;
        next_tb = 1;
        #clk_tk;

        if (loop_finished_tb == 0 && jmp_address_tb == 2) $display("case 1 passed");
        else $display("case 1 failed - Expected 0, 2 got %d, %d", loop_finished_tb, jmp_address_tb);

        new_loop_tb = 0;
        next_tb = 1;
        #clk_tk;

        if (loop_finished_tb == 1) $display("case 2 passed");
        else $display("case 2 failed - Expected 0 got %d", loop_finished_tb);

        new_loop_tb = 0;
        next_tb = 1;
        #clk_tk;

        if (loop_finished_tb == 0 && jmp_address_tb == 1) $display("case 3 passed");
        else $display("case 3 failed - Expected 0, 2 got %d, %d", loop_finished_tb, jmp_address_tb);

        new_loop_tb = 0;
        next_tb = 1;
        #clk_tk;
        
        if (loop_finished_tb == 1) $display("case 4 passed");
        else $display("case 4 failed - Expected 1, got %d", loop_finished_tb);

        $finish;
    end 
endmodule
