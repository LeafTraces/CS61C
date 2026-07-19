.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -32
    sw s3, 12(sp)
    sw s2, 16(sp)
    sw s1, 20(sp)
    sw s0, 24(sp)
    sw ra, 28(sp)

    mv s1, a1   # matrix start
    mv s2, a2   # rows
    mv s3, a3   # cols

    # fd = fopen(filename, 1)
    mv a1, a0
    li a2, 1    # write
    jal ra, fopen

    li t0, -1
    beq a0, t0, fopen_error

    mv s0, a0   # s0 = fd

    # fwrite(fd, &rows, 1, 4)
    sw s2, 0(sp)
    mv a1, s0   #fd
    addi a2, sp, 0  #rows_ptr
    li a3, 1
    li a4, 4
    jal ra, fwrite

    li t0, 1
    bne a0, t0, fwrite_error

    # fwrite(fd, &cols, 1, 4)
    sw s3 4(sp)
    mv a1, s0
    addi a2, sp, 4  #cols_ptr
    li a3, 1
    li a4, 4
    jal ra, fwrite

    li t0, 1
    bne a0, t0, fwrite_error

    # fwrite(fd, matrix, rows * cols, 4)
    mul t0, s2, s3
    sw t0, 8(sp)

    mv a1, s0
    mv a2, s1
    mv a3, t0
    li a4, 4
    jal ra, fwrite

    lw t0, 8(sp)
    bne a0, t0, fwrite_error

    # fclose(fd)
    mv a1, s0
    jal ra, fclose

    bne a0, x0, fclose_error

    # Epilogue
    lw s3, 12(sp)
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)

    addi sp, sp, 32

    ret


fopen_error:
    li a1, 93
    jal exit2

fwrite_error:
    li a1, 94
    jal exit2

fclose_error:
    li a1, 95
    jal exit2