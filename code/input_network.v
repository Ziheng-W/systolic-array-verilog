/*
  本文件为脉动阵列的输入接口。
  思路： 
    1.
      如下图所示，输入模块从片上的RAM获取数据并喂给阵列。
      脉动阵列的IO有两个约束条件：布线和延时。
      - 如果追求0延时(每个PE直接从RAM取得数据)，布线资源就不够了。
      - 如果压榨布线资源(比如总数据线的位宽只取8bit或更小)，将数据充满一列PE所需的时间就会极长，拖累PE的运算。
      因此，IO设计实质上就是在延时和布线之间取舍，最终在不拖累PE计算速度的前提下尽可能减少布线，即减少线路的并行度。
            in  in  in

      in    PE  PE  PE
      in    PE  PE  PE
      in    PE  PE  PE
    2.
      由上可知IO的实际形式是类似“荷官发牌”的单入多出的分发器。纸牌的出入比即为IO的并行度，\
      并行度越高布线资源用的越多，并行度越低攒够一组纸牌的耗时越久。
      在此基础上进一步优化，我们就得到了乒乓IO：两个荷官一组，其中一个人收牌的时候另一个人发牌，这样始终有一个人在发牌，\
      可以不间断输出，相当于把延时本身封装进了模块内部。
  *** 实现：
    基本组成单元是长度为m的位移寄存器串(shift_reg)。
    将n个长度为m的位移寄存器串并在一起，就得到了面积为 m*n 的寄存器阵列，其时钟周期正比于m，并行度正比于n，一次输出m*n个字长。
*/

/*
  一个如上所述的乒乓移位器，本身不对乒乓进行计算(不然每个shifter都得加一个加法器)。
  使用：
    在后面的input_array里批量实例化。
  优化：
    如果以榨干fpga资源为目的，则DATA_WIDTH可以取实际字宽的倍数，比如实际计算用的8bit，\
    但是某块fpga的flipflop相比于布线资源特别充足，那么代码上的字宽就取16bit，在模块内部就把富余的资源用干净。
*/
module input_element #( // 实质是个带ping-pong的移位寄存器
  parameter DATA_WIDTH = 8,
  parameter SIZE = 8
) (
  input clk,
  input flag, 
  input [DATA_WIDTH-1:0] in,
  output [DATA_WIDTH*SIZE-1:0] out
);
  integer i;
  reg [DATA_WIDTH*SIZE-1:0] local_0 = 0;
  reg [DATA_WIDTH*SIZE-1:0] local_1 = 0;
  
  // output
  assign out_ = flag ? local_1 : local_0;
  
  // refresh
  always @(posedge clk)
    if (flag) begin
      local_0[DATA_WIDTH-1:0] <= in;
      for(i = 0; i<SIZE-1; i=i+1)
        local_0[DATA_WIDTH*(SIZE-i)-1 -: DATA_WIDTH] <= 
        local_0[DATA_WIDTH*(SIZE-i-1)-1 -: DATA_WIDTH];
    end 
    else begin
      local_1[DATA_WIDTH-1:0] <= in;
      for(i = 0; i<SIZE-1; i=i+1) 
        local_1[DATA_WIDTH*(SIZE-i)-1 -: DATA_WIDTH] <= 
        local_1[DATA_WIDTH*(SIZE-i-1)-1 -: DATA_WIDTH];
    end
endmodule

module input_array #( // 对上面的模块打包
  parameter DATA_WIDTH = 8,
  parameter SIZE = 8,
  parameter NUM = 8
) (
  input clk,
  input [DATA_WIDTH*NUM-1 : 0] in,
  output [DATA_WIDTH*SIZE*NUM-1 : 0] out
);
  reg flag = 0; 
  reg [$clog2(SIZE)-1:0] counter = 0;

  // 每size个周期翻转一次flag  
  always @(posedge clk)
    if (counter == SIZE-1) begin
        flag <= ~flag; 
        counter <= 0; 
    end 
    else counter <= counter + 1;

  // 实例化num个shifter
  genvar i; generate
    for(i=0; i<NUM; i=i+1) begin: array_of_shifters 
      input_element #(DATA_WIDTH, SIZE) shifter (
        clk, flag, 
        in[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH], 
        out[(i+1)*DATA_WIDTH*SIZE-1 -: DATA_WIDTH*SIZE]
      ); 
    end
  endgenerate
endmodule



