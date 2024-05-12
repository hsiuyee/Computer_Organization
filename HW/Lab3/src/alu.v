`timescale 1ns / 1ps
// 111652017

/* checkout FIGURE C.5.12 */
/** [Prerequisite] complete bit_alu.v & msb_alu.v
 * We recommend you to design a 32-bit ALU with 1-bit ALU.
 * However, you can still implement ALU with more advanced feature in Verilog.
 * Feel free to code as long as the I/O ports remain the same shape.
 */
module alu (
    input  [31:0] a,        // 32 bits, source 1 (A)
    input  [31:0] b,        // 32 bits, source 2 (B)
    input  [ 3:0] ALU_ctl,  // 4 bits, ALU control input
    output [31:0] result,   // 32 bits, result
    output        zero,     // 1 bit, set to 1 when the output is 0
    output        overflow  // 1 bit, overflow
);
    /* [step 1] instantiate multiple modules */
    /**
     * First, we need wires to expose the I/O of 32 1-bit ALUs.
     * You might wonder if we can declare `operation` by `wire [31:0][1:0]` for better readability.
     * No, that is a feature call "packed array" in "System Verilog" but we are using "Verilog" instead.
     * System Verilog and Verilog are similar to C++ and C by their relationship.
     */
    wire [31:0] less, a_invert, b_invert, carry_in;
    wire [31:0] carry_out;
    wire [63:0] operation;  // flatten vector, 32 ALU, op cost 2 bits for each.
    wire        set;  // set of most significant bit
    /**
     * Second, we instantiate the less significant 31 1-bit ALUs
     * How are these modules wried?
     */
    bit_alu lsbs[30:0] (
        .a        (a[30:0]),
        .b        (b[30:0]), // Connects to the corresponding bits in b
        .less     (less[30:0]), // Connects to the corresponding bits in less
        .a_invert (a_invert[30:0]), // Connects to the corresponding bits in a_invert
        .b_invert (b_invert[30:0]), // Connects to the corresponding bits in b_invert
        .carry_in (carry_in[30:0]), // Connects to the corresponding bits in carry_in
        .operation(operation[61:0]), // Connects to the corresponding bits in operation
        .result   (result[30:0]), // Connects to the corresponding bits in result
        .carry_out(carry_out[30:0]) // Connects to the corresponding bits in carry_out
    );
    /* Third, we instantiate the most significant 1-bit ALU */
    msb_bit_alu msb (
        .a        (a[31]),
        .b        (b[31]), // Connects to the corresponding bit in b
        .less     (less[31]), // Connects to the corresponding bit in less
        .a_invert (a_invert[31]), // Connects to the corresponding bit in a_invert
        .b_invert (b_invert[31]), // Connects to the corresponding bit in b_invert
        .carry_in (carry_in[31]), // Connects to the corresponding bit in carry_in
        .operation(operation[63:62]), // Connects to the corresponding bit in operation
        .result   (result[31]), // Connects to the corresponding bit in result
        .set      (set), // Connects to the set signal
        .overflow (overflow) // Connects to the overflow signal
    );
    /** [step 2] wire these ALUs correctly
     * 1. `a` & `b` are already wired.
     * 2. About `less`, only the least significant bit should be used when SLT, so the other 31 bits ...?
     *    checkout: https://www.chipverify.com/verilog/verilog-concatenation
     * 3. `a_invert` should all connect to ?
     * 4. `b_invert` should all connect to ? (name it `b_negate` first!)
     * 5. What is the relationship between `carry_in[i]` & `carry_out[i-1]` ?
     * 6. `carry_in[0]` and `b_invert` appears to be the same when SUB... , right?
     * 7. `operation` should be wired to which 2 bits in `ALU_ctl` ?
     * 8. `result` is already wired.
     * 9. `set` should be wired to which `less` bit?
     * 10. `overflow` is already wired.
     * 11. You need another logic for `zero` output.
     */
    genvar i;
    generate
        for(i = 0; i < 32; i = i + 1) begin
            assign a_invert[i] = ALU_ctl[3];
            assign b_invert[i] = ALU_ctl[2];
            assign operation[2*i] = ALU_ctl[0];
            assign operation[2*i+1] = ALU_ctl[1];
        end
    endgenerate

    reg temp;
    always @* begin
        temp = (ALU_ctl == 4'b0110 || ALU_ctl == 4'b0111);
    end

    assign carry_in[0] = temp ? 1'b1 : 1'b0; // Initial carry in
    assign carry_in[31:1] = carry_out[30:0]; // previous carry_out is latter carry_in

    // Logic for `set` based on `less`
    assign less[0] = set;

    assign less[31:1] = 31'b0;
    // Logic for `zero` output
    assign zero = (result == 32'b0) ? 1'b1 : 1'b0;

endmodule