`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2025 09:47:57
// Design Name: 
// Module Name: branch_calculator
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


module branch_calculator (
    input wire [31:0] pc,
    input wire [23:0] branch_offset,
    input wire [4:0] opcode,
    output reg [31:0] branch_target
);
// Branches
`define OP_B     5'b10100
`define OP_BL    5'b10101
`define OP_BEQ   5'b10110
`define OP_BNE   5'b10111

reg [31:0] sign_extended_offset;

always @(*) begin
    // Sign extend the 24-bit offset to 32 bits
    sign_extended_offset = {{6{branch_offset[23]}}, branch_offset, 2'b00};
    
    case (opcode)
        `OP_B, `OP_BL, `OP_BEQ, `OP_BNE: begin
            branch_target = pc + 8 + sign_extended_offset; // PC+8 due to ARM pipeline
        end
        default: begin
            branch_target = pc + 4;
        end
    endcase
end

endmodule