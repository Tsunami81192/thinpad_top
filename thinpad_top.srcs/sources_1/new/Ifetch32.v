`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 14:15:16
// Design Name: 
// Module Name: Ifetch32
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


module Ifetch32(
input wire clk,rst,stop,

output reg[31:0]pc,//output reg read,

input wire [1:0]signal,
input wire [31:0]jmppc,jr_pc,
input wire [31:0]branch_pc
    );
    reg [31:0]nextpc; 
    always @ (posedge clk)begin
        if(rst )begin
                    pc <= 32'h8000_0000;///read <= 1'b0;
                    nextpc <= 32'h8000_0000;
                end
       else if(signal == 2'b01)begin
                        //read <= 1'b1;
                        nextpc <= branch_pc + 32'h4;
                        pc <= branch_pc;
                      end
       else if(signal == 2'b10)begin
                        //read <= 1'b1;
                        nextpc <= jr_pc + 32'h4;
                        pc <= jr_pc;
                      end  
       else if(signal == 2'b11)begin
                        //read <= 1'b1;
                        nextpc <= jmppc + 32'h4;
                        pc <= jmppc;
                      end                                   
       else if(stop)begin
                        //read <= read;
                        nextpc <= nextpc;pc <= pc;
                    end
       else begin
                    //read <= 1'b1;
                    nextpc <= nextpc + 32'h4;pc <= nextpc;
            end             
    end
    
endmodule
