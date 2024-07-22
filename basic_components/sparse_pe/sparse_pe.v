module sparse_PE_rounded #(
  parameter DATA_WIDTH = 8, 
  parameter Half_WIDTH = 4,
  parameter INDEX_SIZE = 3 // 8*8 PE
)(
  input clk,
  input[DATA_WIDTH-1 : 0] i_up,
  input[DATA_WIDTH-1 : 0] i_left,
  input [INDEX_SIZE-1 : 0] index_up,
  input [INDEX_SIZE-1 : 0] index_left,
  output reg [DATA_WIDTH-1 : 0] o_down,
  output reg [DATA_WIDTH-1 : 0] o_right,
  output reg [INDEX_SIZE-1 : 0] index_down,
  output reg [INDEX_SIZE-1 : 0] index_right,
  output reg[DATA_WIDTH-1 : 0] o_result = 0,
  output finished // 普通pe接受finish信号作为输入，稀疏pe自己判断是否finish并将其输出  
);
  reg [DATA_WIDTH-1 : 0] partial_sum = 0;
  reg [INDEX_SIZE+DATA_WIDTH : 0] cache = 0; // 最高位代表存入方向（0上1左），中间INDEX_SIZE位为存入元素的序号，最后DATA_WIDTH位为数据
  reg [INDEX_SIZE+DATA_WIDTH : 0] cache_use = 0; // 最高位代表存入方向（0上1左），中间INDEX_SIZE位为存入元素的序号，最后DATA_WIDTH位为数据
  wire [DATA_WIDTH-1 : 0] delta;
  
  // 传输：无论如何，每个上升沿向下、向后传输一位数据
  always @(posedge clk) begin
    cache_use <= cache;
    o_down <= i_up;
    o_right <= i_left;
    index_down <= index_up;
    index_right <= index_left;    
  end
  // 计算：在计算未完成时，通过比较两个输入的index，分情况处理。若计算完成，什么也不做
  assign delta = (i_up*i_left) >> Half_WIDTH;  // 乘累加增量
  assign finished = (i_up==0) | (i_left==0);   // 判断是否计算完成
  always @(posedge clk) begin
    if (finished == 0) begin
      // 情况1：计算未完成，则result维持不动
      o_result <= o_result;
      if (index_left == index_up) begin
        // 情况1.1：两个输入的序号相等，直接进行乘累加
        partial_sum <= partial_sum + delta;
        cache <= 0; // cache清零
      end 
      else if (index_left < index_up) begin
        // 情况1.2：上方输入序号更大，舍弃左边的输入，存储上方的输入
        cache [INDEX_SIZE+DATA_WIDTH] <= 0;
        cache [INDEX_SIZE+DATA_WIDTH - 1 -: INDEX_SIZE] = index_up;
        cache [DATA_WIDTH-1 : 0] = i_up;
        if (cache_use[INDEX_SIZE+DATA_WIDTH] == 0) begin
          if(cache_use[INDEX_SIZE+DATA_WIDTH-1 -: INDEX_SIZE] == index_left) begin
            partial_sum <= partial_sum + (cache_use[DATA_WIDTH-1 : 0] * i_left) >> Half_WIDTH;
          end
        end else begin
          // todo:
          partial_sum <= partial_sum;
        end
      end 
      else begin
        // 情况1.3：左侧输入序号更大，舍弃上边的输入，存储左侧的输入
        cache [INDEX_SIZE+DATA_WIDTH] <= 1;
        cache [INDEX_SIZE+DATA_WIDTH - 1 -: INDEX_SIZE] = index_left;
        cache [DATA_WIDTH-1 : 0] = i_left;
        if (cache_use[INDEX_SIZE+DATA_WIDTH] == 1) begin
          if(cache_use[INDEX_SIZE+DATA_WIDTH-1 -: INDEX_SIZE] == index_up) begin
            partial_sum <= partial_sum + (cache_use[DATA_WIDTH-1 : 0] * i_up) >> Half_WIDTH;
          end
        end else begin
          // todo:
          partial_sum <= partial_sum;
        end
      end
    end
  end
endmodule