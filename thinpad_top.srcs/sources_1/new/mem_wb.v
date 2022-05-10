`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 17:13:53
// Design Name: 
// Module Name: mem_wb
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


module mem_wb(
           input    wire        rst,            ///< 重置
           input    wire        clk,            ///< 时钟信号

           input    wire        mem_we_i,
           input    wire[4:0]   mem_waddr_i,
           input    wire[31:0]  mem_wdata_i,

           output    wire        wb_we_o,
           output    wire[4:0]   wb_waddr_o,
           output    wire[31:0]  wb_wdata_o
    );

dff32 u0(.clk(clk),.rst(rst),.d(mem_wdata_i),.q(wb_wdata_o));
dff5 u1(.clk(clk),.rst(rst),.d(mem_waddr_i),.q(wb_waddr_o));
dff1 u2(.clk(clk),.rst(rst),.d(mem_we_i),.q(wb_we_o));


endmodule
