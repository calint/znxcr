`timescale 1ns / 1ps

module TB_Control;
    reg clk = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk = ~clk;

    reg rst = 1;
    reg [15:0] program_counter = 0;
    wire [15:0] program_counter_nxt;
    wire signed [15:0] debug1;
    wire signed [15:0] debug2;

    Control dut(
        .rst(rst),
        .clk(clk),
        .program_counter(program_counter),
        .program_counter_nxt(program_counter_nxt),
        .debug1(debug1),
        .debug2(debug2)
    );

    initial begin
        #clk_tk;
        rst = 0;

//        instruction = 16'h1000; // znxr c [load register] 1 with data
        #clk_tk;
        program_counter = program_counter + 1;
//        instruction = 16'h1234; // data
        #clk_tk;
        program_counter = program_counter + 1;
        
        if (debug1 == 16'h1234) $display("case 1 passed");
        else $display("case 1 failed - Expected 0x1234, got %d", debug1);

//        instruction = 16'h2000; // znxr c [load register] 2 with data
        #clk_tk;
        program_counter = program_counter + 1;
//        instruction = 16'h0001; // data
        #clk_tk;
        program_counter = program_counter + 1;

        if (debug2 == 16'h1) $display("case 2 passed");
        else $display("case 2 failed - Expected 1, got %d", debug2);

//        instruction = 16'h12a0; // znxr c [add] register 2 to register 1
        #clk_tk;
        program_counter = program_counter + 1;

        if (debug1 == 16'h1235) $display("case 3 passed");
        else $display("case 3 failed - Expected 0x1235, got %d", debug1);

//        instruction = 16'h12a0; // znxr c [add] register 1 to register 2
        #clk_tk;
        program_counter = program_counter + 1;

        if (debug1 == 16'h1236) $display("case 4 passed");
        else $display("case 4 failed - Expected 0x1236, got %d", debug1);

//        instruction = 16'h1000; // znxr c [load register] 1 with data
        #clk_tk;
        program_counter = program_counter + 1;
//        instruction = 16'h0004; // data
        #clk_tk;
        program_counter = program_counter + 1;

        if (debug1 == 4) $display("case 5 passed");
        else $display("case 5 failed - Expected 4, got %d", debug1);

//        instruction = 16'h1260; // znxr c [right shift] register 1 by 2
        #clk_tk;
        program_counter = program_counter + 1;

        if (debug1 == 1) $display("case 6 passed");
        else $display("case 6 failed - Expected 1, got %d", debug1);
 
//        instruction = 16'h1e60; // znxr c [lef shift] register 1 by 2
        #clk_tk;
        program_counter = program_counter + 1;

        if (debug1 == 4) $display("case 7 passed");
        else $display("case 7 failed - Expected 4, got %d", debug1);

//        instruction = 16'h1060; // znxr c [not] register 1
        #clk_tk;
        program_counter = program_counter + 1;

        if (debug1 == -5) $display("case 8 passed");
        else $display("case 8 failed - Expected -5, got %d", debug1);

        $finish;
    end
endmodule
