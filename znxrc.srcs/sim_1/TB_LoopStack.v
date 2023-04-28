`timescale 1ns / 1ps

module TB_LoopStack;
    reg clk = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk = ~clk;

    reg rst = 1;
    reg new = 0;
    reg nxt = 0;
    reg [15:0] cnt_in = 0;
    reg [15:0] pc_in = 0;
    wire [15:0] cnt_out;
    wire [15:0] pc_out;
    wire done;

    LoopStack dut(
        .rst(rst),
        .clk(clk),
        .new(new),
        .cnt_in(cnt_in),
        .pc_in(pc_in),
        .nxt(nxt),
        .cnt_out(cnt_out),
        .pc_out(pc_out),
        .done(done)
    );
    
    initial begin
        #clk_tk;
        rst = 0;
        
        // push loop count 2, jmp address 2
        new = 1;
        nxt = 0;
        cnt_in = 2;
        pc_in = 1;
        #clk_tk;

        // push loop count 2, jmp address 3
        new = 1;
        nxt = 0;
        cnt_in = 2;
        pc_in = 2;
        #clk_tk;
        
        // next => counter=1
        new = 0;
        nxt = 1;
        #clk_tk;

        if (!done && pc_out == 3) $display("case 1 passed");
        else $display("case 1 failed - Expected false, 3 got %d, %d", done, pc_out);

        // next => counter=0
        new = 0;
        nxt = 1;
        #clk_tk;

        if (done) $display("case 2 passed");
        else $display("case 2 failed - Expected true got %d", done);

        new = 0;
        nxt = 1;
        #clk_tk;

        if (!done && pc_out == 2) $display("case 3 passed");
        else $display("case 3 failed - Expected false, 2 got %d, %d", done, pc_out);

        new = 0;
        nxt = 1;
        #clk_tk;
        
        if (done) $display("case 4 passed");
        else $display("case 4 failed - Expected true, got %d", done);

        $finish;
    end 
endmodule
