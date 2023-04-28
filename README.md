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
    / . / . / . / 0 / 1 / immediate 11 << 3   /  call
   / . / . / . / 1 / 1 / 0 0 0 / .... / .... /  copy

    op :       :
   ----:-------:-----------------------------------------------------
   000 : loadi : reg[b]={next instruction}
   001 : addi  : reg[b]+=imm4
   010 : loop  : start loop with counter value from reg[b]
   011 : not   : reg[b]=~reg[b]
   011 : shift : reg[b]>>=imm4
   100 : skip  : pc+=imm8+1
   101 : add   : reg[b]+=reg[a]
   110 : load  : reg[b]=ram[a]
   111 : store : ram[a]=reg[b]

   page cr = 11

    op :       :
   ----:-------:-----------------------------------------------------
   000 : copy  : reg[b]=reg[a] 
   001 :       : 
   010 :       :
   011 :       : 
   100 :       :
   101 :       : 
   110 :       :
   111 :       :
```

todo:
- [ ] zn
- [ ] op copy
- [ ] assembler in webapp using server b