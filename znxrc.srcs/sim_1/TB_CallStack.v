`timescale 1ns / 1ps

module TB_CallStack;
    reg clk = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk = ~clk;

    reg rst = 1;
    reg [15:0] program_counter_in = 0;
    reg zero_flag_in = 0;
    reg negative_flag_in = 0;
    reg push = 0;
    reg pop = 0;
    wire [15:0] program_counter_out;
    wire zero_flag_out;
    wire negative_flag_out;

    CallStack dut(
        .rst(rst),
        .clk(clk),
        .program_counter_in(program_counter_in),
        .zero_flag_in(zero_flag_in),
        .negative_flag_in(negative_flag_in),
        .push(push),
        .pop(pop),
        .program_counter_out(program_counter_out),
        .zero_flag_out(zero_flag_out),
        .negative_flag_out(negative_flag_out)
    );
    
    initial begin
        #clk_tk;
        rst = 0;
    
        program_counter_in = 1;
        zero_flag_in = 1;
        negative_flag_in = 1;
        push = 1;
        pop = 0;
        #clk_tk;

        program_counter_in = 2;
        zero_flag_in = 0;
        negative_flag_in = 0;
        push = 1;
        pop = 0;
        #clk_tk;

        push = 0;        
        pop = 1;
        #clk_tk;
        
        if (program_counter_out == 2 && zero_flag_out == 0 && negative_flag_out == 0) $display("case 1 passed");
        else  $display("case 1 failed - Expected 2, 0, 0, got %d, %d, %d", program_counter_out, zero_flag_out, negative_flag_out);

        push = 0;        
        pop = 1;
        #clk_tk;
        
        if (program_counter_out == 1 && zero_flag_out == 1 && negative_flag_out == 1) $display("case 2 passed");
        else $display("case 2 failed - Expected 1, 1, 1, got %d, %d, %d", program_counter_out, zero_flag_out, negative_flag_out);

        $finish;
    end
    
endmodule
