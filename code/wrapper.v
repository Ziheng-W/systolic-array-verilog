/*
  what's in this file:
  将单个PE打包成PE阵列的wrapper。
*/

/*
  地址映射：
  0 ············ n-1
  ·              ·
  ·              ·
  ·              ·
  n2-n ········· n2-1
*/

/*
  每个乘累加PE需要finish信号告诉自己计算完毕，finish_decider()模块用来生成finish信号
*/
module finish_decider #(
  parameter ARRAY_SIZE = 4,
  parameter Half_SIZE = 2
) (
  input clk,
  input tile,
  output reg [ARRAY_SIZE*ARRAY_SIZE -1 : 0] signal = 0
);
  reg unsigned[$clog2(ARRAY_SIZE)-1 : 0] counter = 0;
  reg unsigned[$clog2(ARRAY_SIZE)-1 : 0] counter_tile = 0;
  reg [$clog2(ARRAY_SIZE)-1 : 0] bias = 0;
  reg [$clog2(ARRAY_SIZE)-1 : 0] bias2 = 0;

  integer unsigned i;

  always @(posedge clk ) begin
    counter <= counter+1;
    counter_tile <= counter + 1 + Half_SIZE;

    signal = 0;
    for(i=0; i<ARRAY_SIZE; i=i+1) begin
      bias = ARRAY_SIZE - i + counter;
      signal[bias + ARRAY_SIZE*i] = 1;  
      if(tile) begin
        bias2 = ARRAY_SIZE - i + counter_tile;        
        signal[bias2 + ARRAY_SIZE*i] = 1;  
      end 
    end  
  end
endmodule

module multi(
  input[7:0] a, 
  input[7:0] b, 
  output[15:0]c
  );
  assign c = a * b;
endmodule
