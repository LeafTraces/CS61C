.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    li t0, 1

    blt a1, t0, error_m0
    blt a2, t0, error_m0

    blt a4, t0, error_m1
    blt a5, t0, error_m1

    bne a2, a4, error_match


    # Prologue
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)

    mv s0, a0      # s0 = m0
    mv s1, a1      # s1 = rows0
    mv s2, a2      # s2 = cols0

    mv s3, a3      # s3 = m1
    mv s4, a4      # s4 = rows1
    mv s5, a5      # s5 = cols1

    mv s6, a6      # s6 = d

    li s7, 0       # s7 = i

outer_loop_start:

    bge s7, s1, outer_loop_end

    li s8, 0

inner_loop_start:

    bge s8, s5, inner_loop_end

    # row_ptr
    mul t0, s7, s2  # i * cols
    slli t0, t0, 2  # i * cols * 4
    add t1, s0, t0  # i * cols * 4 + m0

    # col_ptr
    slli t0, s8, 2
    add t2, s3, t0

    mv a0, t1
    mv a1, t2
    mv a2, s2   # a2 = length = cols0
    li a3, 1
    mv a4, s5

    jal ra, dot

    mul t0, s7, s5
    add t0, t0, s8
    slli t0, t0, 2
    add t3, s6, t0

    sw a0, 0(t3)

    addi s8, s8, 1
    j inner_loop_start

inner_loop_end:
    addi s7, s7, 1
    j outer_loop_start

outer_loop_end:

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    addi sp, sp, 48

    # Epilogue
    
    ret

error_m0:
    li a1, 72
    jal exit2

error_m1:
    li a1, 73
    jal exit2

error_match:
    li a1, 74
    jal exit2