`timescale 1ns / 1ps
// <your student id>

/** [Prerequisite] pipelined (Lab 3), forwarding, hazard_detection
 * This module is the pipelined MIPS processor "similar to" FIGURE 4.60 (control hazard is not solved).
 * You can implement it by any style you want, as long as it passes testbench.
 */

module pipelined #(
    parameter integer TEXT_BYTES = 1024,        // size in bytes of instruction memory
    parameter integer TEXT_START = 'h00400000,  // start address of instruction memory
    parameter integer DATA_BYTES = 1024,        // size in bytes of data memory
    parameter integer DATA_START = 'h10008000   // start address of data memory
) (
    input clk,  // clock
    input rstn  // negative reset
);

    /** [step 0] Copy from Lab 3
     * You should modify your pipelined processor from Lab 3, so copy to here first.
     */

    /** [step 2] Connect Forwarding unit
     * 1. add `ID_EX_rs` into ID/EX stage registers
     * 2. Use a mux to select correct ALU operands according to forward_A/B
     *    Hint don't forget that alu_b might be sign-extended immediate!
     */
    wire [1:0] forward_A, forward_B;
    forwarding forwarding (
        .ID_EX_rs        (ID_EX_rs),
        .ID_EX_rt        (???),
        .EX_MEM_reg_write(???),
        .EX_MEM_rd       (???),
        .MEM_WB_reg_write(???),
        .MEM_WB_rd       (???),
        .forward_A       (forward_A),
        .forward_B       (forward_B)
    );

    assign alu_a = ???;  // forward 1st operand
    assign alu_b = ???;  // forward 2nd operand

    /** [step 4] Connect Hazard Detection unit
     * 1. use `pc_write` when updating PC
     * 2. use `IF_ID_write` when updating IF/ID stage registers
     * 3. use `stall` when updating ID/EX stage registers
     */
    hazard_detection hazard_detection (
        .ID_EX_mem_read(???),
        .ID_EX_rt      (???),
        .IF_ID_rs      (???),
        .IF_ID_rt      (???),
        .pc_write      (pc_write),            // implicitly declared
        .IF_ID_write   (IF_ID_write),         // implicitly declared
        .stall         (stall)                // implicitly declared
    );

    /** [step 5] Control Hazard
     * This is the most difficult part since the textbook does not provide enough information.
     * By reading p.377-379 "Reducing the Delay of Branches",
     * we can disassemble this into the following steps:
     * 1. Move branch target address calculation & taken or not from EX to ID
     * 2. Move branch decision from MEM to ID
     * 3. Add forwarding for registers used in branch decision from EX/MEM
     * 4. Add stalling:
          branch read registers right after an ALU instruction writes it -> 1 stall
          branch read registers right after a load instruction writes it -> 2 stalls
     */

endmodule  // pipelined
