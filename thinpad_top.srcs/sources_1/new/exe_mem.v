`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 16:49:58
// Design Name: 
// Module Name: exe_mem
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


module exe_mem(
           input    wire        rst,        ///< 重置
           input    wire        clk,        ///< 时钟信号

           input    wire        ex_we,
           input    wire[4:0]   ex_waddr,
           input    wire[31:0]  ex_wdata,

           output   wire        mem_we,
           output   wire[4:0]   mem_waddr,
           output   wire[31:0]  mem_wdata,

           // for store
           input    wire[3:0]    ex_mem_op,
           input    wire[31:0]   ex_mem_addr_i,
           input    wire[31:0]   ex_mem_data_i,

           output    wire[3:0]    mem_mem_op,
           output    wire[31:0]   mem_mem_addr_o,
           output    wire[31:0]   mem_mem_data_o
    );

dff1  d1(.clk(clk),.rst(rst),.d(ex_we),.q(mem_we));
dff5  d2(.clk(clk),.rst(rst),.d(ex_waddr),.q(mem_waddr));
dff32 d0(.clk(clk),.rst(rst),.d(ex_wdata),.q(mem_wdata));
dff4  d3(.clk(clk),.rst(rst),.d(ex_mem_op),.q(mem_mem_op));
dff32 d4(.clk(clk),.rst(rst),.d(ex_mem_addr_i),.q(mem_mem_addr_o));
dff32 d5(.clk(clk),.rst(rst),.d(ex_mem_data_i),.q(mem_mem_data_o));


endmodule
