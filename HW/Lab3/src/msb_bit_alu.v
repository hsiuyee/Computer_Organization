`timescale 1ns / 1ps
// 111652017

/* checkout FIGURE C.5.10 (Bottom) */
/* [Prerequisite] complete bit_alu.v */
module msb_bit_alu (
    input        a,          // 1 bit, a
    input        b,          // 1 bit, b
    input        less,       // 1 bit, Less
    input        a_invert,   // 1 bit, Ainvert
    input        b_invert,   // 1 bit, Binvert
    input        carry_in,   // 1 bit, CarryIn
    input  [1:0] operation,  // 2 bit, Operation
    output reg   result,     // 1 bit, Result (Must it be a reg?)
    output reg   set,        // 1 bit, Set
    output       overflow    // 1 bit, Overflow
);
    /* Try to implement the most significant bit ALU by yourself! */
    /* Be careful with overflow in SLT, checkout Exercise C.24 */
    /* [step 1] ok invert input on demand */
    wire ai, bi;  // what's the difference between `wire` and `reg` ?
    assign ai = a_invert ? ~a : a;  // remember `?` operator in C/C++?
    assign bi = b_invert ? ~b : b;  // you can use logical expression too!

    /* [step 2] ok implement a 1-bit full adder */
    /**
     * Full adder should take ai, bi, carry_in as input, and carry_out, sum as output.
     * What is the logical expression of each output? (Checkout C.5.1)
     * Is there another easier way to implement by `+` operator?
     * https://www.chipverify.com/verilog/verilog-combinational-logic-assign
     * https://www.chipverify.com/verilog/verilog-full-adder
     */
     
    // assign set = ai ^ bi ^ carry_in; 
    assign carry_out = (ai & bi) | (ai & carry_in) | (bi & carry_in); 
    assign overflow = ((carry_in ^ carry_out) && !(operation == 2'b11)); 
    
    /* [step 3] ok using a mux to assign result */
    always @(*) begin
        if (a == 1 && b == 0 && operation == 2'b11)
            set <= 1;
        else if (a == 0 && b == 1 && operation == 2'b11)
            set <= 0;
        else
            set <= ai ^ bi ^ carry_in; 
    end
    
    always @(*) begin     
        case (operation) 
            2'b00: result <= ai & bi;  // AND
            2'b01: result <= ai | bi;  // OR
            2'b10: result <= set;
            2'b11: result <= less;     // SLT
            default: result <= 0;      // should not happen
        endcase
    end


endmodule
