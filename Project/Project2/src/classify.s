.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    addi sp, sp, -64
    sw s8, 8(sp)
    sw s7, 12(sp)
    sw s6, 16(sp)
    sw s5, 20(sp)
    sw s4, 24(sp)
    sw s3, 28(sp)
    sw s2, 32(sp)
    sw s1, 36(sp)
    sw s0, 40(sp)
    sw ra, 44(sp)

    li t0, 5
    bne a0, t0, argc_error

    mv s0, a1   # argv
    mv s1, a2   # print_classification

    li a0, 24
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s2, a0

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    lw a0, 4(s0)
    addi a1, s2, 0
    addi a2, s2, 4
    jal ra, read_matrix
    mv s3, a0
    

    # Load pretrained m1
    lw a0, 8(s0)
    addi a1, s2, 8
    addi a2, s2, 12
    jal ra, read_matrix
    mv s4, a0


    # Load input matrix
    lw a0, 12(s0)
    addi a1, s2, 16
    addi a2, s2, 20
    jal ra, read_matrix
    mv s5, a0


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    lw t0, 0(s2)    # m0_rows
    lw t1, 20(s2)   # input_cols
    mul t0, t0, t1  # hidden_elements
    slli a0, t0, 2  # hidden_bytes
    jal ra, malloc

    beq a0, x0, malloc_error
    mv s6, a0   #hidden_ptr

    # hidden = m0 * input
    mv a0, s3       # m0
    lw a1, 0(s2)    # m0_rows
    lw a2, 4(s2)    # m0_cols
    mv a3, s5       # input
    lw a4, 16(s2)
    lw a5, 20(s2)
    mv a6, s6
    jal ra, matmul

    mv a0, s6
    lw t0, 0(s2)    # m0_rows
    lw t1, 20(s2)   # input_cols
    mul a1, t0, t1
    jal ra, relu

    lw t0, 8(s2)    # m1_rows
    lw t1, 20(s2)   # hidden_cols = input_cols
    mul t0, t0, t1
    slli a0, t0, 2
    jal ra, malloc

    beq a0, x0, malloc_error
    mv s7, a0

    # output = m1 * hidden
    mv a0, s4
    lw a1, 8(s2)
    lw a2, 12(s2)
    mv a3, s6
    lw a4, 0(s2)    # hidden_rows = m0_rows
    lw a5, 20(s2)   # hidden_cols = input_cols
    mv a6, s7
    jal ra, matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

    lw a0, 16(s0)
    mv a1, s7
    lw a2, 8(s2)
    lw a3, 20(s2)
    jal ra, write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s7
    lw t0, 8(s2)    # m1_rows
    lw t1, 20(s2)   # input_cols
    mul a1, t0, t1
    jal ra, argmax

    mv s8, a0

    # Print classification
    bne s1, x0, skip_print

    mv a1, s8
    jal ra, print_int

    # Print newline afterwards for clarity
    li a1, '\n'
    jal ra, print_char



skip_print:
    mv a0, s2
    jal ra, free
    mv a0, s3
    jal ra, free
    mv a0, s4
    jal ra, free
    mv a0, s5
    jal ra, free
    mv a0, s6
    jal ra, free
    mv a0, s7
    jal ra, free

    mv a0, s8

    
    lw s8, 8(sp)
    lw s7, 12(sp)
    lw s6, 16(sp)
    lw s5, 20(sp)
    lw s4, 24(sp)
    lw s3, 28(sp)
    lw s2, 32(sp)
    lw s1, 36(sp)
    lw s0, 40(sp)
    lw ra, 44(sp)
    addi sp, sp, 64


    ret


argc_error:
    li a1, 89
    jal exit2

malloc_error:
    li a1, 88
    jal exit2