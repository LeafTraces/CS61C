.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)

    mv s1, a1   # rows_ptr
    mv s2, a2   # cols_ptr

    # fd = fopen(filename, 0)
    mv a1, a0
    li a2, 0    # read_only
    jal ra, fopen
	
    li t0, -1
    beq a0, t0, fopen_error

    mv s0, a0

    # fread(fd, rows_ptr, 4)
    mv a1, s0   # fd
    mv a2, s1   # rows_ptr
    li a3, 4
    jal ra, fread

    li t0, 4
    bne a0, t0, fread_error

    # fread(fd, cols_ptr, 4)
    mv a1, s0
    mv a2, s2
    li a3, 4
    jal ra, fread

    li t0, 4
    bne a0, t0, fread_error

    lw t0, 0(s1)    # t0 = rows
    lw t1, 0(s2)    # t1 = cols
    mul t0, t0, t1  #number of elements
    slli s3, t0, 2  # number of byte

    # void* matrix = malloc(num_bytes)
    mv a0, s3
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s4, a0

    # fread(fd, matrix, num_bytes)
    mv a1, s0
    mv a2, s4
    mv a3, s3
    jal ra, fread

    bne a0, s3, fread_error

    # fclose(fd)
    mv a1, s0
    jal ra, fclose

    li t0, -1
    beq a0, t0, fclose_error

    mv a0, s4

    # Epilogue
    lw s4, 8(sp)
    lw s3, 12(sp)
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32

    ret


malloc_error:
    li a1, 88
    jal exit2

fopen_error:
    li a1, 90
    jal exit2

fread_error:
    li a1, 91
    jal exit2

fclose_error:
    li a1, 92
    jal exit2