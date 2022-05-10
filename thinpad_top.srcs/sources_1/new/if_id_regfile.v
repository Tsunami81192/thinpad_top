`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 14:27:56
// Design Name: 
// Module Name: if_id_regfile
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


module if_id_regfile(
input wire [31:0]if_pc,if_inst,
output wire [31:0]id_pc,id_inst,

input wire clk,rst,if_stop
    );

dff32 d0(   .clk(clk),
            .rst(rst || if_stop),
            .d(if_pc),
            .q(id_pc));
            
dff32 d1(   .clk(clk),
            .rst(rst || if_stop),
            .d(if_inst),
            .q(id_inst));
endmodule
