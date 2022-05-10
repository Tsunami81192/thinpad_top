`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/14 14:14:18
// Design Name: 
// Module Name: SRAM
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

`define fyuart_Stat 32'hBFD003FC
`define fyuart_Date 32'hBFD003F8
module SRAM(
           input wire rst,
           input wire clk_50M,           //50MHz ʱ������

           /// ȡָ��
           input    wire[31:0]  rom_addr_i,     ///< ��ȡָ��ĵ�ַ
           input    wire        ce_i,           ///< ʹ���ź�
           output   reg [31:0] rom_data_o,     ///< ��ȡ����ָ��

           /// Ϊ�˷��㣬�����洢���ݵ��ߣ�ǰ׺Ϊram2
           (*mark_debug = "true"*)output   reg[31:0]   ram_data_o,
           (*mark_debug = "true"*)input    wire[31:0]  ram_addr_i,
           (*mark_debug = "true"*)input    wire[31:0]  ram_data_i,
           (*mark_debug = "true"*)input    wire        ram_we_i,              ///< дʹ�ܣ�����Ч
           (*mark_debug = "true"*)input    wire[3:0]   ram_sel_i,
           (*mark_debug = "true"*)input    wire        ram_ce_i,

           //ֱ�������ź�
           output    wire       txd,  //ֱ�����ڷ��Ͷ�
           input     wire       rxd,  //ֱ�����ڽ��ն�

           //BaseRAM�ź�
           (*mark_debug = "true"*)inout    wire[31:0]  base_ram_data,          //BaseRAM���ݣ���8λ��CPLD���ڿ���������
           (*mark_debug = "true"*)output   reg [19:0]  base_ram_addr,          //BaseRAM��ַ
           (*mark_debug = "true"*)output   reg [3:0]   base_ram_be_n,          //BaseRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
           (*mark_debug = "true"*)output   reg         base_ram_ce_n,          //BaseRAMƬѡ������Ч
           (*mark_debug = "true"*)output   reg         base_ram_oe_n,          //BaseRAM��ʹ�ܣ�����Ч
           (*mark_debug = "true"*)output   reg         base_ram_we_n,          //BaseRAMдʹ�ܣ�����Ч

           //ExtRAM�ź�
           (*mark_debug = "true"*)inout    wire[31:0]  ext_ram_data,           //ExtRAM����
           (*mark_debug = "true"*)output   reg [19:0]  ext_ram_addr,           //ExtRAM��ַ
           (*mark_debug = "true"*)output   reg [3:0]   ext_ram_be_n,           //ExtRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
           (*mark_debug = "true"*)output   reg         ext_ram_ce_n,           //ExtRAMƬѡ������Ч
           (*mark_debug = "true"*)output   reg         ext_ram_oe_n,           //ExtRAM��ʹ�ܣ�����Ч
           (*mark_debug = "true"*)output   reg         ext_ram_we_n            //ExtRAMдʹ�ܣ�����Ч
       );

/*****************************************************************************
 ����ͨ��ģ��
*****************************************************************************/

(*mark_debug = "true"*)wire [7:0]  ext_uart_rx;             ///< ���յ���������·
(*mark_debug = "true"*)reg  [7:0]  ext_uart_tx;                    ///< �������ݵ���·
(*mark_debug = "true"*)wire        ext_uart_ready,          ///< �������յ��������֮����Ϊ1
                                    ext_uart_busy;           ///< ������״̬�Ƿ�æµ��1Ϊæµ��0Ϊ��æµ
(*mark_debug = "true"*)reg         ext_uart_start,          ///< ���ݸ���������Ϊ1ʱ��������Է��ͣ�Ϊ0ʱ����������
                                    ext_uart_clear;          ///< ��1�����´�ʱ����Ч��ʱ�򣬻�����������ı�־λ


async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
               ext_uart_r(
                   .clk(clk_50M),                       //�ⲿʱ���ź�
                   .RxD(rxd),                           //�ⲿ�����ź�����
                   .RxD_data_ready(ext_uart_ready),     //���ݽ��յ���־
                   .RxD_clear(ext_uart_clear),          //������ձ�־
                   .RxD_data(ext_uart_rx)               //���յ���һ�ֽ�����
               );



async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
                  ext_uart_t(
                      .clk(clk_50M),                  //�ⲿʱ���ź�
                      .TxD(txd),                      //�����ź����
                      .TxD_busy(ext_uart_busy),       //������æ״ָ̬ʾ
                      .TxD_start(ext_uart_start),     //��ʼ�����ź�
                      .TxD_data(ext_uart_tx)          //�����͵�����
                  );


/*****************************************************************************
 CPU ����Эͬģ��
*****************************************************************************/

/// �����ȡ����д������ݷ�Χ
wire is_SerialStat = (ram_addr_i ==  `fyuart_Stat);
wire is_SerialDate = (ram_addr_i == `fyuart_Date);
wire is_base_ram = is_SerialStat != 1'b1 && is_SerialDate != 1'b1 && (ram_addr_i >= 32'h80000000) &&   (ram_addr_i < 32'h80400000);
wire is_ext_ram = is_SerialStat != 1'b1 && is_SerialDate != 1'b1 &&  (ram_addr_i < 32'h80800000) && (ram_addr_i >= 32'h80400000);

reg[31:0] serial_o;
wire[31:0] base_ram_o;
wire[31:0] ext_ram_o;

/// ������
always @(*) begin
    if(rst) begin
        ext_uart_start <= 1'b0;
        serial_o <= 32'h0000_0000;
        ext_uart_tx <= 8'h00;
    end
    else begin
        if(is_SerialStat) begin                                     /// ��ȡ����״̬
            serial_o <= {{30{1'b0}}, {ext_uart_ready, !ext_uart_busy}};
            ext_uart_start <= 1'b0;
            ext_uart_tx <= 8'h00;
        end
        else if(ram_addr_i == `fyuart_Date) begin                   /// ��ȡ�����ͣ���������
            if(ram_we_i) begin                                     /// �����ݣ������մ�������
                serial_o <= {24'h000000, ext_uart_rx};
                ext_uart_start <= 1'b0;
                ext_uart_tx <= 8'h00;
            end
            else begin                                              /// д���ݣ������ʹ�������
                ext_uart_tx <= ram_data_i[7:0];
                ext_uart_start <= 1'b1;
                serial_o <= 32'h0000_0000;
            end
        end
        else begin
            ext_uart_start <= 1'b0;
            serial_o <= 32'h0000_0000;
            ext_uart_tx <= 8'h00;
        end
    end
end

/// �����ڽ��յ�clear
reg     ext_uart_clear_next;
reg[3:0] ext_uart_clear_para;

always @(negedge clk_50M) begin
    if(rst) begin
        ext_uart_clear_next <= 1'b0;
    end
    else begin
        if(ext_uart_ready && ram_addr_i == `fyuart_Date && ram_we_i && ext_uart_clear_next == 1'b0) begin
            ext_uart_clear_next <= 1'b1;
        end
        else if (ext_uart_clear == 1'b1) begin
            ext_uart_clear_next <= 1'b0;
        end
        else begin
            ext_uart_clear_next <= ext_uart_clear_next;
        end
    end
end

always @(posedge clk_50M) begin
    if(rst) 
        ext_uart_clear <= 1'b0;
    else begin
        if(ext_uart_clear_next) 
            ext_uart_clear <= 1'b1;
        else 
            ext_uart_clear <= 1'b0;
    end
end


/// BaseRam ����ָ��������ݵĴ�ȡ
assign base_ram_data = is_base_ram ? ((ram_we_i) ? 32'hzzzzzzzz : ram_data_i) : 32'hzzzzzzzz;
//assign base_ram_o = base_ram_data;      /// �ڶ�ȡģʽ�£���ȡ����BaseRam����

/// ����BaseRam
/// ����Ҫ��BaseRam�л�ȡ����д�����ݵ�ʱ��������ΪCPU����ͣ��ˮ�ߣ�1��ʱ�����ڣ�
always @(*) begin
  base_ram_addr <= rst ? 20'h00000 : is_base_ram ? ram_addr_i[21:2] : rom_addr_i[21:2];
  base_ram_be_n <= rst ? 4'b1111 : is_base_ram ? ram_sel_i : 4'b0000;
  base_ram_ce_n <= rst ? 1'b1 : 1'b0;
  base_ram_oe_n <= rst ? 1'b1 : is_base_ram ? ! ram_we_i : 1'b0;
  base_ram_we_n <= rst ? 1'b1 : is_base_ram ? ram_we_i : 1'b1;
  rom_data_o <= rst ? 32'h0000_0000 : base_ram_data;
end


/// ����ExtRam
assign ext_ram_data = (ram_we_i) ? 32'hzzzzzzzz : ram_data_i;
//assign ext_ram_o = ext_ram_data;

always @(*) begin

    ext_ram_addr <= (rst || ~is_ext_ram ) ? 20'h00000 :  ram_addr_i[21:2];
    ext_ram_be_n <= (rst || ~is_ext_ram ) ? 4'b1111 : ram_sel_i;
    ext_ram_ce_n <= (rst || ~is_ext_ram ) ? 1'b1 : 1'b0;
    ext_ram_oe_n <= (rst || ~is_ext_ram ) ? 1'b1 : !ram_we_i;
    ext_ram_we_n <= (rst || ~is_ext_ram ) ? 1'b1 : ram_we_i;
    
end


/// ģ�飬ȷ�����������(*mark_debug = "true"*)

always @(*) begin
    if(rst) begin
        ram_data_o <= 32'h0000_0000;
    end
    else begin
        if(is_SerialStat || is_SerialDate ) begin
            ram_data_o <= serial_o;
        end
        else if (is_base_ram) begin
            case (ram_sel_i)
                4'b1110: ram_data_o <= {{24{base_ram_data[7]}}, base_ram_data[7:0]};
                4'b1101: ram_data_o <= {{24{base_ram_data[15]}}, base_ram_data[15:8]};
                4'b1011: ram_data_o <= {{24{base_ram_data[23]}}, base_ram_data[23:16]};
                4'b0111: ram_data_o <= {{24{base_ram_data[31]}}, base_ram_data[31:24]};
                4'b0000: ram_data_o <= base_ram_data;
                default: ram_data_o <= base_ram_data;
            endcase
        end
        else if (is_ext_ram) begin
            case (ram_sel_i)
                4'b1110: ram_data_o <= {{24{ext_ram_data[7]}}, ext_ram_data[7:0]};
                4'b1101: ram_data_o <= {{24{ext_ram_data[15]}}, ext_ram_data[15:8]};
                4'b1011: ram_data_o <= {{24{ext_ram_data[23]}}, ext_ram_data[23:16]};
                4'b0111: ram_data_o <= {{24{ext_ram_data[31]}}, ext_ram_data[31:24]};
                4'b0000: ram_data_o <= ext_ram_data;
                default: ram_data_o <= ext_ram_data;
            endcase
        end
        else begin
            ram_data_o <= 32'h0000_0000;
        end
    end
end

endmodule
