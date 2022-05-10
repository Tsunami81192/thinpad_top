`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 14:14:42
// Design Name: 
// Module Name: Fy_cpu_core
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


module Fy_cpu_core(
           input     wire               rst,          
           input     wire               clk,          

           output    wire[31:0]         rom_addr_o,   
           output    wire               ce_o,         
           input     wire[31:0]         rom_data_i,    

           input    wire[31:0]          ram2_data_i,
           output   wire[31:0]          ram2_addr_o,
           output   wire[31:0]          ram2_data_o,
           output   wire                ram2_we_o,
           output   wire[3:0]           ram2_sel_o,
           output   wire                ram2_ce_o
    );
    
    wire [31:0]pc;wire id_stop,if_stop;wire [31:0]bpc;wire[1:0] branch_singal;wire [31:0]id_pc;
    wire [31:0]id_inst;wire [31:0]id_ex_inst;wire [3:0]aluop;wire [31:0]jaldata;
    wire [31:0]read_data_1,read_data_2;
    wire [3:0]id_ex_aluop;wire [3:0]ex_aluop;wire [4:0]ex_waddr;wire [31:0]ex_read_1;
    wire [31:0]ex_read_2;wire [31:0]ex_jaldata;wire [31:0]ex_inst;wire ex_wreg; 
    wire [31:0]ex_wdata;wire [3:0]ex_mem_op;wire [31:0]ex_mem_addr_o;wire [31:0]ex_mem_data_o;
    wire ex_mem_wreg;wire [4:0]ex_mem_waddr;    
    wire mem_wreg;wire [4:0]mem_waddr;wire [31:0]mem_wdata;wire [3:0]mem_op;wire [31:0]mem_addr;wire [31:0]mem_data;    
    wire mem_wb_wreg;wire [4:0]mem_wb_waddr;wire [31:0]mem_wb_wdata;    
    wire [31:0]wb_wdata;wire wb_wreg;wire [4:0]wb_waddr;     wire [31:0]jr_pc,jmppc;
    wire [31:0]wb_id_wdata;wire wb_id_wreg;wire [4:0]wb_id_waddr;    
    
    
    FSM_stop fsm(
    .id_stop (id_stop),
    .if_stop (if_stop),
    .clk     (clk),
    .rst     (rst)
    );
    
    Ifetch32 ife(
    .clk          (clk),
    .rst          (rst),
    .pc           (pc),
    .stop         (if_stop),
    .signal(branch_singal),
    .branch_pc    (bpc),
    .jmppc(jmppc),.jr_pc(jr_pc)
    //.read         (ce_o)   
    );
    assign rom_addr_o = {3'b000,pc[28:0]};
    
    if_id_regfile  if_id(
    .clk    (clk),
    .rst    (rst),
    .if_pc  (pc),
    .id_pc  (id_pc),
    .if_inst(rom_data_i),
    .id_inst(id_inst),
    .if_stop(if_stop)
    );
    wire [4:0]id_waddr;wire id_wreg;
    Decode32 id(
    .clk(clk),
    .rst(rst),
    .wb_wreg(wb_id_wreg),
    .wb_waddr(wb_id_waddr),
    .wb_data(wb_id_wdata),   
    .inst(id_inst),
    .inst_o(id_ex_inst),
    
    .aluop(aluop),
    .pc(id_pc),
    .read_data_1(read_data_1),
    .read_data_2(read_data_2),
    .waddr(id_waddr),
    .wreg(id_wreg),
    
    .mem_we_i(mem_wb_wreg),
    .mem_waddr_i(mem_wb_waddr),
    .mem_wdata_i(mem_wb_wdata),
    
    .ex_we_i(ex_mem_wreg),
    .ex_waddr_i(ex_mem_waddr),
    .ex_wdata_i(ex_wdata),
    
    .branch_signal(branch_singal),
    .branch_address(bpc),
    .jmppc(jmppc),
    .jr_pc(jr_pc),
    .link_addr_o(jaldata),
    .is_stop(id_stop)
    );
    

    id_exe id_exe(
         .rst           (rst),
         .clk           (clk),
        
        .aluop          (aluop),
        .ex_aluop       (ex_aluop),
        
        .waddr          (id_waddr),
        .ex_waddr       (ex_waddr),
        
   
            
        .id_wreg        (id_wreg),
        .id_ex_wreg     (ex_wreg), 
        .read_1         (read_data_1),
        .ex_read_1      (ex_read_1),
        
        .read_2         (read_data_2),
        .ex_read_2      (ex_read_2),
        
        .id_link_addr_i (jaldata),
        .ex_link_addr_o (ex_jaldata),
        
        .id_inst        (id_ex_inst),
        .ex_inst        (ex_inst)
     
    );

    Execute32 exe(
          .rst(rst),
          .inst(ex_inst),
          
          .aluop(ex_aluop),
          
          .alua(ex_read_1),
          .alub(ex_read_2),
          
          .waddr(ex_waddr),
          .we(ex_wreg),
          
          .wdata_o(ex_wdata),
          .waddr_o(ex_mem_waddr),
          .we_o(ex_mem_wreg),
          .link_addr_i(ex_jaldata),
          
          //input    wire[31:0]  inst_i,         
          
          .mem_op(ex_mem_op),         
          .mem_addr_o(ex_mem_addr_o),     
          .mem_data_o(ex_mem_data_o)  
);

    exe_mem em(
           .rst(rst),        
           .clk(clk),       

           .ex_we(ex_mem_wreg),
           .ex_waddr(ex_mem_waddr),
           .ex_wdata(ex_wdata),

           .mem_we(mem_wreg),
           .mem_waddr(mem_waddr),
           .mem_wdata(mem_wdata),

           .ex_mem_op(ex_mem_op),
           .ex_mem_addr_i(ex_mem_addr_o),
           .ex_mem_data_i(ex_mem_data_o),

           .mem_mem_op(mem_op),
           .mem_mem_addr_o(mem_addr),
           .mem_mem_data_o(mem_data)
    );
    

    mem_store mem(
     . rst(rst),        

     . we_i(mem_wreg),      
     . waddr_i(mem_waddr),   
     . wdata_i(mem_wdata),   

     . we_o(mem_wb_wreg),      
     . waddr_o(mem_wb_waddr),   
     . wdata_o(mem_wb_wdata),

     . mem_op(mem_op),     
     . mem_addr_i(mem_addr), 
     . mem_data_i(mem_data), 

     . ram_data_i(ram2_data_i),  
     . mem_addr_o(ram2_addr_o), 
     . mem_data_o(ram2_data_o), 
     . mem_we_o(ram2_we_o),   
     . mem_sel_o(ram2_sel_o),  
     . mem_ce_o(ram2_ce_o)
    );

    mem_wb mem_wb(
           . rst(rst),        
           . clk(clk),          

           . mem_we_i(mem_wb_wreg),
           . mem_waddr_i(mem_wb_waddr),
           . mem_wdata_i(mem_wb_wdata),

           . wb_we_o(wb_wreg),
           . wb_waddr_o(wb_waddr),
           . wb_wdata_o(wb_wdata)
    
    );
    

    write_back wb(
 .rst(rst),    
 .clk(~clk),   

 .wd_i(wb_wreg),
 .waddr_i(wb_waddr),
 .wdata_i(wb_wdata),

 .wd_o(wb_id_wreg),
 .waddr_o(wb_id_waddr),
 .wdata_o(wb_id_wdata)
    );
endmodule
