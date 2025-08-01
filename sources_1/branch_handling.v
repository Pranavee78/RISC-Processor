`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2025 10:49:25
// Design Name: 
// Module Name: branch_handling
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

module branch_handling (
    input wire [31:0] pc_in,     // Current PC value
    input wire [31:0] imm_in,    // Branch offset (immediate value)
    input wire [3:0] cond,       // Branch condition (e.g., EQ, NE, etc.)
    input wire [1:0] opcode,     // Branch opcode (e.g., B, BL, BX)
    input wire zero,             // Zero flag from ALU
    input wire carry,            // Carry flag from ALU
    input wire negative,         // Negative flag from ALU
    input wire overflow,         // Overflow flag from ALU
    output reg [31:0] branch_pc_out, // Branch target address
    output reg branch_taken      // Indicates if the branch is taken
);

    // Branch target calculation
    assign branch_pc_out = pc_in + (imm_in << 1); // PC-relative addressing

    // Branch condition evaluation
    always @(*) begin
        case (cond)
            4'b0000: branch_taken = zero;          // EQ (Equal)
            4'b0001: branch_taken = ~zero;         // NE (Not Equal)
            4'b1010: branch_taken = carry;         // CS/HS (Carry Set/Unsigned Higher or Same)
            4'b1011: branch_taken = ~carry;        // CC/LO (Carry Clear/Unsigned Lower)
            4'b1100: branch_taken = negative;      // MI (Negative)
            4'b1101: branch_taken = ~negative;     // PL (Positive or Zero)
            4'b1110: branch_taken = overflow;      // VS (Overflow)
            4'b1111: branch_taken = ~overflow;     // VC (No Overflow)
            default: branch_taken = 1'b0;          // Default: no branch
        endcase
    end

endmodule
