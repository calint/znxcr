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

        // 1000 // 00: znxr c [loadi] reg[1]={data}
        #clk_tk;
        // 1234 // 01: {data}
        #clk_tk;
        
        if (dut.regs.mem[1] == 16'h1234) $display("case 1 passed");
        else $display("case 1 failed - Expected 0x1234, got %d", dut.regs.mem[1]);

        // 2000 // 02: znxr c [loadi] reg[2]={data}
        #clk_tk;
        // 0001 // 03: {data}
        #clk_tk;

        if (dut.regs.mem[2] == 16'h1) $display("case 2 passed");
        else $display("case 2 failed - Expected 1, got %d", dut.regs.mem[2]);

        // 12a0 // 04: znxr c [add] regs[1]+=regs[2]
        #clk_tk;

        if (dut.regs.mem[1] == 16'h1235) $display("case 3 passed");
        else $display("case 3 failed - Expected 0x1235, got %d", dut.regs.mem[1]);

        // 12a0 // 05: znxr c [add] regs[1]+=regs[2]
        #clk_tk;

        if (dut.regs.mem[1] == 16'h1236) $display("case 4 passed");
        else $display("case 4 failed - Expected 0x1236, got %d", dut.regs.mem[1]);

        // 1000 // 06: znxr c [loadi] reg[1]={data}
        #clk_tk;
        // 0004 // 07: {data}
        #clk_tk;

        if (dut.regs.mem[1] == 4) $display("case 5 passed");
        else $display("case 5 failed - Expected 4, got %d", dut.regs.mem[1]);

        // 1260 // 08: znxr c [shift] reg[1]>>=2
        #clk_tk;

        if (dut.regs.mem[1] == 1) $display("case 6 passed");
        else $display("case 6 failed - Expected 1, got %d", dut.regs.mem[1]);
        if (dut.zf == 0 && dut.nf == 0) $display("case 6.1 passed");
        else $display("case 6.1 failed - Expected 0,1, got %d,%d", dut.zf, dut.nf);
 
        // 1ec0 // 09: znxr c [shift] reg[1]<<=2
        #clk_tk;

        if (dut.regs.mem[1] == 4) $display("case 7 passed");
        else $display("case 7 failed - Expected 4, got %d", dut.regs.mem[1]);

        // 10c0 // 10: znxr c [not] reg[1]=~reg[1]
        #clk_tk;

        if (dut.regs.mem[1] == -5) $display("case 8 passed");
        else $display("case 8 failed - Expected -5, got %d", dut.regs.mem[1]);
        if (dut.zf == 0 && dut.nf == 1) $display("case 8.1 passed");
        else $display("case 8.1 failed - Expected 0,1, got %d,%d", dut.zf, dut.nf);

        // 1000 // 11: znxr c [loadi] reg[1]={data}
        #clk_tk
        // 0003 // 12: {data}
        #clk_tk
        if (dut.regs.mem[1] == 3) $display("case 9 passed");
        else $display("case 9 failed - Expected 1, got %d", dut.regs.mem[1]);

        // 2000 // 13: znxr c [loadi] reg[2]={data}
        #clk_tk
        // 0004 // 14: {data}        
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
        if (dut.pc == 22) $display("case 15 passed");
        else $display("case 15 failed - Expected 22, got %d", dut.pc);
        
        // ffff // 21: 
        // ffff // 22:
         
        // 41c0 // 23: znxr c [load] %4=ram[%1] (reg[4]=ram[4] => reg[4]==4)
        #clk_tk
        if (dut.regs.mem[4] == 4) $display("case 16 passed");
        else $display("case 16 failed - Expected 4, got %d", dut.regs.mem[4]);

        // 0090 // 24: znxr C [call] 32 => encoded (32>>2)|1==9
        #clk_tk
        if (dut.pc == 31) $display("case 17 passed");
        else $display("case 17 failed - Expected 31, got %d", dut.pc);

        // 51c0 // 32: znxr c [load] %5=ram[%1] (reg[5]=ram[4] => reg[5]==4)
        #clk_tk
        if (dut.regs.mem[5] == 4) $display("case 18 passed");
        else $display("case 18 failed - Expected 4, got %d", dut.regs.mem[5]);

        // 61c8 // 33: znxR c [load & return] %6=ram[%1] (reg[6]=ram[4] => reg[6]==4)
        #clk_tk
        if (dut.regs.mem[6] == 4) $display("case 19 passed");
        else $display("case 19 failed - Expected 4, got %d", dut.regs.mem[6]);       
        if (dut.pc == 24) $display("case 20 passed");
        else $display("case 20 failed - Expected 24, got %d", dut.pc);
        
        // check that zf and nf is popped. instruction 10: did set nf=1 zf=0
        if (dut.zf == 0 && dut.nf == 1) $display("case 24.1 passed");
        else $display("case 24.1 failed - Expected 0,1, got %d,%d", dut.zf, dut.nf);

        // 6040 // 25: znxr c [loop] %6 (reg[6]==4)
        #clk_tk
        
        if (dut.ls.pc_out == 25) $display("case 21 passed");
        else $display("case 21 failed - Expected 25, got %d", dut.ls.pc_out);
        if (!dut.ls.done) $display("case 22 passed");
        else $display("case 22 failed - Expected 0, got %d", dut.ls.done);
        
        // 6284 // 26: znXr c [addi & next] reg[6]+=2
        #clk_tk // => cnt==3
        
        if (dut.ls.pc_out == 25) $display("case 23 passed");
        else $display("case 23 failed - Expected 25, got %d", dut.ls.pc_out);
        if (dut.regs.mem[6] == 6) $display("case 24 passed");
        else $display("case 24 failed - Expected 6, got %d", dut.regs.mem[6]);
        if (!dut.ls.done) $display("case 25 passed");
        else $display("case 25 failed - Expected 0, got %d", dut.ls.done);
 
        #clk_tk // => cnt==2
        #clk_tk // => cnt==1, done==true
        #clk_tk // => cnt==0, next loop
        
        if (dut.pc == 26) $display("case 26 passed");
        else $display("case 26 failed - Expected 26, got %d", dut.pc);
        if (dut.regs.mem[6] == 12) $display("case 27 passed");
        else $display("case 27 failed - Expected 12, got %d", dut.regs.mem[6]);
        
        // 5000 // 27: znxr c [load] %5=1
        #clk_tk
        #clk_tk
        if (dut.regs.mem[5] == 1) $display("case 28 passed");
        else $display("case 28 failed - Expected 1, got %d", dut.regs.mem[5]);
        
        // 5f80 // 29: znxr c [addi] %5-=1
        #clk_tk
        if (dut.regs.mem[5] == 0) $display("case 29 passed");
        else $display("case 29 failed - Expected 9, got %d", dut.regs.mem[5]);
        
        // 0322 // 30: zNxr c [skip] 3 instructions
        #clk_tk
        if (dut.pc == 30) $display("case 30 passed");
        else $display("case 30 failed - Expected 30, got %d", dut.pc);
        
        // 0321 // 31: Znxr c [skip] 3 instructions
        #clk_tk
        if (dut.pc == 34) $display("case 31 passed");
        else $display("case 31 failed - Expected 34, got %d", dut.pc);
        
        // 5f83 // 35: znxr c [addi] %5-=1
        #clk_tk
        // 0122 // 36: zNxr c [skip] 1
        #clk_tk
        if (dut.pc == 37) $display("case 32 passed");
        else $display("case 32 failed - Expected 37, got %d", dut.pc);
        
        // 0000 // 37: 
        // 5280 // 38: znxr c [addi] %5+=2
        #clk_tk
        if (dut.regs.mem[5] == 1) $display("case 33 passed");
        else $display("case 33 failed - Expected 1, got %d", dut.regs.mem[5]);
        
        // 0123 // 39: ZNxr c [skip] 1
        #clk_tk
        if (dut.pc == 41) $display("case 34 passed");
        else $display("case 34 failed - Expected 40, got %d", dut.pc);

        // 0000 // 40: 
        // 7000 // 41: znxr c [load] %7=-1
        // ffff // 42: {data -1} 

        
        // 0000 // 33: 

        $finish;
    end
endmodule
