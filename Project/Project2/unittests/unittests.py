from unittest import TestCase
from framework import AssemblyTest, print_coverage


class TestAbs(TestCase):
    def test_zero(self):
        t = AssemblyTest(self, "abs.s")
        # load 0 into register a0
        t.input_scalar("a0", 0)
        # call the abs function
        t.call("abs")
        # check that after calling abs, a0 is equal to 0 (abs(0) = 0)
        t.check_scalar("a0", 0)
        # generate the `assembly/TestAbs_test_zero.s` file and run it through venus
        t.execute()

    def test_one(self):
        # same as test_zero, but with input 1
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", 1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    def test_minus_ones(self):
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", -1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    @classmethod
    def tearDownClass(cls):
        print_coverage("abs.s", verbose=False)


class TestRelu(TestCase):
    def do_relu(self, values, expected=None, code=0, length=None):
        t = AssemblyTest(self, "relu.s")
        array0 = t.array(values)
        t.input_array("a0", array0)
        t.input_scalar("a1", len(values) if length is None else length)
        t.call("relu")
        if expected is not None:
            t.check_array(array0, expected)
        t.execute(code=code)

    def test_simple(self):
        self.do_relu([1, -2, 3, -4, 5, -6, 7, -8, 9], [1, 0, 3, 0, 5, 0, 7, 0, 9])

    def test_all_positive(self):
        self.do_relu([1, 2, 3], [1, 2, 3])

    def test_all_negative(self):
        self.do_relu([-1, -2, -3], [0, 0, 0])

    def test_length_less_than_one(self):
        self.do_relu([1], code=78, length=0)

    @classmethod
    def tearDownClass(cls):
        print_coverage("relu.s", verbose=False)


class TestArgmax(TestCase):
    def do_argmax(self, values, length, expected=None, code=0):
        t = AssemblyTest(self, "argmax.s")
        array0 = t.array(values)
        t.input_array("a0", array0)
        t.input_scalar("a1", length)
        t.call("argmax")
        if expected is not None:
            t.check_scalar("a0", expected)
        t.execute(code=code)

    def test_simple(self):
        self.do_argmax([1, 2, 3, 4], 4, 3)

    def test_tie_returns_first_index(self):
        self.do_argmax([1, 7, 7, 3], 4, 1)

    def test_all_negative(self):
        self.do_argmax([-9, -3, -12, -3], 4, 1)

    def test_length_less_than_one(self):
        self.do_argmax([1], 0, code=77)

    @classmethod
    def tearDownClass(cls):
        print_coverage("argmax.s", verbose=False)


class TestDot(TestCase):
    def do_dot(self, v0, v1, length, stride0, stride1, expected=None, code=0):
        t = AssemblyTest(self, "dot.s")
        array0 = t.array(v0)
        array1 = t.array(v1)
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        t.input_scalar("a2", length)
        t.input_scalar("a3", stride0)
        t.input_scalar("a4", stride1)
        t.call("dot")
        if expected is not None:
            t.check_scalar("a0", expected)
        t.execute(code=code)

    def test_simple(self):
        self.do_dot([1, 2, 3], [4, 5, 6], 3, 1, 1, 32)

    def test_strided(self):
        self.do_dot([1, 0, 2, 0, 3], [4, 0, 5, 0, 6], 3, 2, 2, 32)

    def test_negative_values(self):
        self.do_dot([-1, -2, -3], [4, 5, 6], 3, 1, 1, -32)

    def test_length_less_than_one(self):
        self.do_dot([1], [2], 0, 1, 1, code=75)

    def test_stride0_less_than_one(self):
        self.do_dot([1], [2], 1, 0, 1, code=76)

    def test_stride1_less_than_one(self):
        self.do_dot([1], [2], 1, 1, 0, code=76)

    @classmethod
    def tearDownClass(cls):
        print_coverage("dot.s", verbose=False)


