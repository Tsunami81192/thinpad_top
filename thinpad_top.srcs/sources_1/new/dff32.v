`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 17:17:50
// Design Name: 
// Module Name: dff32
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


module dff32(
input wire clk,rst,
input wire [31:0] d,
output reg[31:0]q
    );
    always @(posedge clk)begin
        if(rst) q <= 32'h0000_0000;
        else q <= d;
    end
endmodule

module dff5(
input wire clk,rst,
input wire [4:0] d,
output reg[4:0]q
    );
    always @(posedge clk)begin
        if(rst) q <= 5'b0_0000;
        else q <= d;
    end
endmodule

module dff1(
input wire clk,rst,
input wire  d,
output reg q
    );
    always @(posedge clk)begin
        if(rst) q <= 1'b0;
        else q <= d;
    end
endmodule

module dff4(
input wire clk,rst,
input wire [3:0] d,
output reg [3:0]q
    );
    always @(posedge clk)begin
        if(rst) q <= 4'b0000;
        else q <= d;
    end
endmodule
