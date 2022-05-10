`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 18:50:32
// Design Name: 
// Module Name: FSM_stop
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


module FSM_stop(//-----¶¨Òå³õÊ¼×´Ì¬---------//
    input wire id_stop,
    input wire clk,
    input wire rst,
    output reg if_stop
    );
 reg [3:0]fsm;

 parameter [3:0] sinit = 4'b0000,
                  sif   = 4'b0001,
                  sid   = 4'b0010,
                  sexe  = 4'b0100,
                  smem  = 4'b1000;
 always @ (negedge clk)begin   
          if(rst)begin
                    if_stop <= 1'b0; fsm <= sinit;
                 end           
          else begin
             if(id_stop)begin
                            fsm <= sif;if_stop <= 1'b1;
                        end
             else begin           
                case(fsm)
                sif :begin
                        fsm <= sid;if_stop <= 1'b1;
                      end
                sid :begin
                        fsm <= sexe;if_stop <= 1'b1;
                     end      
                sexe:begin
                        fsm <= smem;if_stop <= 1'b1;
                     end
                smem:begin
                        fsm <= sinit;if_stop <= 1'b0;
                     end 
                default:begin
                        fsm <= sinit;if_stop <= 1'b0;
                end                 
                endcase
          end 
          end       
 end                 
endmodule