class TestMatmul(TestCase):
    def do_matmul(self, m0, m0_rows, m0_cols,
                  m1, m1_rows, m1_cols,
                  result, code=0):
        t = AssemblyTest(self, "matmul.s")

        # matmul uses dot
        t.include("dot.s")

        # create arrays
        array0 = t.array(m0)
        array1 = t.array(m1)

        # result memory must be pre-allocated
        out_len = len(result) if len(result) > 0 else 1
        array_out = t.array([0] * out_len)

        # load arguments
        t.input_array("a0", array0)
        t.input_scalar("a1", m0_rows)
        t.input_scalar("a2", m0_cols)

        t.input_array("a3", array1)
        t.input_scalar("a4", m1_rows)
        t.input_scalar("a5", m1_cols)

        t.input_array("a6", array_out)

        # call matmul
        t.call("matmul")

        # only check output if matmul should succeed
        if code == 0:
            t.check_array(array_out, result)

        t.execute(code=code)

    def test_square_3_by_3(self):
        self.do_matmul(
            [1, 2, 3,
             4, 5, 6,
             7, 8, 9],
            3, 3,

            [1, 2, 3,
             4, 5, 6,
             7, 8, 9],
            3, 3,

            [30, 36, 42,
             66, 81, 96,
             102, 126, 150]
        )

    def test_rectangular_2_by_3_times_3_by_2(self):
        self.do_matmul(
            [1, 2, 3,
             4, 5, 6],
            2, 3,

            [7, 8,
             9, 10,
             11, 12],
            3, 2,

            [58, 64,
             139, 154]
        )

    def test_1_by_3_times_3_by_1(self):
        self.do_matmul(
            [1, 2, 3],
            1, 3,

            [4,
             5,
             6],
            3, 1,

            [32]
        )

    def test_2_by_1_times_1_by_2(self):
        self.do_matmul(
            [3,
             4],
            2, 1,

            [5, 6],
            1, 2,

            [15, 18,
             20, 24]
        )

    def test_with_negative_numbers(self):
        self.do_matmul(
            [1, -2,
             -3, 4],
            2, 2,

            [-5, 6,
             7, -8],
            2, 2,

            [-19, 22,
             43, -50]
        )

    def test_m0_rows_invalid(self):
        self.do_matmul(
            [1, 2, 3],
            0, 3,

            [1, 2, 3],
            3, 1,

            [0],
            code=72
        )

    def test_m0_cols_invalid(self):
        self.do_matmul(
            [1, 2, 3],
            1, 0,

            [1, 2, 3],
            3, 1,

            [0],
            code=72
        )

    def test_m1_rows_invalid(self):
        self.do_matmul(
            [1, 2, 3],
            1, 3,

            [1, 2, 3],
            0, 1,

            [0],
            code=73
        )

    def test_m1_cols_invalid(self):
        self.do_matmul(
            [1, 2, 3],
            1, 3,

            [1, 2, 3],
            3, 0,

            [0],
            code=73
        )

    def test_dimension_mismatch(self):
        self.do_matmul(
            [1, 2,
             3, 4],
            2, 2,

            [1, 2,
             3, 4,
             5, 6],
            3, 2,

            [0, 0, 0, 0],
            code=74
        )

    @classmethod
    def tearDownClass(cls):
        print_coverage("matmul.s", verbose=False)


class TestReadMatrix(TestCase):

    def do_read_matrix(self, fail='', code=0):
        t = AssemblyTest(self, "read_matrix.s")
        # load address to the name of the input file into register a0
        t.input_read_filename("a0", "inputs/test_read_matrix/test_input.bin")

        # allocate space to hold the rows and cols output parameters
        rows = t.array([-1])
        cols = t.array([-1])

        # load the addresses to the output parameters into the argument registers
        t.input_array("a1", rows)
        t.input_array("a2", cols)

        # call the read_matrix function
        t.call("read_matrix")

        # check the output from the function
        if code == 0:
            t.check_array(rows, [3])
            t.check_array(cols, [3])

            t.check_array_pointer(
                "a0", 
                [1, 2, 3,
                4, 5, 6,
                7, 8, 9]
            )
        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)

    def test_fopen_error(self):
        self.do_read_matrix(fail='fopen', code=90)

    def test_fread_error(self):
        self.do_read_matrix(fail='fread', code=91)

    def test_malloc_error(self):
        self.do_read_matrix(fail='malloc', code=88)

    def test_fclose_error(self):
        self.do_read_matrix(fail='fclose', code=92)

    def test_simple(self):
        self.do_read_matrix()

    @classmethod
    def tearDownClass(cls):
        print_coverage("read_matrix.s", verbose=False)


