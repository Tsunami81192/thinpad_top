Thinpad 模板工程
---------------

工程包含示例代码和所有引脚约束，可以直接编译。

代码中包含中文注释，Vivado下可能出现乱码问题，为了保证显示正确
Windows平台请使用GBK编码的文件，Linux平台请使用UTF-8编码的文件。  

一、代码使用说明
thinpad_top.sim:仿真文件夹
thinpad_top.srcs:代码文件夹
    constrs_1:管脚约束文件
    sim_1:    仿真文件
    sources_1:代码文件夹
        Add_Sub.v       :  加减法器代码
        async.v         :  串口发送和接受模块
        Decode32.v      :  指令译码
        dff32.v         :  32位寄存器
        exe_mem.v       :  从执行一级到访存一级的流水间寄存器
        Execute32.v     :  执行单元
        FSM_stop.v      :  用于解决结构相关性的状态机
        Fy_cpu_core.v   :  整个CPU核的顶层模块
        id_exe.v        :  从译码一级传到执行一级的流水间寄存器
        if_id_regfile.v :  从取指一级传到译码一级的流水间寄存器
        Ifetch32.v      :  取指单元
        mem_store.v     :  访存模块
        mem_wb.v        :  从访存一级传到写回一级的流水间寄存器
        regfile32.v     :  32个32位寄存器组
        SEG7_LUT.v      :  数码管模块
        SRAM.v          :  SRAM内存读写控制与串口控制模块
        thinpad_top.v   :  树莓派顶层模块代码
        vga.v           :  vga显示模块，用于显示三原色
        write_back.v    :  CPU的写回模块
thinpad_top.xpr:整个工程文件，可直接双击打开

notes:在进行仿真时，需要先将kernel.bin文件拷贝至（thinpad_top\thinpad_top.sim\sim_1\behav\xsim）
      路径下。否则的话，仿真时会无法加载内存里的数据

二、代码设计说明

    顶层模块thinpad_top包括三个部分，一个是SRAM接口部分。一个是CPU部分，还有一个就是串口转发部分。
而CPU部分又包括基本的五个单元，即取指令（Ifetch32），这个模块主要负责对分支地址的处理。译码（Decode32），
这个模块主要负责对指令的解析和得到传递给执行单元的操作数（即处理数据相关性采用定向法）。执行（Execute32），
这个模块主要是负责处理各种指令的计算。存储（mem_store），这个模块主要是负责对于传到SRAM的数据和传入到CPU
的一些地址和数据的处理，计算出传出的地址以及接受从SRAM到来的数据。回写（write_back）。同时为了解决结构相
关性，引入了状态机（FSM_stop）。这个模块主要是通过一个状态的变迁来处理的，比如取指令在第一个时钟阶段发生，
如果是访存指令那么得到第四个时钟阶段才能取消阻塞。寄存器文件（regfile32）用于读写数据。还有4个流水间寄存器。
接下来就是内存部分与串口部分，这两个部分是参考了去年的比赛代码，将这两个部分结合在一起构成一个完整的模块（SRAM），
这个模块在SRAM读写上主要是提供一些读写信号以及读出写入数据的处理。


以上就是该工程的粗略说明，详细说明还请看design.docx文件。