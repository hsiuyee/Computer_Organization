`timescale 1ns / 1ps
// <your student id>

/* Copy your ALU (and its components) from Lab 1 */
module alu (
    input  [31:0] a,        // 32 bits, source 1 (A)
    input  [31:0] b,        // 32 bits, source 2 (B)
    input  [ 3:0] ALU_ctl,  // 4 bits, ALU control input
    output [31:0] result,   // 32 bits, result
    output        zero,     // 1 bit, set to 1 when the output is 0
    output        overflow  // 1 bit, overflow
);
endmodule