class TestWriteMatrix(TestCase):

    def do_write_matrix(self, fail='', code=0):
        t = AssemblyTest(self, "write_matrix.s")
        outfile = "outputs/test_write_matrix/student.bin"
        # load output file name into a0 register
        t.input_write_filename("a0", outfile)
        # load input array and other arguments
        matrix = t.array([
            1, 2, 3,
            4, 5, 6,
            7, 8, 9
        ])

        t.input_array("a1", matrix)
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 3)
        # call `write_matrix` function
        t.call("write_matrix")
        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)
        # compare the output file against the reference
        if code == 0:
            t.check_file_output(outfile, "outputs/test_write_matrix/reference.bin")

    def test_fopen_error(self):
        self.do_write_matrix(fail='fopen', code=93)

    def test_fwrite_error(self):
        self.do_write_matrix(fail='fwrite', code=94)

    def test_fclose_error(self):
        self.do_write_matrix(fail='fclose', code=95)

    def test_simple(self):
        self.do_write_matrix()

    @classmethod
    def tearDownClass(cls):
        print_coverage("write_matrix.s", verbose=False)


class TestClassify(TestCase):

    def make_test(self):
        t = AssemblyTest(self, "classify.s")
        t.include("argmax.s")
        t.include("dot.s")
        t.include("matmul.s")
        t.include("read_matrix.s")
        t.include("relu.s")
        t.include("write_matrix.s")
        t.input_scalar("a2", 0)
        return t

    def test_simple0_input0(self):
        t = self.make_test()
        out_file = "outputs/test_basic_main/student0.bin"
        ref_file = "outputs/test_basic_main/reference0.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        # call classify function
        t.call("classify")
        # generate assembly and pass program arguments directly to venus
        t.execute(args=args)

        # compare the output file and
        t.check_file_output(out_file, ref_file)
        # compare the classification output with `check_stdout`
        t.check_stdout("2")

    def test_argc_error(self):
            t = self.make_test()
            args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                    "inputs/simple0/bin/inputs/input0.bin"]
            t.call("classify")
            t.execute(args=args, code=89)

    def test_malloc_error(self):
        t = self.make_test()
        out_file = "outputs/test_basic_main/student_malloc.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        t.call("classify")
        t.execute(args=args, fail="malloc", code=88)

    def test_simple1_input0(self):
        t = self.make_test()
        out_file = "outputs/test_basic_main/student1.bin"
        ref_file = "outputs/test_basic_main/reference1.bin"
        args = ["inputs/simple1/bin/m0.bin", "inputs/simple1/bin/m1.bin",
                "inputs/simple1/bin/inputs/input0.bin", out_file]
        t.call("classify")
        t.execute(args=args)
        t.check_file_output(out_file, ref_file)
        t.check_stdout("1")

    @classmethod
    def tearDownClass(cls):
        print_coverage("classify.s", verbose=False)


class TestMain(TestCase):

    def run_main(self, inputs, output_id, label):
        args = [f"{inputs}/m0.bin", f"{inputs}/m1.bin", f"{inputs}/inputs/input0.bin",
                f"outputs/test_basic_main/student{output_id}.bin"]
        reference = f"outputs/test_basic_main/reference{output_id}.bin"
        t = AssemblyTest(self, "main.s", no_utils=True)
        t.call("main")
        t.execute(args=args, verbose=False)
        t.check_stdout(label)
        t.check_file_output(args[-1], reference)

    def test0(self):
        self.run_main("inputs/simple0/bin", "0", "2")

    def test1(self):
        self.run_main("inputs/simple1/bin", "1", "1")
