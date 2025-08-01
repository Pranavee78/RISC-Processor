`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2025 20:06:23
// Design Name: 
// Module Name: program_counter
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


// ====================
// PROGRAM COUNTER MODULE
// ====================
module program_counter (
    input wire clk,
    input wire rst,
    input wire stall,
    input wire branch_taken,
    input wire [31:0] branch_target,
    output reg [31:0] pc
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 32'h00000000;
    end else if (!stall) begin
        if (branch_taken) begin
            pc <= branch_target;
        end else begin
            pc <= pc + 4;
        end
    end
end

endmodule
