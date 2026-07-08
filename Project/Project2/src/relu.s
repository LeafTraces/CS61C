.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    li t0, 1
    blt a1, t0, error_length

    # Prologue
    li t0, 0
    mv t1, a0

loop_start:
    bge t0, a1, loop_end
    lw t2, 0(t1)
    bge t2, zero, loop_continue
    sw zero, 0(t1)

loop_continue:
    addi t0, t0, 1
    addi t1, t1, 4
    j loop_start

loop_end:
    # Epilogue

    ret

error_length:
    li a1, 78
    jal exit2
