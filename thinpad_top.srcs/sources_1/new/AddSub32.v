`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/01 23:10:00
// Design Name: 
// Module Name: AddSub32
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


module AddSub32(
input wire [31:0]a,b,
input wire sub,
output wire [31:0]s
    );
    assign s = (sub == 1'b1) ? a-b : a+b;
endmodule
