# znxcr
experimental retro 16 bit cpu written in verilog xilinix vivado intended for fpga board Arty S7-25

under construction

```
                 n
                 e
             z n-x-c r   vintage 16 bit cpu
             e e t a e
             r g   l t
             o a   l u
               t     r
               i     n
               v
               e

             | 0 | 1 | 2 | 3 | 4 | 5 - 7 | 8-11 | 12-15|
             |---|---|---|---|---|-------|------|------|
             | z | n | x | r | c | o p   | rega | regb |
             |---|---|---|---|---|-------|------|------|
             / . / . / . / . / 0 / 0 0 0 / 0000 / .... /  loadi
            / . / . / . / . / 0 / 0 0 1 / imm4 / .... /  addi
           / 0 / 0 / 0 / 0 / 0 / 0 1 0 / 0000 / .... /  loop
          / . / . / . / . / 0 / 0 1 1 / 0000 / .... /  not
         / . / . / . / . / 0 / 0 1 1 / imm4 / .... /  shift
        / . / . / 0 / 0 / 0 / 1 0 0 / immediate 8 /  skip
       / . / . / . / . / 0 / 1 0 1 / .... / .... /  add
      / . / . / . / . / 0 / 1 1 0 / addr / dst  /  load
     / . / . / . / . / 0 / 1 1 1 / addr / src  /  store
    / . / . / . / 0 / 1 / immediate 10 << 4   /  call
   / . / . / . / 1 / 1 / 0 0 0 / .... / .... /  copy

    op :       :
   ----:-------:-------------------------------------------------------
   000 : loadi : load next instruction into register b
   001 : addi  : add immediate 4 bit signed value to register b
   010 : loop  : starts loop with counter value set by register b
   011 : not   : register b if immediate value of 'rega' is 0
   011 : shift : register b by immediate 4 bit signed value of 'rega'
   100 : skip  : adds immediate 8 bit value to program counter
   101 : add   : register a to register b
   110 : load  : loads ram location of register b into register a
   111 : store : stores register a into ram location of register b

   page cr = 11

    op :       :
   ----:-------:-------------------------------------------------------
   000 : copy  : copies register a into register b 
   001 :       : 
   010 :       :
   011 :       : 
   100 :       :
   101 :       : 
   110 :       :
   111 :       :
```
