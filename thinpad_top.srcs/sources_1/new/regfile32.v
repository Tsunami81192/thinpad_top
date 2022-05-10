`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 15:16:27
// Design Name: 
// Module Name: regfile32
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


module regfile32(
           input    wire        rst,   
           input    wire        clk,   

           (*mark_debug = "true"*)input    wire[4:0]   waddr,  
           (*mark_debug = "true"*)input    wire[31:0]  wdata,  
           (*mark_debug = "true"*)input    wire        we,    

           input    wire[4:0]   raddr_1,
           input    wire        re_1,  
           output   wire [31:0]  rdata_1,

           input    wire[4:0]   raddr_2,
           input    wire        re_2,   
           output   wire [31:0]  rdata_2
    );
    reg  [31:0]register[0:31];
    integer i;
    always@(negedge clk) begin
    if(rst) begin
        for ( i= 0;i < 32;i = i+1 ) begin
            register[i] <= 32'h00000000;
        end
    end
    else if(we == 1'b1 && waddr != 5'b00000) begin
                register[waddr] <= wdata;
            end
    else begin
            for ( i= 0;i < 32;i = i+1 ) begin
                register[i] <= register[i];
            end
    end
end
    
    assign rdata_1 = rst ? 32'h0000_0000 : re_1 ?( raddr_1 ? register[raddr_1] : 32'h0000_0000): 32'h00000000;
    
    assign rdata_2 = rst ? 32'h0000_0000 : re_2 ?( raddr_2 ? register[raddr_2] : 32'h0000_0000): 32'h00000000;
endmodule
