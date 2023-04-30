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
                 / . / . / . / . / 0 / 0 0 0 / .... / .... /  
                / . / . / . / . / 0 / 0 0 1 / imm4 / .... /  addi
               / . / . / . / . / 0 / 0 1 0 / src  / dst  /  copy
              / . / . / . / . / 0 / 0 1 1 / 0000 / .... /  not
             / . / . / . / . / 0 / 0 1 1 / imm4 / .... /  shift
            / . / . / . / . / 0 / 1 0 0 / ...  / .... /  
           / . / . / . / . / 0 / 1 0 1 / .... / .... /  add
          / . / . / . / . / 0 / 1 1 0 / addr / dst  /  load
         / . / . / . / . / 0 / 1 1 1 / addr / src  /  store
        / . / . / . / 0 / 1 / immediate 11 << 3   /  call
       / 0 / 0 / 0 / 1 / 1 / 0 0 0 / 0000 / .... /  loop
      / . / . / 0 / 1 / 1 / 0 0 1 / immediate 8 /  skip
     / . / . / . / 1 / 1 / 0 1 0 / 0000 / .... /  loadi

    op :       :
   ----:-------:-----------------------------------------------------
   000 : loadi : reg[b]={next instruction}
   001 : addi  : reg[b]+=imm4
   010 : loop  : start loop with counter value from reg[b]
   011 : not   : reg[b]=~reg[b]
   011 : shift : reg[b]>>=imm4 (negative imm4 means 'left')
   100 : skip  : pc+=imm8+1
   101 : add   : reg[b]+=reg[a]
   110 : load  : reg[b]=ram[a]
   111 : store : ram[a]=reg[b]

   page cr = 11

    op :       :
   ----:-------:-----------------------------------------------------
   000 : loop  : counter from regb
   001 : skip  : immediate 8
   010 : loadi : loads next instruction into regb
   011 :       : 
   100 :       :
   101 :       : 
   110 :       :
   111 :       :
```
