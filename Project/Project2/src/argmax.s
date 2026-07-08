.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    li t0, 1
    blt a1, t0, error_length

    # Prologue
    lw t1, 0(a0)
    li t2, 0
    li t3, 1
    addi t4, a0, 4


loop_start:
    bge t3, a1, loop_end
    lw t5, 0(t4)
    bge t1, t5, loop_continue
    mv t1, t5
    mv t2, t3


loop_continue:
    addi t3, t3, 1
    addi t4, t4, 4
    j loop_start


loop_end:
    mv a0, t2

    # Epilogue


    ret

error_length:
    li a1, 77
    jal exit2
