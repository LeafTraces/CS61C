addi t0, x0, 0x100   
addi t1, x0, 1234     
sw   t1, 0(t0)
lw   t2, 0(t0)         
addi t1, x0, 5678
sw   t1, 8(t0)
lw   s0, 8(t0)    
lw   s1, 0(t0)          