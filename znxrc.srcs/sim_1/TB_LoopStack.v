`timescale 1ns / 1ps

module TB_LoopStack;
    reg clk = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk = ~clk;

    reg rst = 1;
    reg new_loop = 0;
    reg next = 0;
    reg [15:0] count = 0;
    reg [15:0] loop_address = 0;
    wire loop_finished;
    wire [15:0] jmp_address;

    LoopStack dut(
        .rst(rst),
        .clk(clk),
        .new_loop(new_loop),
        .count(count),
        .loop_address(loop_address),
        .next(next),
        .loop_finished(loop_finished),
        .jmp_address(jmp_address)
    );
    
    initial begin
        #clk_tk;
        rst = 0;
        
        new_loop = 1;
        next = 0;
        count = 2;
        loop_address = 1;
        #clk_tk;

        new_loop = 1;
        next = 0;
        count = 2;
        loop_address = 2;
        #clk_tk;
        
        new_loop = 0;
        next = 1;
        #clk_tk;

        if (loop_finished == 0 && jmp_address == 2) $display("case 1 passed");
        else $display("case 1 failed - Expected 0, 2 got %d, %d", loop_finished, jmp_address);

        new_loop = 0;
        next = 1;
        #clk_tk;

        if (loop_finished == 1) $display("case 2 passed");
        else $display("case 2 failed - Expected 0 got %d", loop_finished);

        new_loop = 0;
        next = 1;
        #clk_tk;

        if (loop_finished == 0 && jmp_address == 1) $display("case 3 passed");
        else $display("case 3 failed - Expected 0, 2 got %d, %d", loop_finished, jmp_address);

        new_loop = 0;
        next = 1;
        #clk_tk;
        
        if (loop_finished == 1) $display("case 4 passed");
        else $display("case 4 failed - Expected 1, got %d", loop_finished);

        $finish;
    end 
endmodule
