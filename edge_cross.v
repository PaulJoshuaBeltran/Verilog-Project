`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2023 18:40:28
// Design Name: 
// Module Name: edge_cross
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

module edge_cross (
    input wire [15:0] vax, vay,
    input wire [15:0] vbx, vby,
    input wire [15:0] px, py,
    output wire [31:0] output_val
    );
    
    reg [31:0] output_reg;
    assign output_val = ((vbx - vax)*(py - vay)) - ((px - vax)*(vby - vay));
endmodule