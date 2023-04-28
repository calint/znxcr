# znxcr
experimental retro 16 bit cpu written in verilog xilinix vivado intended for fpga board Arty S7-25

under construction

```
           zn-x-cr vintage 16 bit cpu

           | 0 | 1 | 2 | 3 | 4 | 5 - 7 | 8-11 | 12-15|
           |---|---|---|---|---|-------|------|------|
           | . | . | . | . | . | o p   | rega | regb |
           |---|---|---|---|---|-------|------|------|
           / Z / N / n / R / C / 0 0 0 / 0000 / .... /  loadi
          / e / e / e / e / a / 0 0 1 / 0000 / .... /  increment
         / r / g / X / t / l / 0 1 0 / 0000 / .... /  loop
        / o / a / t / u / l / 0 1 1 / 0000 / .... /  not
       / . / t / . / r / . / 0 1 1 / imm4 / .... /  shift
      / . / i / . / n / . / 1 0 0 / immediate 8 /  skip
     / . / v / . / . / . / 1 0 1 / .... / .... /  add
    / . / e / . / . / . / 1 1 0 / addr / dst  /  load
   / . / . / . / . / . / 1 1 1 / addr / src  /  store
  / . / . / . / . / 1 / immediate 10 << 4   /  call

    op :       :
   ----:-------:---------------------------------------------------
   000 : loadi : next instruction into register b
   001 : inc   : increment register b
   010 : loop  : starts loop with counter value set by register b
   011 : not   : register b if immediate value of 'rega' is 0
   011 : shift : register b by immediate 4 bit value of 'rega'
   100 : skip  : adds immediate 8 bit value to program counter
   101 : add   : register a to register b
   110 : load  : loads ram location of register b into register a
   111 : store : stores register a into ram location of register b

   page cr = 11

    op :       :
   ----:-------:--------------------------------------
   000 : copy  : copies register a into register b 
   001 :       : 
   010 :       :
   011 :       : 
   100 :       :
   101 :       : 
   110 :       :
   111 :       :
```
