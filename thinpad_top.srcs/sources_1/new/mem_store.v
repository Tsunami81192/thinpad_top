`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 16:49:35
// Design Name: 
// Module Name: mem_store
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


module mem_store(
           input        wire        rst,        

           input        wire        we_i,      
           input        wire[4:0]   waddr_i,   
           input        wire[31:0]  wdata_i,   

           output       reg         we_o,      
           output       reg[4:0]    waddr_o,   
           output       reg[31:0]   wdata_o,   

           input        wire[3:0]   mem_op,     
           input        wire[31:0]  mem_addr_i, 
           input        wire[31:0]  mem_data_i, 

           input       wire[31:0]    ram_data_i,  
           output      reg[31:0]    mem_addr_o, 
           output      reg[31:0]    mem_data_o, 
           output      reg          mem_we_o,  
           output      reg          mem_ce_o, 
           output      reg[3:0]     mem_sel_o 
           
    );

 always @ * begin
        
            if(rst) begin
                       we_o <= 1'b0;
                       waddr_o <= 5'b00000;
                       wdata_o <= 32'h00000000;
                       mem_addr_o <= 32'b00000000;
                       mem_data_o <= 32'b00000000;
                       mem_we_o <= 1'b0;
                    end
            else begin
                   we_o <= we_i;
                    waddr_o <= waddr_i;
                   if(mem_op == 4'b0001)begin //i_lb
                             mem_addr_o <= mem_addr_i;
                             mem_data_o <= 32'b00000000;
                             mem_we_o <= 1'b1;
                             wdata_o <= ram_data_i;   
                   end
                   else if(mem_op == 4'b0010)begin //i_lw
                          mem_addr_o <= mem_addr_i;
                          mem_data_o <= 32'b00000000;
                          mem_we_o <= 1'b1;
                          wdata_o <= ram_data_i;    
                   end
                   else if(mem_op == 4'b0100  )begin//i_sb
                           mem_addr_o <= mem_addr_i;
                           mem_data_o <= mem_data_i;
                           mem_we_o <= 1'b0;
                           wdata_o <= 32'h0000_0000; 
                   end
                   else if(mem_op == 4'b1000)begin
                           mem_addr_o <= mem_addr_i;
                           mem_data_o <= mem_data_i;
                           mem_we_o <= 1'b0;
                           wdata_o <= 32'h0000_0000; 
                   end
                   else begin
                           wdata_o <= wdata_i;
                           mem_addr_o <= 32'b00000000;
                           mem_data_o <= 32'b00000000;
                           mem_we_o <= 1'b0;
                   end
            end        
    end
     
    always @ * begin
             if(rst) begin
                     mem_sel_o <= 4'b0000;
             end     
             else begin
                    if(mem_op == 4'b0001 || mem_op == 4'b0100)begin
                        case(mem_addr_i[1:0]) 
                           2'b00:  mem_sel_o <= 4'b1110;
                           2'b01:  mem_sel_o <= 4'b1101;
                           2'b10:  mem_sel_o <= 4'b1011;
                           2'b11:  mem_sel_o <= 4'b0111;
                           default: mem_sel_o <= 4'b1111;                                   
                        endcase
                    end
                    else if(mem_op == 4'b0010 || mem_op == 4'b1000)begin
                          mem_sel_o <=  4'b0000;
                    end
                    else mem_sel_o <=  4'b1111;
             end
    end
    
    
endmodule
