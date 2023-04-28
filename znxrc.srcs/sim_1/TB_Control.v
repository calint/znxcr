`timescale 1ns / 1ps

module TB_Control;
    reg clk = 0;
    parameter clk_tk = 10;
    always #(clk_tk/2) clk = ~clk;

    reg rst = 1;

    Control dut(
        .rst(rst),
        .clk(clk)
    );

    initial begin
        #clk_tk;
        rst = 0;

//        instruction = 16'h1000; // znxr c [load register] 1 with data
        #clk_tk;
//        instruction = 16'h1234; // data
        #clk_tk;
        
        if (dut.regs.mem[1] == 16'h1234) $display("case 1 passed");
        else $display("case 1 failed - Expected 0x1234, got %d", dut.regs.mem[1]);

//        instruction = 16'h2000; // znxr c [load register] 2 with data
        #clk_tk;
//        instruction = 16'h0001; // data
        #clk_tk;

        if (dut.regs.mem[2] == 16'h1) $display("case 2 passed");
        else $display("case 2 failed - Expected 1, got %d", dut.regs.mem[2]);

//        instruction = 16'h12a0; // znxr c [add] register 2 to register 1
        #clk_tk;

        if (dut.regs.mem[1] == 16'h1235) $display("case 3 passed");
        else $display("case 3 failed - Expected 0x1235, got %d", dut.regs.mem[1]);

//        instruction = 16'h12a0; // znxr c [add] register 1 to register 2
        #clk_tk;

        if (dut.regs.mem[1] == 16'h1236) $display("case 4 passed");
        else $display("case 4 failed - Expected 0x1236, got %d", dut.regs.mem[1]);

//        instruction = 16'h1000; // znxr c [load register] 1 with data
        #clk_tk;
//        instruction = 16'h0004; // data
        #clk_tk;

        if (dut.regs.mem[1] == 4) $display("case 5 passed");
        else $display("case 5 failed - Expected 4, got %d", dut.regs.mem[1]);

//        instruction = 16'h1260; // znxr c [right shift] register 1 by 2
        #clk_tk;

        if (dut.regs.mem[1] == 1) $display("case 6 passed");
        else $display("case 6 failed - Expected 1, got %d", dut.regs.mem[1]);
 
//        instruction = 16'h1e60; // znxr c [lef shift] register 1 by 2
        #clk_tk;

        if (dut.regs.mem[1] == 4) $display("case 7 passed");
        else $display("case 7 failed - Expected 4, got %d", dut.regs.mem[1]);

//        instruction = 16'h1060; // znxr c [not] register 1
        #clk_tk;

        if (dut.regs.mem[1] == -5) $display("case 8 passed");
        else $display("case 8 failed - Expected -5, got %d", dut.regs.mem[1]);

        // 1000 // znxr c [load register] 1 with data
        #clk_tk
        // 0003 // data
        #clk_tk
        if (dut.regs.mem[1] == 3) $display("case 9 passed");
        else $display("case 9 failed - Expected 1, got %d", dut.regs.mem[1]);

        // 2000 // znxr c [load register] 2 with data
        #clk_tk
        // 0004 // data        
        #clk_tk
        if (dut.regs.mem[2] == 4) $display("case 10 passed");
        else $display("case 10 failed - Expected 2, got %d", dut.regs.mem[2]);

        // 12e0 // 15: znxr c [store] ram[%2]=%1 (ram[4]=3)
        #clk_tk
        if (dut.ram.mem[4] == 3) $display("case 11 passed");
        else $display("case 11 failed - Expected 3, got %d", dut.ram.mem[4]);
        
        // 1000 // 16: znxr c [loadi] reg[2]={data}
        #clk_tk
        // 0004 // 17: {data}
        #clk_tk
        if (dut.regs.mem[1] == 4) $display("case 12 passed");
        else $display("case 12 failed - Expected 4, got %d", dut.regs.mem[1]);

        // 21e0 // 18: znxr c [store] ram[%1]=%2 (ram[4]=4)
        #clk_tk
        if (dut.ram.mem[4] == 4) $display("case 13 passed");
        else $display("case 11 failed - Expected 4, got %d", dut.ram.mem[4]);
        
        // 31c0 // 19: znxr c [load] %3=ram[%1] (reg[3]=ram[4] => reg[3]==4)
        #clk_tk
        if (dut.regs.mem[3] == 4) $display("case 14 passed");
        else $display("case 14 failed - Expected 4, got %d", dut.regs.mem[3]);
        
        // 0280 // 20: znxr c [skip] 2 instructions
        #clk_tk
        if (dut.pc == 23) $display("case 15 passed");
        else $display("case 15 failed - Expected 23, got %d", dut.pc);
        
        // ffff // 21: 
        // ffff // 22:
         
        // 41c0 // 23: znxr c [load] %4=ram[%1] (reg[4]=ram[4] => reg[4]==4)
        #clk_tk
        if (dut.regs.mem[4] == 4) $display("case 16 passed");
        else $display("case 16 failed - Expected 4, got %d", dut.regs.mem[4]);

        // 0090 // 24: znxr C [call] 32 => encoded (32>>2)|1==9
        #clk_tk
        if (dut.pc == 32) $display("case 17 passed");
        else $display("case 17 failed - Expected 32, got %d", dut.pc);

        // 0000 // 25: 
        // 0000 // 26: 
        // 0000 // 27: 
        // 0000 // 28: 
        // 0000 // 29: 
        // 0000 // 30: 
        // 0000 // 31: 
        
        // 51c0 // 32: znxr c [load] %5=ram[%1] (reg[5]=ram[4] => reg[5]==4)
        #clk_tk
        if (dut.regs.mem[5] == 4) $display("case 18 passed");
        else $display("case 18 failed - Expected 4, got %d", dut.regs.mem[5]);

        // 61c8 // 33: znxR c [load & return] %6=ram[%1] (reg[6]=ram[4] => reg[6]==4)
        #clk_tk
        if (dut.regs.mem[6] == 4) $display("case 19 passed");
        else $display("case 19 failed - Expected 4, got %d", dut.regs.mem[6]);
        
        if (dut.pc == 25) $display("case 20 passed");
        else $display("case 20 failed - Expected 25, got %d", dut.pc);
        
        // 0000 // 33: 

        $finish;
    end
endmodule
