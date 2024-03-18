/*
  本文件为脉动阵列的输出接口。
  思路：
    直观上，和输入接口的“荷官发牌”相对称，输出接口的工作是serialize。
    但具体来说还有一不同之处：每个PE内部的乘累加(MAC)计算完成的时刻是不一样的，
    因此输出模块无法像输入模块成排喂数据那样“成排”地取出数据，而是必须轮换进行，\
    因此既不存在移位寄存器结构，也用不上乒乓。
    
  实现: 假设有个4*4的阵列，计算完成的顺序就是
        4 3 2 1
        3 2 1 4
        2 1 4 3
        1 4 3 2, 实际上需要取出数据的位置是一条方向为“/”的移动的对角线。
        那么，直接与PE相连的输出接口就是一排mux，根据轮换循环的地址挑选数据。
*/

/*
  寻址器，实质上是个mux
*/
module output_element #( 
  parameter DATA_WIDTH = 8,
  parameter SIZE = 8
) (
  input [$clog2(SIZE)-1:0] address, // 与PE同频 
  input [DATA_WIDTH*SIZE-1:0] in,
  output [DATA_WIDTH-1:0] out
);
  // 寻址输出
  assign out = in[DATA_WIDTH*(SIZE-address)-1 -: DATA_WIDTH];  
endmodule
/*
  用来给寻址器算地址，专门写这个adder是为了指定字宽，不然编译器老warning
*/
module adder #(
  parameter SIZE = 8,
  parameter BIAS = 0
)(
  input [$clog2(SIZE)-1:0] in,
  output [$clog2(SIZE)-1:0] out
);
  assign out = in+BIAS;
endmodule

/*
  直接连结PE阵列的输出模块
*/
module output_array #(
  parameter DATA_WIDTH = 8,
  parameter SIZE = 8 // 默认方阵
) (
  input clk, // 与PE同频
  input [DATA_WIDTH*SIZE*SIZE-1:0] in,
  output [DATA_WIDTH*SIZE-1:0] out
);
  reg [$clog2(SIZE)-1:0] counter = 0;
  wire [$clog2(SIZE)-1:0] address[SIZE-1:0];

  always @(posedge clk)
    if (counter == SIZE-1) counter <= 0; 
    else counter <= counter + 1;

  genvar i; generate
    for(i = 0; i<SIZE; i=i+1) begin: array_of_mux
      adder #(SIZE, i) address_adder(
        counter, address[i]);
      output_element #(DATA_WIDTH, SIZE) mux(
        address[i],
        in[DATA_WIDTH*SIZE*(SIZE-i)-1 -: DATA_WIDTH*SIZE],
        out[DATA_WIDTH*(SIZE-i)-1 -: DATA_WIDTH]
      );
    end
  endgenerate
endmodule

