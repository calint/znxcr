`timescale 1ns / 1ps
`default_nettype none
//`define DBG

module TB_Control;

reg clk = 0;
parameter clk_tk = 10;
always #(clk_tk/2) clk = ~clk;

reg rst = 1;
wire [3:0] led;

Control dut(
    .rst(rst),
    .clk(clk),
    .led(led)
);

initial begin
    rst = 1;
    #100 // https://docs.xilinx.com/r/en-US/ug900-vivado-logic-simulation/Using-Test-Benches-and-Stimulus-Files
    rst = 0;

    #clk_tk // 1058 // 00: loadi r1
    #clk_tk // 1234 // 01: 0x1234
    if (dut.regs.mem[1] == 16'h1234) $display("case 1 passed");
    else $display("case 1 failed - expected 0x1234, got %d", dut.regs.mem[1]);

    #clk_tk // 2058 // 02: loadi r2
    #clk_tk // 0001 // 03: 0x0001
    if (dut.regs.mem[2] == 16'h1) $display("case 2 passed");
    else $display("case 2 failed - expected 1, got %d", dut.regs.mem[2]);

    #clk_tk // 12a3 // 04: add r1 r2
    if (dut.regs.mem[1] == 16'h1235) $display("case 3 passed");
    else $display("case 3 failed - expected 0x1235, got %d", dut.regs.mem[1]);

    #clk_tk // 12a3 // 05: add r1 r2
    if (dut.regs.mem[1] == 16'h1236) $display("case 4 passed");
    else $display("case 4 failed - expected 0x1236, got %d", dut.regs.mem[1]);

    #clk_tk // 1058 // 06: loadi r1
    #clk_tk // 0004 // 07: 0x0004
    if (dut.regs.mem[1] == 4) $display("case 5 passed");
    else $display("case 5 failed - expected 4, got %d", dut.regs.mem[1]);

    #clk_tk // 12c3 // 08: shift r1 2
    if (dut.regs.mem[1] == 1) $display("case 6 passed");
    else $display("case 6 failed - expected 1, got %d", dut.regs.mem[1]);
    if (dut.zn_zf == 0 && dut.zn_nf == 0) $display("case 6.1 passed");
    else $display("case 6.1 failed - expected 0,1, got %d,%d", dut.zn_zf, dut.zn_nf);

    #clk_tk // 1ec3 // 09: shift r1 -2
    if (dut.regs.mem[1] == 4) $display("case 7 passed");
    else $display("case 7 failed - expected 4, got %d", dut.regs.mem[1]);

    #clk_tk // 10c3 // 10: not r1
    if (dut.regs.mem[1] == -5) $display("case 8 passed");
    else $display("case 8 failed - expected -5, got %d", dut.regs.mem[1]);
    if (dut.zn_zf == 0 && dut.zn_nf == 1) $display("case 8.1 passed");
    else $display("case 8.1 failed - expected 0,1, got %d,%d", dut.zn_zf, dut.zn_nf);

    #clk_tk // 1058 // 11: loadi r1
    #clk_tk // 0003 // 12: 0x003
    if (dut.regs.mem[1] == 3) $display("case 9 passed");
    else $display("case 9 failed - expected 1, got %d", dut.regs.mem[1]);

    #clk_tk // 2058 // 13: loadi r2
    #clk_tk // 0004 // 14: 0x004
    if (dut.regs.mem[2] == 4) $display("case 10 passed");
    else $display("case 10 failed - expected 2, got %d", dut.regs.mem[2]);

    #clk_tk // 12e3 // 15: store r2 r1 ; ram[4] => 3
    if (dut.ram.mem[4] == 3) $display("case 11 passed");
    else $display("case 11 failed - expected 3, got %d", dut.ram.mem[4]);
    
    #clk_tk // 1058 // 16: loadi r2
    #clk_tk // 0004 // 17: 0x004
    if (dut.regs.mem[1] == 4) $display("case 12 passed");
    else $display("case 12 failed - expected 4, got %d", dut.regs.mem[1]);

    #clk_tk // 21e3 // 18: store r1 r2 ; ram[4] => 4
    if (dut.ram.mem[4] == 4) $display("case 13 passed");
    else $display("case 11 failed - expected 4, got %d", dut.ram.mem[4]);
    
    #clk_tk // 3163 // 19: load r3 r1  ; ram[4] => 4
    if (dut.regs.mem[3] == 4) $display("case 14 passed");
    else $display("case 14 failed - expected 4, got %d", dut.regs.mem[3]);
    
    #clk_tk // 023b // 20: skip 2
    if (dut.pc_nxt == 23) $display("case 15 passed");
    else $display("case 15 failed - expected 23, got %d", dut.pc_nxt);
    
    // ffff // 21: 
    // ffff // 22: 
        
    #clk_tk // 4163 // 23: load r4 r1 ; r4=ram[4] => 4
    if (dut.regs.mem[4] == 4) $display("case 16 passed");
    else $display("case 16 failed - expected 4, got %d", dut.regs.mem[4]);

    #clk_tk // 0093 // 24: call 32 ; encoded (32>>2)|1 => 0x9
    if (dut.pc_nxt == 32) $display("case 17 passed");
    else $display("case 17 failed - expected 32, got %d", dut.pc_nxt);
    // select the lower 8-bits since the width is a parameter most likely higher than 8
    if (dut.cs.mem[0][7:0] == 24) $display("case 17.1 passed");
    else $display("case 17.1 failed - expected 24, got %d", dut.cs.mem[0][7:0]);

    #clk_tk // 5163 // 32: load r5 r1 ; ram[4] => 4
    if (dut.regs.mem[5] == 4) $display("case 18 passed");
    else $display("case 18 failed - expected 4, got %d", dut.regs.mem[5]);
    if (dut.zn_zf == 0 && dut.zn_nf == 0) $display("case 18.1 passed");
    else $display("case 18.1 failed - expected 0,0, got %d,%d", dut.zn_zf, dut.zn_nf);


    #clk_tk // 616b // 33: load r6 r1 return ; ram[4] => 4
    if (dut.regs.mem[6] == 4) $display("case 19 passed");
    else $display("case 19 failed - expected 4, got %d", dut.regs.mem[6]);       
    if (dut.pc_nxt == 25) $display("case 20 passed");
    else $display("case 20 failed - expected 25, got %d", dut.pc_nxt);
    // check that zf and nf is popped. instruction 10: did set nf=1 zf=0
    if (dut.zn_zf == 0 && dut.zn_nf == 1) $display("case 20.1 passed");
    else $display("case 20.1 failed - expected 0,1, got %d,%d", dut.zn_zf, dut.zn_nf);

    #clk_tk // 601b // 25: loop r6 ; r6 => 4
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

    #clk_tk // => cnt==2
    #clk_tk // => cnt==1, done==true
    #clk_tk // => cnt==0, next loop
    
    if (dut.pc_nxt == 27) $display("case 26 passed");
    else $display("case 26 failed - expected 27, got %d", dut.pc_nxt);
    if (dut.regs.mem[6] == 12) $display("case 27 passed");
    else $display("case 27 failed - expected 12, got %d", dut.regs.mem[6]);
    
    #clk_tk // 5058 // 27: loadi r5
    #clk_tk // 0001 // 28: 0x0001
    if (dut.regs.mem[5] == 1) $display("case 28 passed");
    else $display("case 28 failed - expected 1, got %d", dut.regs.mem[5]);
    
    #clk_tk // 5f83 // 29: addi r5 -1
    if (dut.regs.mem[5] == 0) $display("case 29 passed");
    else $display("case 29 failed - expected 9, got %d", dut.regs.mem[5]);
    if (dut.zn_zf == 1 && dut.zn_nf == 0) $display("case 29.1 passed");
    else $display("case 29.1 failed - expected 1,0, got %d,%d", dut.zn_zf, dut.zn_nf);
    
    #clk_tk // 033a // 30: ifn skip 3
    if (dut.pc_nxt == 31) $display("case 30 passed");
    else $display("case 30 failed - expected 31, got %d", dut.pc_nxt);
    
    #clk_tk // 0339 // 31: ifz skip 3
    if (dut.pc_nxt == 35) $display("case 31 passed");
    else $display("case 31 failed - expected 35, got %d", dut.pc_nxt);
    
    #clk_tk // 5f83 // 35: addi r5 -1
    #clk_tk // 013a // 36: ifn skip 1
    if (dut.pc_nxt == 38) $display("case 32 passed");
    else $display("case 32 failed - expected 38, got %d", dut.pc_nxt);
    
    #clk_tk // 5283 // 38: addi r5 2
    if (dut.regs.mem[5] == 1) $display("case 33 passed");
    else $display("case 33 failed - expected 1, got %d", dut.regs.mem[5]);
    
    #clk_tk // 0238 // 39: ifp skip 2
    if (dut.pc_nxt == 42) $display("case 34 passed");
    else $display("case 34 failed - expected 42, got %d", dut.pc_nxt);

    // 0000 // 40:
    // 0000 // 41: 
    #clk_tk // 7003 // 42: load r7
    #clk_tk // ffff // 43: 0xffff
        
    #clk_tk // 8741 // 44: ifz copy r7 r8
    if (dut.regs.mem[8] !== -1) $display("case 35 passed");
    else $display("case 35 failed - expected not -1, got %d", dut.regs.mem[8]);

    #clk_tk // 8740 // 45: ifp copy r7 r8
    if (dut.regs.mem[8] == -1) $display("case 36 passed");
    else $display("case 36 failed - expected -1, got %d", dut.regs.mem[8]);

    if (dut.zn_zf == 0 && dut.zn_nf == 1) $display("case 37 passed");
    else $display("case 37 failed - expected 0,1, got %d,%d", dut.zn_zf, dut.zn_nf);
    #clk_tk // 00d3 // 46: call 52 ; encoded (48>>2)|1 => 0xd
    if (dut.pc_nxt == 48) $display("case 37.1 passed");
    else $display("case 37.1 failed - expected 48, got %d", dut.pc_nxt);
    
    #clk_tk // 1058 // 48: loadi r1
    #clk_tk // 0002 // 49: 0x002
    #clk_tk // 101b // 50: loop r1
    #clk_tk // 1f8f // 51: addi r1 -1 next return (cnt==2)
    if (dut.pc_nxt == 51) $display("case 38 passed");
    else $display("case 38 failed - expected 51, got %d", dut.pc_nxt);
    if (dut.regs.mem[1] == 1) $display("case 39 passed");
    else $display("case 39 failed - expected 1, got %d", dut.regs.mem[1]);
    
    #clk_tk // 1f8f // 51: addi r1 -1 next return (cnt==1)
    if (dut.pc_nxt == 47) $display("case 40 passed");
    else $display("case 40 failed - expected 47, got %d", dut.pc_nxt);
    if (dut.regs.mem[1] == 0) $display("case 41 passed");
    else $display("case 41 failed - expected 0, got %d", dut.regs.mem[1]);
        // check that zf and nf are same as before the call, see 'case 37'   
    if (dut.zn_zf == 0 && dut.zn_nf == 1) $display("case 42 passed");
    else $display("case 42 failed - expected 0,1, got %d,%d", dut.zn_zf, dut.zn_nf);
    
    #clk_tk // 063b // 47: skip 6
    if (dut.pc_nxt == 54) $display("case 42.1 passed");
    else $display("case 42.1 failed - expected 54, got %d", dut.pc_nxt);
    
    #clk_tk // 2058 // 54: loadi r2
    #clk_tk // 0001 // 55: 0x001
    #clk_tk // 3058 // 56: loadi r3
    #clk_tk // 0002 // 57: 0x002
    #clk_tk // 3223 // 58: sub r2 r3 (r3-=r2)
    if (dut.regs.mem[3] == 1) $display("case 43 passed");
    else $display("case 43 failed - expected 1, got %d", dut.regs.mem[3]);

    #clk_tk // 301b // 59: loop r3 ; r3==1
    #clk_tk // 3f83 // 60: addi r3 -1 next
    if (dut.pc_nxt == 61) $display("case 44 passed");
    else $display("case 44 failed - expected 61, got %d", dut.pc_nxt);
    if ($signed(dut.ls.idx) == -1) $display("case 45 passed");
    else $display("case 45 failed - expected -1, got %d", $signed(dut.ls.idx));
    if ($signed(dut.cs.idx) == -1) $display("case 46 passed");
    else $display("case 46 failed - expected -1, got %d", $signed(dut.cs.idx));

    #clk_tk // 305a // 61: ifn loadi r3
    #clk_tk // 0002 // 62: 0x002
    if (dut.regs.mem[3] == 0) $display("case 47 passed");
    else $display("case 47 failed - expected 0, got %d", dut.regs.mem[3]);

    #clk_tk // 201a // 63: ifn loop r2 ; r2==1, zf, !nf
    if ($signed(dut.ls.idx) == -1) $display("case 48 passed");
    else $display("case 48 failed - expected -1, got %d", $signed(dut.ls.idx));

    #clk_tk // 2019 // 64: ifz loop r2 ; r2==1, zf, nf
    if (dut.ls.done) $display("case 49 passed");
    else $display("case 49 failed - expected 0, got %d", dut.ls.done);
    
    #clk_tk // 2f83 // 65: addi r2 -1 next
    if (dut.regs.mem[2] == 0) $display("case 50 passed");
    else $display("case 50 failed - expected 0, got %d", dut.regs.mem[2]);

    #clk_tk // 0132 // 66: ifn call 72 ; encoded (72>>2)|1 => 0x13
    if (dut.pc_nxt == 67) $display("case 51 passed");
    else $display("case 51 failed - expected 67, got %d", dut.pc_nxt);
    
    #clk_tk // 01311 // 67: ifz call 72 ; encoded (72>>2)|1 => 0x13
    if (dut.pc_nxt == 72) $display("case 51 passed");
    else $display("case 51 failed - expected 72, got %d", dut.pc_nxt);

    #clk_tk // 0153 // 72: call 80 ; encoded (80>>2)|1 => 0x15
    if (dut.pc_nxt == 80) $display("case 52 passed");
    else $display("case 52 failed - expected 80, got %d", dut.pc_nxt);
    if (dut.cs.idx == 1) $display("case 53 passed");
    else $display("case 53 failed - expected 1, got %d", dut.cs.idx);

    #clk_tk // 008b // 80: addi r0 0 return
    if (dut.pc_nxt == 73) $display("case 54 passed");
    else $display("case 54 failed - expected 73, got %d", dut.pc_nxt);
    if (dut.cs.idx == 0) $display("case 55 passed");
    else $display("case 55 failed - expected 0, got %0d", dut.cs.idx);
    
    #clk_tk // 008b // 73: addi r0 0 return
    if (dut.pc_nxt == 68) $display("case 56 passed");
    else $display("case 56 failed - expected 68, got %0d", dut.pc_nxt);
    
    #clk_tk // 0c3b // 68: skip 12
    if (dut.pc_nxt == 81) $display("case 57 passed");
    else $display("case 57 failed - expected 81, got %0d", dut.pc_nxt);
    
    #clk_tk // a05b // 81: loadi r10
    #clk_tk // 0003 // 82: 0x0003
    #clk_tk // b05b // 83: loadi r11
    #clk_tk // 0003 // 84: 0x0003
    #clk_tk // 4403 // 85: xor r4 r4 (r4==4)
    if (dut.regs.mem[4] == 0) $display("case 58 passed");
    else $display("case 58 failed - expected 0, got %0d", dut.regs.mem[4]);

    #clk_tk // 2203 // 86: xor r2 r2
    #clk_tk // a01b // 87: loop r10

    #clk_tk // b01b // 88: loop r11
    // loop r11: cnt==3
    #clk_tk // 1187 // 89: addi r1 1 next
    // loop r11: cnt==2
    #clk_tk // 1187 // 89: addi r1 1 next
    // loop r11: cnt==1, last iteration
    #clk_tk // 1187 // 89: addi r1 1 next
    // loop r10: cnt==2
    #clk_tk // 2f87 // 90: addi r2 -1 next

    #clk_tk // b01b // 88: loop r11
    // loop r11: cnt==3
    #clk_tk // 1187 // 89: addi r1 1 next
    // loop r11: cnt==2
    #clk_tk // 1187 // 89: addi r1 1 next
    // loop r11: cnt==1, last iteration
    #clk_tk // 1187 // 89: addi r1 1 next
    // loop r10: cnt==2
    #clk_tk // 2f87 // 90: addi r2 -1 next

    #clk_tk // b01b // 88: loop r11
    // loop r11: cnt==3
    #clk_tk // 1187 // 89: addi r1 1 next
    // loop r11: cnt==2
    #clk_tk // 1187 // 89: addi r1 1 next
    // loop r11: cnt==1, last iteration
    #clk_tk // 1187 // 89: addi r1 1 next
    #clk_tk // 2f87 // 90: addi r2 -1 next

    if (dut.regs.mem[1] == 9) $display("case 59 passed");
    else $display("case 59 failed - expected 9, got %0d", dut.regs.mem[1]);
    if (dut.regs.mem[2] == -3) $display("case 60 passed");
    else $display("case 60 failed - expected -3, got %0d", dut.regs.mem[2]);
    if (dut.pc_nxt == 91) $display("case 61 passed");
    else $display("case 61 failed - expected 91, got %0d", dut.pc_nxt);
    if ($signed(dut.ls.idx) == -1) $display("case 62 passed");
    else $display("case 62 failed - expected -1, got %0d", $signed(dut.ls.idx));

    #clk_tk // a01b // 91: loop r10

    #clk_tk // b01b // 92: loop r11
    #clk_tk // 1183 // 93: addi r1 1
    #clk_tk // 1187 // 94: addi r1 1 next
    #clk_tk // 1183 // 93: addi r1 1
    #clk_tk // 1187 // 94: addi r1 1 next
    #clk_tk // 1183 // 93: addi r1 1
    #clk_tk // 1187 // 94: addi r1 1 next

    #clk_tk // 2f87 // 95: addi r2 -1 next

    #clk_tk // b01b // 92: loop r11
    #clk_tk // 1183 // 93: addi r1 1
    #clk_tk // 1187 // 94: addi r1 1 next
    #clk_tk // 1183 // 93: addi r1 1
    #clk_tk // 1187 // 94: addi r1 1 next
    #clk_tk // 1183 // 93: addi r1 1
    #clk_tk // 1187 // 94: addi r1 1 next

    #clk_tk // 2f87 // 95: addi r2 -1 next

    #clk_tk // b01b // 92: loop r11
    #clk_tk // 1183 // 93: addi r1 1
    #clk_tk // 1187 // 94: addi r1 1 next
    #clk_tk // 1183 // 93: addi r1 1
    #clk_tk // 1187 // 94: addi r1 1 next
    #clk_tk // 1183 // 93: addi r1 1
    #clk_tk // 1187 // 94: addi r1 1 next

    #clk_tk // 2f87 // 95: addi r2 -1 next

    if (dut.regs.mem[1] == 27) $display("case 63 passed");
    else $display("case 63 failed - expected 27, got %0d", dut.regs.mem[1]);
    if (dut.regs.mem[2] == -6) $display("case 64 passed");
    else $display("case 64 failed - expected -6, got %0d", dut.regs.mem[2]);
    if (dut.pc_nxt == 96) $display("case 65 passed");
    else $display("case 65 failed - expected 96, got %0d", dut.pc_nxt);
    if ($signed(dut.ls.idx) == -1) $display("case 66 passed");
    else $display("case 66 failed - expected -1, got %0d", $signed(dut.ls.idx));

    #clk_tk // ff3b // 96: skip -1 ; skips -1+1==0 => hangs
    if (dut.pc_nxt == 96) $display("case 67 passed");
    else $display("case 67 failed - expected 96, got %0d", dut.pc_nxt);
 
    $finish;
end

endmodule

`default_nettype wire

