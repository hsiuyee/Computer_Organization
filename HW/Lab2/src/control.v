`timescale 1ns / 1ps
// 111652017

/** [Reading] 4.4 p.318-321
 * "Designing the Main Control Unit"
 */
/** [Prerequisite] alu_control.v
 * This module is the Control unit in FIGURE 4.17
 * You can implement it by any style you want.
 */

/* checkout FIGURE 4.16/18 to understand each definition of control signals */
module control (
    input  [5:0] opcode,      // the opcode field of a instruction is [?:?]
    output       reg_dst,     // select register destination: rt(0), rd(1)
    output       alu_src,     // select 2nd operand of ALU: rt(0), sign-extended(1)
    output       mem_to_reg,  // select data write to register: ALU(0), memory(1)
    output       reg_write,   // enable write to register file
    output       mem_read,    // enable read form data memory
    output       mem_write,   // enable write to data memory
    output       branch,      // this is a branch instruction or not (work with alu.zero)
    output       jump,        // this is a jump instruction or not 
    output       immd, 
    output       leftshift, 
    output [1:0] alu_op       // ALUOp passed to ALU Control unit
);

    /* implement "combinational" logic satisfying requirements in FIGURE 4.18 */
    /* You can check the "Green Card" to get the opcode/funct for each instruction. */
    reg [9:0] control_signals;  // Temporary reg for control signals
    reg [1:0] alu_op_reg;       // Temporary reg for ALUOp

    always @(*) begin
        if (opcode == 6'b000000) begin
            control_signals = 10'b1001000000;
            alu_op_reg = 2'b10;
        end
        // lw
        else if (opcode == 6'b100011) begin
            control_signals = 10'b0111100000;
            alu_op_reg = 2'b00;
        end
        // sw
        else if (opcode == 6'b101011) begin
            control_signals = 10'b0100010000;
            alu_op_reg = 2'b00;
        end   
        // beq
        else if (opcode == 6'b000100) begin
            control_signals = 10'b0000001000;
            alu_op_reg = 2'b01;
        end  
        // jump
        else if (opcode == 6'b000010)begin
            control_signals = 10'b0000000100;
            alu_op_reg = 2'b01;
        end  
        // lui: do or operation
        else if (opcode == 6'b001111) begin
            control_signals = 10'b0101000011;
            alu_op_reg = 2'b11;
        end
        // ori: do or operation
        else if (opcode == 6'b001101) begin
            control_signals = 10'b0101000010;
            alu_op_reg = 2'b11;
        end 
        else begin
            control_signals = 10'b0000000000; // Set to a default value
            alu_op_reg = 2'b00; // Set to a default value
        end
    end

    // Assign temporary reg values to outputs
    assign reg_dst         = control_signals[9];
    assign alu_src         = control_signals[8];
    assign mem_to_reg      = control_signals[7];
    assign reg_write       = control_signals[6];
    assign mem_read        = control_signals[5];
    assign mem_write       = control_signals[4];
    assign branch          = control_signals[3];
    assign jump            = control_signals[2];
    assign immd            = control_signals[1];
    assign leftshift       = control_signals[0];
    assign alu_op          = alu_op_reg;
    
endmodule