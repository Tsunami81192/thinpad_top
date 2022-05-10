`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 16:00:34
// Design Name: 
// Module Name: Execute32
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


module Execute32(
input wire rst,input wire [31:0]inst,

input wire[3:0]aluop,

input wire [31:0]alua,alub,

input   wire[4:0]   waddr,
input   wire        we,

output  wire [31:0]  wdata_o,
output  wire [4:0]   waddr_o,
output  wire         we_o,
input   wire[31:0]  link_addr_i,

//input    wire[31:0]  inst_i,         

output   reg[3:0]    mem_op,         
output   reg[31:0]   mem_addr_o,     
output   reg[31:0]   mem_data_o     
    );
  wire [63:0]mulresult;  
  mult mul(.A(alua),.B(alub),.P(mulresult));  
  wire [31:0]Add_result;
  AddSub32 add(.a(alua),.b(alub),.sub(1'b0),.s(Add_result));
  reg[31:0]alu_result;    
  always @ * begin
        if(rst) alu_result = 32'h0000_0000;
        else if(aluop == 4'b0001) alu_result = Add_result;
        else if(aluop == 4'b0010) alu_result = mulresult[31:0];
        else if(aluop == 4'b0011) alu_result = alua & alub;
        else if(aluop == 4'b0100) alu_result = alua | alub;
        else if(aluop == 4'b0101) alu_result = alua ^ alub;
        else if(aluop == 4'b0110) alu_result = alua << alub;  
        else if(aluop == 4'b0111) alu_result = alua >> alub;
        else if(aluop == 4'b1000) alu_result = {alua[15:0],16'h0000};
        else if(aluop == 4'b1001) alu_result = link_addr_i;
        else alu_result = 32'h0000_0000;
  end
  
  assign wdata_o = rst ? 32'h0000_0000:alu_result;
  assign waddr_o = rst ? 5'b00000: waddr  ;  
  assign we_o = rst ? 1'b0: we;  
   wire [5:0] op = inst[31:26];
   wire i_lb        = (op == 6'b100000) ? 1'b1:1'b0;
   wire i_sb        = (op == 6'b101000 ) ? 1'b1:1'b0;  
   wire i_lw        = (op == 6'b100011) ? 1'b1 : 1'b0;
   wire i_sw        = (op == 6'b101011) ? 1'b1 : 1'b0;
   
   //----------¼Ó·¨IP------//
   wire [31:0]alu_address;
   AddSub32 add1(.a(alua),.b({{16{inst[15]}},inst[15:0]}),.sub(1'b0),.s(alu_address));
  //assign alu_address = alua + {{16{inst[15]}},inst[15:0]};
  always @ * begin
        if(rst)begin
            mem_op <= 4'b0000;
            mem_addr_o <= 32'b0000_0000;
            mem_data_o <= 32'b0000_0000;
        end
        else if(i_lb)begin
            mem_op <= 4'b0001;
            //mem_addr_o <= alua + {{16{inst[15]}},inst[15:0]};
            mem_addr_o <= alu_address;
            mem_data_o <= 32'h0000_0000;
        end
        else if(i_lw)begin
            mem_op <= 4'b0010;
            //mem_addr_o <= alua + {{16{inst[15]}},inst[15:0]};
            mem_addr_o <= alu_address;
            mem_data_o <= 32'h0000_0000;
        end
        else if(i_sb)begin
            mem_op <= 4'b0100;
            //mem_addr_o <= alua + {{16{inst[15]}},inst[15:0]};
            mem_addr_o <= alu_address;
            mem_data_o <= alub;
        end
        else if(i_sw)begin
            mem_op <= 4'b1000;
            //mem_addr_o <= alua + {{16{inst[15]}},inst[15:0]};
            mem_addr_o <= alu_address;
            mem_data_o <= alub;
        end
        else begin
            mem_op <= 4'b0000;
            mem_addr_o <= 32'h0000_0000;
            mem_data_o <= 32'h0000_0000;
        end
        end
endmodule
