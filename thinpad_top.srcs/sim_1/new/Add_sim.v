`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/25 14:51:38
// Design Name: 
// Module Name: Add_sim
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


module Add_sim();
reg [31:0]a = 32'h4;reg [31:0]b= 32'h1;
reg sub = 1'b0;
wire [31:0]s;

AddSub32 add(.a(a),.b(b),.sub(sub),.s(s));
initial begin
#100 a = 32'h7;
#100 b = 32'h1;
end
endmodule
