# test beq & addi
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
title:  .asciiz "Test: beq & addi (for-loop sum from 0 to 15)"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   
        addi    $a0, $0, 16     # N: a0 = 16
        addi    $t0, $0, 0      # i: t0 = 0
loop:   bge     $t0, $a0, exit	# if i >= N exit (bge -> slt & beq)
        add     $t1, $t1, $t0   # c += i
        beq     $0, $0, loop
        addi    $t0, $t0, 1     # i++
exit:   sub     $t1, $t1, $t0   # undo the last "c += i" due to delayed slot
        nop
