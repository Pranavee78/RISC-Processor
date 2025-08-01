`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2025 10:50:17
// Design Name: 
// Module Name: control_flow
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module control_flow (
    input wire clk,              // Clock signal
    input wire reset,            // Reset signal
    input wire [31:0] pc_in,     // Current program counter (PC)
    input wire [31:0] reg_in,    // Register value for BX/BLX/CBZ
    input wire [31:0] imm_in,    // Immediate value for branch offset
    input wire [3:0] cond,       // Condition code (for conditional branches)
    input wire [1:0] opcode,     // Opcode for branch type
    input wire nop_en,           // NOP enable
    input wire bkpt_en,          // Breakpoint enable
    output reg [31:0] pc_out,    // Updated program counter (PC)
    output reg [31:0] lr_out,    // Link register (for BL/BLX)
    output reg bkpt_triggered    // Breakpoint triggered signal
);

    // Internal signals
    reg [31:0] pc_next;          // Next PC value
    reg [31:0] lr_next;          // Next Link Register value
    reg cond_met;                // Condition met flag

    // Condition codes
    localparam EQ = 4'b0000;    // Equal
    localparam NE = 4'b0001;    // Not Equal
    localparam GT = 4'b1010;    // Greater Than
    localparam LT = 4'b1011;    // Less Than

    // Opcodes
    localparam B_OP = 2'b00;    // Unconditional Branch
    localparam BL_OP = 2'b01;   // Branch with Link
    localparam BLX_OP = 2'b10;  // Branch and Link Exchange
    localparam BX_OP = 2'b11;   // Branch and Exchange
    localparam COND_OP = 2'b11; // Conditional Branch (reused for CBZ)

    // Initialize outputs
    initial begin
        pc_out = 32'h0;
        lr_out = 32'h0;
        bkpt_triggered = 1'b0;
    end

    // Condition evaluation
    always @(*) begin
        case (cond)
            EQ: cond_met = (reg_in == 32'h0); // Equal
            NE: cond_met = (reg_in != 32'h0); // Not Equal
            GT: cond_met = ($signed(reg_in) > 32'h0); // Greater Than
            LT: cond_met = ($signed(reg_in) < 32'h0); // Less Than
            default: cond_met = 1'b0; // Default to false
        endcase
    end

    // Control flow logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'h0; // Reset PC
            lr_out <= 32'h0; // Reset Link Register
            bkpt_triggered <= 1'b0; // Reset breakpoint
        end else begin
            if (bkpt_en) begin
                // Breakpoint instruction
                bkpt_triggered <= 1'b1; // Trigger breakpoint
                pc_out <= pc_in; // Halt PC
            end else if (nop_en) begin
                // NOP instruction
                pc_out <= pc_in + 4; // Increment PC
            end else begin
                case (opcode)
                    B_OP: begin
                        // Unconditional Branch (B)
                        pc_out <= pc_in + imm_in; // PC = PC + offset
                    end
                    BL_OP: begin
                        // Branch with Link (BL)
                        lr_out <= pc_in + 4; // LR = PC + 4 (return address)
                        pc_out <= pc_in + imm_in; // PC = PC + offset
                    end
                    BLX_OP: begin
                        // Branch and Link Exchange (BLX)
                        lr_out <= pc_in + 4; // LR = PC + 4 (return address)
                        pc_out <= reg_in; // PC = Register value
                    end
                    BX_OP: begin
                        // Branch and Exchange (BX)
                        pc_out <= reg_in; // PC = Register value
                    end
                    COND_OP: begin
                        // Conditional Branch (BEQ, BNE, BGT, BLT, CBZ)
                        if (cond == 4'b0000 && reg_in == 32'h0) begin
                            // CBZ (Compare and Branch on Zero)
                            pc_out <= pc_in + imm_in; // Branch if register is zero
                        end else if (cond_met) begin
                            // BEQ, BNE, BGT, BLT
                            pc_out <= pc_in + imm_in; // Branch if condition met
                        end else begin
                            pc_out <= pc_in + 4; // Increment PC if condition not met
                        end
                    end
                    default: begin
                        pc_out <= pc_in + 4; // Default: Increment PC
                    end
                endcase
            end
        end
    end

endmodule