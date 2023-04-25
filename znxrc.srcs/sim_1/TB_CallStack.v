`timescale 1ns / 1ps

module TB_CallStack;
    reg clk_tb = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk_tb = ~clk_tb;

    reg rst_tb = 1;
    reg [15:0] program_counter_in_tb = 0;
    reg zero_flag_in_tb = 0;
    reg negative_flag_in_tb = 0;
    reg push_tb = 0;
    reg pop_tb = 0;
    wire [15:0] program_counter_out_tb;
    wire zero_flag_out_tb;
    wire negative_flag_out_tb;

    CallStack dut(
        .rst(rst_tb),
        .clk(clk_tb),
        .program_counter_in(program_counter_in_tb),
        .zero_flag_in(zero_flag_in_tb),
        .negative_flag_in(negative_flag_in_tb),
        .push(push_tb),
        .pop(pop_tb),
        .program_counter_out(program_counter_out_tb),
        .zero_flag_out(zero_flag_out_tb),
        .negative_flag_out(negative_flag_out_tb)
    );
    
    initial begin
        #clk_tk;
        rst_tb = 0;
    
        program_counter_in_tb = 1;
        zero_flag_in_tb = 1;
        negative_flag_in_tb = 1;
        push_tb = 1;
        pop_tb = 0;
        #clk_tk;

        program_counter_in_tb = 2;
        zero_flag_in_tb = 0;
        negative_flag_in_tb = 0;
        push_tb = 1;
        pop_tb = 0;
        #clk_tk;

        push_tb = 0;        
        pop_tb = 1;
        #clk_tk;
        
        if (program_counter_out_tb == 2 && zero_flag_out_tb == 0 && negative_flag_out_tb == 0) $display("case 1 passed");
        else  $display("case 1 failed - Expected 2, 0, 0, got %d, %d, %d", program_counter_out_tb, zero_flag_out_tb, negative_flag_out_tb);

        push_tb = 0;        
        pop_tb = 1;
        #clk_tk;
        
        if (program_counter_out_tb == 1 && zero_flag_out_tb == 1 && negative_flag_out_tb == 1) $display("case 2 passed");
        else $display("case 2 failed - Expected 1, 1, 1, got %d, %d, %d", program_counter_out_tb, zero_flag_out_tb, negative_flag_out_tb);

        $finish;
    end
    
endmodule
