`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 14:35:47
// Design Name: 
// Module Name: Decode32
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


module Decode32(
input wire clk,rst,//时钟与复位信号

input wire [31:0]inst,pc,

output reg [3:0]aluop,

output reg[31:0]read_data_1,
output reg[31:0]read_data_2,

output reg [4:0]waddr,
output reg wreg,

input wire wb_wreg,
input wire [4:0]wb_waddr,
input wire [31:0]wb_data,

input wire mem_we_i,
input wire [4:0]mem_waddr_i,
input wire [31:0]mem_wdata_i,

input wire ex_we_i,
input wire [4:0]ex_waddr_i,
input wire [31:0]ex_wdata_i,

output reg [1:0]branch_signal,
output   reg[31:0]   branch_address,jmppc,jr_pc,
output   reg[31:0]   link_addr_o,

output wire [31:0]inst_o,
output wire is_stop
    );
    
    assign inst_o = inst;
   wire [5:0] op = inst[31:26];
   wire [5:0] func = inst[5:0];
   
   wire Rtype = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];    // R-类型指令
    ////-------------------------------------r_format-------------------//
   wire r_addu        = (Rtype && (func == 6'b100001)) ? 1'b1 : 1'b0;
   wire r_mul         = (op == 6'b011100 && (func == 6'b000010)) ?1'b1:1'b0;  
   wire r_and        = (Rtype && (func == 6'b100100)) ? 1'b1 : 1'b0;
   wire r_or        = (Rtype && (func == 6'b100101)) ? 1'b1 : 1'b0;
   wire r_xor        = (Rtype && (func == 6'b100110)) ? 1'b1 : 1'b0;
   wire r_sll        = (Rtype && (func == 6'b000000)) ? 1'b1 : 1'b0;
   wire r_srl        = (Rtype && (func == 6'b000010)) ? 1'b1 : 1'b0;
   wire r_jr        = (Rtype && (func == 6'b001000)) ? 1'b1 : 1'b0;
   ////-------------------------------------i_format-------------------//
   wire i_addiu    = (op == 6'b001001) ? 1'b1 : 1'b0;
   wire i_andi        = (op == 6'b001100) ? 1'b1 : 1'b0;
   wire i_ori        = (op == 6'b001101) ? 1'b1 : 1'b0;
   wire i_xori        = (op == 6'b001110) ? 1'b1 : 1'b0;
   wire i_lui        = (op == 6'b001111) ? 1'b1 : 1'b0;
   wire i_lw        = (op == 6'b100011) ? 1'b1 : 1'b0;
   wire i_sw        = (op == 6'b101011) ? 1'b1 : 1'b0;
   wire i_beq        = (op == 6'b000100) ? 1'b1 : 1'b0;
   wire i_bne        = (op == 6'b000101) ? 1'b1 : 1'b0;
   wire i_bgtz      = (op == 6'b000111) ? 1'b1:1'b0;
   wire i_lb        = (op == 6'b100000) ? 1'b1:1'b0;
   wire i_sb        = (op == 6'b101000 ) ? 1'b1:1'b0; 
   ////-------------------------------------j_format-------------------//
   wire jmp            = (op == 6'b000010) ? 1'b1 : 1'b0;
   wire jal        = (op == 6'b000011) ? 1'b1 : 1'b0;
    
   wire [31:0]nextpc = pc + 32'h4; 
//   wire [15:0]immediate = inst[15:0];
   wire [31:0]zero_extend = {16'h0000,inst[15:0]}; 
   wire [31:0]sign_extend = {{16{inst[15]}},inst[15:0]};
   
   //--------------------------------------处理延迟槽用于分支地址计算------------------------------//
   always @ * begin
      if(rst)begin   
                   branch_signal <= 2'b00;
              end 
       else begin
               if((i_beq && (read_data_1 == read_data_2)) || 
                  (i_bne && (read_data_1 != read_data_2)) ||
                  (i_bgtz && (read_data_1 > 32'h0000_0000))) branch_signal <= 2'b01;
               else if(r_jr) branch_signal <= 2'b10;
               else if(jal || jmp) branch_signal <= 2'b11;
               else branch_signal <= 2'b00;
            end  
   end
   always @ * begin
		if(rst)begin
		   branch_address <= 32'h0000_0000;
		   jmppc <= 32'h0000_0000;
		   jr_pc <= 32'h0000_0000;
		end
		else begin
		branch_address <= pc + 32'h4 + {{14{inst[15]}},{inst[15:0],2'b00}};
		jmppc <= {nextpc[31:28],inst[25:0],2'b00};
		jr_pc <= read_data_1;
		link_addr_o = jal ? pc + 32'h8 : 32'h0000_0000; 
		end
end
   //----------------------------------------------------------------------------------------------------------//
   
   assign is_stop = rst ? 1'b0 : (i_sb | i_sw | i_lw | i_lb) ? 1'b1 : 1'b0;
    
   //-----------------------------------------------------------------------------------------------------------// 
   always @ * begin  
 if(rst || inst == 32'h0000_0000) begin
                  waddr <= 5'b00000;
                  wreg <= 1'b0;end
                  else begin 
            waddr <= Rtype ? inst[15:11] : r_mul ? inst[15:11] : jal ? 5'b11111 : inst[20:16];
            wreg <= r_addu | r_mul | r_and | r_or |r_xor |r_sll |r_srl | i_lw | i_lb | i_xori |i_addiu |i_lui |i_ori | i_andi| jal;
            end
   end
   //*--------------------------------------------------------------------------------------------------------------//
   always @ * begin
            if(rst) aluop <= 4'b0000;
            else if(r_addu || i_addiu || i_lw || i_sw || i_lb || i_sb)
               aluop = 4'b0001;
       else if(r_mul)
               aluop = 4'b0010;
       else if(r_and || i_andi)
               aluop = 4'b0011;
       else if(r_or || i_ori)
               aluop = 4'b0100;
       else if(r_xor || i_xori)
               aluop = 4'b0101;
       else if(r_sll)
               aluop = 4'b0110;
       else if(r_srl)
               aluop = 4'b0111;                                                  
       else if(i_lui)
              aluop = 4'b1000;      
       else if(jal)aluop = 4'b1001;         
       else aluop = 4'b0000;       
   end
   //--------------------------------------------------------------------------------------------------------------//
   reg [4:0]raddr_1,raddr_2;reg read_enable_1,read_enable_2;
   always @ * begin                                    
       if(rst || inst == 32'h0000_0000) begin
                                           raddr_1 <= 5'b00000;
                                           read_enable_1 <= 1'b0;
                                           raddr_2 <= 5'b00000;
                                           read_enable_2 <= 1'b0;
                                       end
       else if(r_xor || r_or ||r_and ||r_addu || r_mul || i_sw ||i_sb || i_bne ||i_beq)begin
                raddr_1 <= inst[25:21];raddr_2 <= inst[20:16];
                read_enable_1 <= 1'b1; read_enable_2 <= 1'b1;         
       end
       else if(i_bgtz || i_addiu ||i_andi || i_ori ||i_xori || r_jr)begin
                raddr_1 <= inst[25:21];raddr_2 <= 5'b00000;
                read_enable_1 <= 1'b1; read_enable_2 <= 1'b0;      
       end
       else if(r_sll || r_srl )begin
              raddr_1 <= inst[20:16];raddr_2 <= 5'b0_0000;
              read_enable_1 <= 1'b1; read_enable_2 <= 1'b0;           
       end
       else if(i_lui)begin
             raddr_1 <= inst[25:21];raddr_2 <= inst[25:21];
             read_enable_1 <= 1'b0; read_enable_2 <= 1'b0; 
       end
       else if(i_lw || i_lb)begin
             raddr_1 <= inst[25:21];raddr_2 <= inst[20:16];
             read_enable_1 <= 1'b1; read_enable_2 <= 1'b0; 
       end
       else begin
            raddr_1 <= 5'b00000;raddr_2 <= 5'b00000;
            read_enable_1 <= 1'b0; read_enable_2 <= 1'b0; 
       end
       
   end
   wire [31:0]rsport,rtport;
   regfile32 file(
   .clk(clk),.rst(rst),
   .re_1(read_enable_1),.re_2(read_enable_2),
   .waddr(wb_waddr),.wdata(wb_data),.we(wb_wreg),
   .raddr_1(raddr_1),.raddr_2(raddr_2),
   .rdata_1(rsport),.rdata_2(rtport)
   );
  //-------------------------------------------------------------------------------------------------------------------------------//
  always @ * begin
      if(rst) begin
           read_data_1 <= 32'h00000000; 
      end  
      else begin
          if ((read_enable_1 == 1'b1 && ex_we_i==1'b1) & (raddr_1 == ex_waddr_i)) begin
                   read_data_1 <= ex_wdata_i;
          end  
          else if ((read_enable_1 == 1'b1 && mem_we_i==1'b1) &&(raddr_1 == mem_waddr_i)) begin
                   read_data_1 <= mem_wdata_i;
          end
          else if (read_enable_1 == 1'b1) begin
                  read_data_1 <= rsport;
          end 
          else if(read_enable_1 == 1'b0)begin
                if(r_sll || r_srl)begin  read_data_1 <= {27'h0,inst[10:6]};  end
                else if(i_addiu )begin read_data_1 <= sign_extend;  end
                else if(i_xori || i_ori || i_andi || i_lui)begin read_data_1 <= zero_extend; end
                else read_data_1 <= 32'h0000_0000;
          end  
          else read_data_1 <= 32'h0000_0000;
      end
  end
   
    always @ * begin
      if(rst) begin
           read_data_2 <= 32'h00000000;
      end  
      else begin
          if ((read_enable_2 == 1'b1 && ex_we_i==1'b1) & (raddr_2 == ex_waddr_i)) begin
                   read_data_2 <= ex_wdata_i;
          end  
          else if ((read_enable_2 == 1'b1 && mem_we_i==1'b1) &&(raddr_2 == mem_waddr_i)) begin
                   read_data_2 <= mem_wdata_i;
          end
          else if (read_enable_2 == 1'b1) begin
                  read_data_2 <= rtport;
          end 
          else if(read_enable_2 == 1'b0)begin
                if(r_sll || r_srl)begin  read_data_2 <= {27'h0,inst[10:6]};  end
                else if(i_addiu )begin read_data_2 <= sign_extend;  end
                else if(i_xori || i_ori || i_andi ||i_lui)begin read_data_2 <= zero_extend; end
                else read_data_2 <= 32'h0000_0000;
          end  
          else read_data_2 <= 32'h0000_0000;
      end
  end 
    
endmodule
