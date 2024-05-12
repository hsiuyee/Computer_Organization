`timescale 1ns / 1ps
// 111652017

/** [Reading] 4.4 p.316-318
 * "The ALU Control"
 */
/**
 * This module is the ALU control in FIGURE 4.17
 * You can implement it by any style you want.
 * There's a more hardware efficient design in Appendix D.
 */

/* checkout FIGURE 4.12/13 */
module alu_control (
    input  [1:0] alu_op,    // ALUOp
    input  [5:0] funct,     // Funct field
    output [3:0] operation  // Operation
);

    /* implement "combinational" logic satisfying requirements in FIGURE 4.12 */

    // refer to slide P.34
    reg [3:0] operation_temp;
    always @* begin
        if (alu_op == 2'b11) begin
            operation_temp = 4'b0001;
        end
        else begin
            operation_temp[3] = 1'b0;
            operation_temp[2] = ((alu_op[0] == 1) || (alu_op[1] == 1 && funct[1] == 1)) ? 1'b1 : 1'b0;
            operation_temp[1] = (alu_op[1] == 0 || funct[2] == 0) ? 1'b1 : 1'b0;
            operation_temp[0] = ((alu_op[1] == 1 && funct[0] == 1) || (alu_op[1] == 1 && funct[3] == 1)) ? 1'b1 : 1'b0;
        end
    end
    assign operation = operation_temp;
    
endmodule
