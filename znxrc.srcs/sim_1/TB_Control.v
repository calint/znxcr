`timescale 1ns / 1ps

module TB_Control;
    reg clk = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk = ~clk;

    reg rst = 1;
    reg [15:0] instruction;
    wire [15:0] program_counter_nxt;
    wire signed [15:0] alu_res;

    Control dut(
        .rst(rst),
        .clk(clk),
        .instruction(instruction), // [reg2] [reg1] [op]ic rxnz
        .program_counter_nxt(program_counter_nxt),
        .alu_res(alu_res)
    );

    initial begin
        #clk_tk;
        rst = 0;

        instruction = 16'h0100; // znxr c [load register] 1 with data
        #clk_tk;
        instruction = 16'h1234; // data
        #clk_tk;

        instruction = 16'h0200; // znxr c [load register] 2 with data
        #clk_tk;
        instruction = 16'h4241; // data
        #clk_tk;

//        instruction = 16'h0030; // znxr C imm:1
//        #clk_tk;

//        instruction = 16'h2120; // znxr c op:1 reg1:1 reg2:2
//        #clk_tk;
        
//        instruction = 16'h3230;
//        #clk_tk;

        $finish;
    end
endmodule