`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 15:52:27
// Design Name: 
// Module Name: id_exe
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


module id_exe(
input wire rst,clk,

input wire[3:0]aluop,
input wire [4:0]waddr,
input wire id_wreg,
input wire [31:0]read_1,
input wire[31:0]read_2,
input    wire[31:0]      id_link_addr_i,
input    wire[31:0]      id_inst,

output wire[3:0]ex_aluop,
output wire [4:0]ex_waddr,
output wire id_ex_wreg,
output wire [31:0]ex_read_1,
output wire [31:0]ex_read_2,
output wire[31:0]       ex_link_addr_o,
output wire[31:0]       ex_inst

    );
 
dff4  u0(.clk(clk),.rst(rst),.d(aluop),.q(ex_aluop));
dff32 u1(.clk(clk),.rst(rst),.d(read_1),.q(ex_read_1));
dff32 u2(.clk(clk),.rst(rst),.d(read_2),.q(ex_read_2));
dff5  u3(.clk(clk),.rst(rst),.d(waddr),.q(ex_waddr));
dff1  u4(.clk(clk),.rst(rst),.d(id_wreg),.q(id_ex_wreg));
dff32 u5(.clk(clk),.rst(rst),.d(id_link_addr_i),.q(ex_link_addr_o));
dff32 u6(.clk(clk),.rst(rst),.d(id_inst),.q(ex_inst));

endmodule
