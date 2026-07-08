.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_length
    blt a3, t0, error_stride
    blt a4, t0, error_stride

    # Prologue
    li t0, 0
    li t1, 0
    slli t2, a3, 2
    slli t3, a4, 2

loop_start:
    bge t0, a2, loop_end
    lw t4, 0(a0)
    lw t5, 0(a1)
    mul t6, t4, t5
    add t1, t1, t6
    add a0, a0, t2
    add a1, a1, t3
    addi t0, t0, 1
    j loop_start

loop_end:
    mv a0, t1

    # Epilogue

    ret

error_length:
    li a1, 75
    jal exit2

error_stride:
    li a1, 76
    jal exit2
