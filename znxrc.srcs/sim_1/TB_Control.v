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
        
        #clk_tk // 1003 // 00: loadi r1
        #clk_tk // 1234 // 01: 0x1234
        if (dut.regs.mem[1] == 16'h1234) $display("case 1 passed");
        else $display("case 1 failed - expected 0x1234, got %d", dut.regs.mem[1]);

        #clk_tk // 2003 // 02: loadi r2
        #clk_tk // 0001 // 03: 0x0001
        if (dut.regs.mem[2] == 16'h1) $display("case 2 passed");
        else $display("case 2 failed - expected 1, got %d", dut.regs.mem[2]);

        #clk_tk // 12a3 // 04: add r1 r2
        if (dut.regs.mem[1] == 16'h1235) $display("case 3 passed");
        else $display("case 3 failed - expected 0x1235, got %d", dut.regs.mem[1]);

        #clk_tk // 12a3 // 05: add r1 r2
        if (dut.regs.mem[1] == 16'h1236) $display("case 4 passed");
        else $display("case 4 failed - expected 0x1236, got %d", dut.regs.mem[1]);

        #clk_tk // 1003 // 06: loadi
        #clk_tk // 0004 // 07: 0x0004
        if (dut.regs.mem[1] == 4) $display("case 5 passed");
        else $display("case 5 failed - expected 4, got %d", dut.regs.mem[1]);

        #clk_tk // 12c3 // 08: shift r1 2
        if (dut.regs.mem[1] == 1) $display("case 6 passed");
        else $display("case 6 failed - expected 1, got %d", dut.regs.mem[1]);
        if (dut.zf == 0 && dut.nf == 0) $display("case 6.1 passed");
        else $display("case 6.1 failed - expected 0,1, got %d,%d", dut.zf, dut.nf);
 
        #clk_tk // 1ec3 // 09: shift r1 -2
        if (dut.regs.mem[1] == 4) $display("case 7 passed");
        else $display("case 7 failed - expected 4, got %d", dut.regs.mem[1]);

        #clk_tk // 10c3 // 10: not r1
        if (dut.regs.mem[1] == -5) $display("case 8 passed");
        else $display("case 8 failed - expected -5, got %d", dut.regs.mem[1]);
        if (dut.zf == 0 && dut.nf == 1) $display("case 8.1 passed");
        else $display("case 8.1 failed - expected 0,1, got %d,%d", dut.zf, dut.nf);

        #clk_tk // 1003 // 11: loadi r1
        #clk_tk // 0003 // 12: 0x003
        if (dut.regs.mem[1] == 3) $display("case 9 passed");
        else $display("case 9 failed - expected 1, got %d", dut.regs.mem[1]);

        #clk_tk // 2003 // 13: loadi r2
        #clk_tk // 0004 // 14: 0x004
        if (dut.regs.mem[2] == 4) $display("case 10 passed");
        else $display("case 10 failed - expected 2, got %d", dut.regs.mem[2]);

        #clk_tk // 12e3 // 15: store r2 r1 ; ram[4] => 3
        if (dut.ram.mem[4] == 3) $display("case 11 passed");
        else $display("case 11 failed - expected 3, got %d", dut.ram.mem[4]);
        
        #clk_tk // 1003 // 16: loadi r2
        #clk_tk // 0004 // 17: 0x004
        if (dut.regs.mem[1] == 4) $display("case 12 passed");
        else $display("case 12 failed - expected 4, got %d", dut.regs.mem[1]);

        #clk_tk // 21e3 // 18: store r1 r2 ; ram[4] => 4
        if (dut.ram.mem[4] == 4) $display("case 13 passed");
        else $display("case 11 failed - expected 4, got %d", dut.ram.mem[4]);
        
        #clk_tk // 3163 // 19: load r3 r1  ; ram[4] => 4
        if (dut.regs.mem[3] == 4) $display("case 14 passed");
        else $display("case 14 failed - expected 4, got %d", dut.regs.mem[3]);
        
        #clk_tk // 0223 // 20: skip 2
        if (dut.pc == 22) $display("case 15 passed");
        else $display("case 15 failed - expected 22, got %d", dut.pc);
        
        // ffff // 21: 
        // ffff // 22: 
         
        #clk_tk // 4163 // 23: load r4 r1 ; r4=ram[4] => 4
        if (dut.regs.mem[4] == 4) $display("case 16 passed");
        else $display("case 16 failed - expected 4, got %d", dut.regs.mem[4]);

        #clk_tk // 0093 // 24: call 32 ; encoded (32>>2)|1 => 9
        if (dut.pc == 31) $display("case 17 passed");
        else $display("case 17 failed - expected 31, got %d", dut.pc);

        #clk_tk // 5163 // 32: load r5 r1 ; ram[4] => 4
        if (dut.regs.mem[5] == 4) $display("case 18 passed");
        else $display("case 18 failed - expected 4, got %d", dut.regs.mem[5]);

        #clk_tk // 616b // 33: load r6 r1 return ; ram[4] => 4
        if (dut.regs.mem[6] == 4) $display("case 19 passed");
        else $display("case 19 failed - expected 4, got %d", dut.regs.mem[6]);       
        if (dut.pc == 24) $display("case 20 passed");
        else $display("case 20 failed - expected 24, got %d", dut.pc);
        // check that zf and nf is popped. instruction 10: did set nf=1 zf=0
        if (dut.zf == 0 && dut.nf == 1) $display("case 24.1 passed");
        else $display("case 24.1 failed - expected 0,1, got %d,%d", dut.zf, dut.nf);

        #clk_tk // 6040 // 25: loop r6 ; r6 => 4
        if (dut.ls.pc_out == 25) $display("case 21 passed");
        else $display("case 21 failed - expected 25, got %d", dut.ls.pc_out);
        if (!dut.ls.done) $display("case 22 passed");
        else $display("case 22 failed - expected 0, got %d", dut.ls.done);
        
        #clk_tk // 6287 // 26: addi r6 2 next
        // => cnt==3
        if (dut.ls.pc_out == 25) $display("case 23 passed");
        else $display("case 23 failed - expected 25, got %d", dut.ls.pc_out);
        if (dut.regs.mem[6] == 6) $display("case 24 passed");
        else $display("case 24 failed - expected 6, got %d", dut.regs.mem[6]);
        if (!dut.ls.done) $display("case 25 passed");
        else $display("case 25 failed - expected 0, got %d", dut.ls.done);
 
        #clk_tk
        // => cnt==2
        #clk_tk
        // => cnt==1, done==true
        #clk_tk
        // => cnt==0, next loop
        
        if (dut.pc == 26) $display("case 26 passed");
        else $display("case 26 failed - expected 26, got %d", dut.pc);
        if (dut.regs.mem[6] == 12) $display("case 27 passed");
        else $display("case 27 failed - expected 12, got %d", dut.regs.mem[6]);
        
        #clk_tk // 5003 // 27: load r5
        #clk_tk // 0001 // 28: 0x0001
        if (dut.regs.mem[5] == 1) $display("case 28 passed");
        else $display("case 28 failed - expected 1, got %d", dut.regs.mem[5]);
        
        #clk_tk // 5f83 // 29: addi r5 -1
        if (dut.regs.mem[5] == 0) $display("case 29 passed");
        else $display("case 29 failed - expected 9, got %d", dut.regs.mem[5]);
        if (dut.zf == 1 && dut.nf == 0) $display("case 29.1 passed");
        else $display("case 29.1 failed - expected 1,0, got %d,%d", dut.zf, dut.nf);
        
        #clk_tk // 0322 // 30: ifn skip 3
        if (dut.pc == 30) $display("case 30 passed");
        else $display("case 30 failed - expected 30, got %d", dut.pc);
        
        #clk_tk // 0321 // 31: ifz skip 3
        if (dut.pc == 34) $display("case 31 passed");
        else $display("case 31 failed - expected 34, got %d", dut.pc);
        
        #clk_tk // 5f83 // 35: addi r5 -1
        #clk_tk // 0122 // 36: ifn skip 1
        if (dut.pc == 37) $display("case 32 passed");
        else $display("case 32 failed - expected 37, got %d", dut.pc);
        
        #clk_tk // 5283 // 38: addi r5 2
        if (dut.regs.mem[5] == 1) $display("case 33 passed");
        else $display("case 33 failed - expected 1, got %d", dut.regs.mem[5]);
        
        #clk_tk // 0220 // 39: ifp skip 2
        if (dut.pc == 41) $display("case 34 passed");
        else $display("case 34 failed - expected 40, got %d", dut.pc);

        // 0000 // 40:
        // 0000 // 41: 
        // 7003 // 42: load r7
        // ffff // 43: 0xffff 
        // 0000 // 44:
        // 0000 // 45:
        // 0000 // 46:
        // 0000 // 47:
        
        $finish;
    end
endmodule
