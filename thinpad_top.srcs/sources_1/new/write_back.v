`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 17:13:37
// Design Name: 
// Module Name: write_back
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


module write_back( ///D触发器可实现
           input        wire        rst,    
           input        wire        clk,   

           input        wire        wd_i,
           input        wire[4:0]   waddr_i,
           input        wire[31:0]  wdata_i,

           output       wire         wd_o,
           output       wire[4:0]    waddr_o,
           output       wire[31:0]   wdata_o
    );

assign wd_o = rst ? 1'b0 : wd_i;
assign waddr_o = rst ? 5'b00000 : waddr_i;
assign wdata_o = rst ? 32'h0000_0000 : wdata_i;


endmodule
