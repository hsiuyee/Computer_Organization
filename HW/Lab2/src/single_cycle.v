`timescale 1ns / 1ps
// 111652017

/** [Reading] 4.4 p.321-327
 * "Operation of the Datapath"
 * "Finalizing Control": double check your control.v !
 */
/** [Prerequisite] control.v
 * This module is the single-cycle MIPS processor in FIGURE 4.17
 * You can implement it by any style you want, but port `clk` & `rstn` must remain.
 */

/* checkout FIGURE 4.17 */
module single_cycle #(
    parameter integer TEXT_BYTES = 1024,        // size in bytes of instruction memory
    parameter integer TEXT_START = 'h00400000,  // start address of instruction memory
    parameter integer DATA_BYTES = 1024,        // size in bytes of data memory
    parameter integer DATA_START = 'h10008000   // start address of data memory
) (
    input clk,  // clock
    input rstn  // negative reset
);

    /* Instruction Memory */
    wire [31:0] instr_mem_address, instr_mem_instr;
    instr_mem #(
        .BYTES(TEXT_BYTES),
        .START(TEXT_START)
    ) instr_mem (
        .address(instr_mem_address),
        .instr  (instr_mem_instr)
    );

    /* Register Rile */
    wire [4:0] reg_file_read_reg_1, reg_file_read_reg_2, reg_file_write_reg;
    wire reg_file_reg_write;
    wire [31:0] reg_file_write_data, reg_file_read_data_1, reg_file_read_data_2;
    reg_file reg_file (
        .clk        (clk),
        .rstn       (rstn),
        .read_reg_1 (reg_file_read_reg_1),
        .read_reg_2 (reg_file_read_reg_2),
        .reg_write  (reg_file_reg_write),
        .write_reg  (reg_file_write_reg),
        .write_data (reg_file_write_data),
        .read_data_1(reg_file_read_data_1),
        .read_data_2(reg_file_read_data_2)
    );

    /* ALU */
    wire [31:0] alu_a, alu_b, alu_result;
    wire [3:0] alu_ALU_ctl;
    wire alu_zero, alu_overflow;
    alu alu (
        .a       (alu_a),
        .b       (alu_b),
        .ALU_ctl (alu_ALU_ctl),
        .result  (alu_result),
        .zero    (alu_zero),
        .overflow(alu_overflow)
    );

    /* Data Memory */
    wire data_mem_mem_read, data_mem_mem_write;
    wire [31:0] data_mem_address, data_mem_write_data, data_mem_read_data;
    data_mem #(
        .BYTES(DATA_BYTES),
        .START(DATA_START)
    ) data_mem (
        .clk       (clk),
        .mem_read  (data_mem_mem_read),
        .mem_write (data_mem_mem_write),
        .address   (data_mem_address),
        .write_data(data_mem_write_data),
        .read_data (data_mem_read_data)
    );

    /* ALU Control */
    wire [1:0] alu_control_alu_op;
    wire [5:0] alu_control_funct;
    wire [3:0] alu_control_operation;
    alu_control alu_control (
        .alu_op   (alu_control_alu_op),
        .funct    (alu_control_funct),
        .operation(alu_control_operation)
    );

    /* (Main) Control */  // named without `control_` prefix!
    wire [5:0] opcode;
    wire reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, jump, immd, leftshift;
    wire [1:0] alu_op;
    control control (
        .opcode    (opcode),
        .reg_dst   (reg_dst),
        .alu_src   (alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write (reg_write),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .branch    (branch),
        .jump      (jump),
        .immd      (immd),
        .leftshift (leftshift),
        .alu_op    (alu_op)
    );

    /** [step 1] Instruction Fetch
     * Fetch the instruction pointed by PC form memory.
     * 1. We need a register to store PC.
     * 2. Wire the pc to instruction memory.
     * 3. Implement an adder to calculate PC+4. (combinational)
     *    Hint: use "+" operator.
     */
    /** [Check Yourself]
     * After this stage, what does `instr_mem_instr` represents?
     */

    //  step 1
    reg [31:0] pc;  // DO NOT change this line

    // Step 2
    assign instr_mem_address = pc;

    // Step 3
    reg [31:0] pc_plus_4;
    always @* begin
        pc_plus_4 <= pc + 4;
    end

    /** [step 2] Instruction Decode
     * Let the processor understand what the instruction means & how to process this instruction.
     * (And read register files)
     * i.e. Let Control & ALU Control set correct control signal.
     * We will implement from top to bottom in FIGURE 4.17.
     * 1. Each segment of instruction refers to different meanings.
     *    Review FIGURE 4.14 to understand MIPS instruction formats. (Green Card is helpful, too)
     * 2. Wire each segment to Control & read address of Register File.
     * 3. Skip write address of Register File here.
     *    We will wire it in step 5.
     * 4. Implement a Sign-extend unit. (combinational)
     *    Hint: in two's complement, which bit represents sign-bit?
     * 5. Wire an segment to ALU Control.
     * 6. Wire ALUOp.
     * Hint: you can check your wiring by "Schematic" in Vivado.
     */
    /** [Check Yourself]
     * After this stage, are the outputs of Control ready?
     * Why we use combinational logic for Control unit instead of sequential?
     */

    // step 2
    assign opcode = instr_mem_instr[31:26];
    assign reg_file_read_reg_1 = instr_mem_instr[25:21];
    assign reg_file_read_reg_2 = instr_mem_instr[20:16];
    
    // step 3

    // step 4
    wire [31:0] extended_instr;
    assign extended_instr = {{16{instr_mem_instr[15]}}, instr_mem_instr[15:0]};

    // step 5
    assign alu_control_funct = instr_mem_instr[5:0];

    // step 6
    assign alu_control_alu_op = alu_op[1:0];

    /** [step 3] Execution
     * The processor execute the instruction using ALU.
     * e.g. calculate result of R-type instr, address of load/store, branch or not.
     * 1. Wire control signal to ALU.
     * 2. Use a Mux to select inputs (a, b) of ALU.
     *    Hint: use "?" operator with "assign", which is easier to read than an always block.
     * 3. Calculate branch target address. (combinational)
     * 4. Use a Mux & gate to select the next pc to be pc+4 or branch target. (combinational)
     */
    /** [Check Yourself]
     * Can you describe what the result of ALU means and how it is calculated for each different instruction?
     */

    // step 1
    assign alu_ALU_ctl = alu_control_operation[3:0];

    // step 2
    wire [31:0] pre_alu_a, pre_alu_b;
    wire [32:0] instr_15_0_shift = (leftshift == 1'b1) ? {instr_mem_instr[15:0], 16'b0} : {16'b0, instr_mem_instr[15:0]};
    assign pre_alu_a = reg_file_read_data_1[31:0];
    wire [32:0] pre_immd_alu_a = (leftshift == 1'b1) ? 32'b0 : reg_file_read_data_1;
    assign alu_a = (immd == 1'b1) ? pre_immd_alu_a : pre_alu_a;
    assign pre_alu_b = (alu_src == 1'b0) ? reg_file_read_data_2 : extended_instr;
    assign alu_b = (immd == 1'b1) ? instr_15_0_shift : pre_alu_b;
     
    // step 3
    wire [31:0] branch_target;
    assign branch_target = pc_plus_4 + {extended_instr[29:0],2'b00};
        
    // step 4
    wire branch_and_zero_flag_and;
    assign branch_and_zero_flag_and = branch && alu_zero;
    reg [31:0] next_pc, pre_next_pc;


    wire [31:0] jump_address = {pc_plus_4[31:28], instr_mem_instr[25:0], 2'b00};
    
    always @* begin
        if (branch_and_zero_flag_and) begin
            pre_next_pc = branch_target;
        end else begin
            pre_next_pc = pc_plus_4; 
        end
    end
    always @* begin
        if (jump) begin
            next_pc = jump_address;
        end else begin
            next_pc = pre_next_pc; 
        end
    end

    /** [step 4] Memory
     * The processor interact with Data Memory to execute load/store instr.
     * 1. wire address & data to write
     * 2. wire control signal of read/write
     * 3. check the clock signal is wired to data memory.
     */
    /** [Check Yourself]
     * Can you describe how the address is calculated?
     */

    // step 1
    assign data_mem_address = alu_result[31:0];
    assign data_mem_write_data = reg_file_read_data_2[31:0];

    // step 2
    assign data_mem_mem_read = mem_read;
    assign data_mem_mem_write = mem_write;


    // step 3
    // ok

    /** [step 5] Write Back
     * For R-type & load/store instr, data calculated or read from memory should be write back to register file.
     * 1. Use a Mux to select whether the write reg is rt or rd.
     * 2. Use a Mux to select whether the write data is from ALU or Memory.
     * 3. Wire the write control signal of Register File.
     */

    // step 1
    assign reg_file_write_reg = (reg_dst == 1'b0) ? instr_mem_instr[20:16] : instr_mem_instr[15:11];

    // step 2
    assign reg_file_write_data = (mem_to_reg == 1'b0) ? alu_result[31:0] : data_mem_read_data[31:0];

    // step 3
    assign reg_file_reg_write = reg_write;

    /** [step 6] Clocking (sequential logic)
     * This define the behavior of processor when a new clock cycle comes.
     * It should be very simple. Do not write your processor like a program.
     * Instead, it should looks more like a bunch of connected hardwares.
     * In single-cycle processor, it have to do 2 things:
     * 1. Update the registers inside the processor.
     *    Depends on your implementation, at least PC needs to be updated.
     * 2. Write data into Register File or Memory.
     *    Remember in Lab 1, Register File write is positive edge-trigger.
     * What else needs to be done besides clearing Register File when reset?
     * Important: our processor executes instruction at 0x00400000 when booted.
     */
    always @(posedge clk)begin
        if (rstn) begin
            pc <= next_pc;
        end
    end

    always @(negedge rstn) begin
        pc <= 'h00400000; 
    end

endmodule