module single_PE_rounded #(
  parameter DATA_WIDTH = 8,
  parameter Half_WIDTH = 4
)(
  input clk,
  input finish,
  input [DATA_WIDTH-1 : 0] i_up,
  input [DATA_WIDTH-1 : 0] i_left,
  output reg [DATA_WIDTH-1 : 0] o_down,
  output reg [DATA_WIDTH-1 : 0] o_right,
  output reg [DATA_WIDTH-1 : 0] o_result = 0  
);
  reg  [DATA_WIDTH-1 : 0] partial_sum = 0;
  wire [DATA_WIDTH-1 : 0] x;
  assign x = (i_up*i_left) >> Half_WIDTH;
  always @(posedge clk) begin
    o_down      <= i_up;
    o_right     <= i_left;
    o_result    <= finish ? partial_sum : o_result;
    partial_sum <= finish ? x : (partial_sum + x);
  end
endmodule

module single_kernel #(
  parameter SIZE = 8,
  parameter DATA_WIDTH = 16
) (
  input clk,
  input [SIZE*SIZE-1:0] finish,                   //  编号规则：                     
  input [SIZE*DATA_WIDTH-1:0] in_up,              //          n_n ---- n_1                        
  input [SIZE*DATA_WIDTH-1:0] in_left,            //           |        |      
  output [SIZE*DATA_WIDTH-1:0] pass_down,         //           |        |        
  output [SIZE*DATA_WIDTH-1:0] pass_right,        //          1_n ---- 1_1              
  output [SIZE*SIZE*DATA_WIDTH-1:0] out_matrix,   //  
  output [SIZE*DATA_WIDTH-1:0] out_diagonal       //  serialized_index(i,j) = (i-1)*SIZE + j 
);
  genvar i,j,k;
  wire [SIZE*SIZE*DATA_WIDTH-1:0] inner_pass_down;
  wire [SIZE*SIZE*DATA_WIDTH-1:0] inner_pass_right;
  generate
    for (i=SIZE; i>=1; i=i-1) begin
      for (j=SIZE; j>=1; j=j-1) begin
        if (i==SIZE && j==SIZE) begin           // 左上角。the upper-left PE
          single_PE_rounded # (DATA_WIDTH, DATA_WIDTH/2) 
          pe (clk, finish      [(i-1)*SIZE+j-1], 
              in_up            [j*DATA_WIDTH-1                -:DATA_WIDTH], 
              in_left          [i*DATA_WIDTH-1                -:DATA_WIDTH],
              inner_pass_down  [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH], 
              inner_pass_right [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH],
              out_matrix       [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH]);
        end else if (i==SIZE && j!=SIZE) begin  // 最上一行。PEs in the upper-most row
          single_PE_rounded # (DATA_WIDTH, DATA_WIDTH/2) 
          pe (clk, finish      [(i-1)*SIZE+j-1], 
              in_up            [j*DATA_WIDTH-1 -:DATA_WIDTH], 
              inner_pass_right [((i-1)*SIZE+j+1)*DATA_WIDTH-1 -:DATA_WIDTH],
              inner_pass_down  [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH],
              inner_pass_right [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH],
              out_matrix       [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH]);
        end else if (i!=SIZE && j==SIZE) begin  // 最左一列。PEs in the left-most column
          single_PE_rounded # (DATA_WIDTH, DATA_WIDTH/2) 
          pe (clk, finish      [(i-1)*SIZE+j-1], 
              inner_pass_down  [((i-1+1)*SIZE+j)*DATA_WIDTH-1 -:DATA_WIDTH], 
              in_left          [i*DATA_WIDTH-1                -:DATA_WIDTH],
              inner_pass_down  [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH], 
              inner_pass_right [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH],
              out_matrix       [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH]);
        end else begin                          // 其他PE。all other PEs
          single_PE_rounded # (DATA_WIDTH, DATA_WIDTH/2) 
          pe (clk, finish      [(i-1)*SIZE+j-1], 
              inner_pass_down  [((i-1+1)*SIZE+j)*DATA_WIDTH-1 -:DATA_WIDTH], 
              inner_pass_right [((i-1)*SIZE+j+1)*DATA_WIDTH-1 -:DATA_WIDTH],
              inner_pass_down  [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH], 
              inner_pass_right [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH],
              out_matrix       [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH]);
        end end end
  endgenerate
  generate
    for (k=SIZE; k>=1; k=k-1) begin
      // 向下侧阵列传递。pass data downward to other PE arays
      // 向下侧阵列传递。pass data rightward to other PE arays      
      // 输出对角线值。  output results in diagonal position            
      assign  pass_down        [k*DATA_WIDTH-1              -:DATA_WIDTH]
            = inner_pass_down  [((1-1)*SIZE+k)*DATA_WIDTH-1 -:DATA_WIDTH];
      assign  pass_right       [k*DATA_WIDTH-1              -:DATA_WIDTH] 
            = inner_pass_right [((k-1)*SIZE+1)*DATA_WIDTH-1 -:DATA_WIDTH];     
      assign  out_diagonal     [k*DATA_WIDTH-1              -:DATA_WIDTH] 
            = out_matrix       [((k-1)*SIZE+k)*DATA_WIDTH-1 -:DATA_WIDTH];  
    end      
  endgenerate
endmodule

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
      end end end
endmodule

// 高位先出
module serialize #(
  parameter LENGTH = 4,
  parameter BIT_WIDTH = 16
) (
  input clk,
  input write_enable,
  input read_enable,
  input [LENGTH*BIT_WIDTH -1 : 0] in,
  output [BIT_WIDTH-1 : 0] out
);
  reg [BIT_WIDTH*LENGTH-1 : 0] local = 0;
  integer i;
  always @(posedge clk) begin
    if(write_enable == 1 & read_enable == 0) begin
      local <= in;
    end else if(write_enable == 0 & read_enable == 1) begin
      for (i = LENGTH; i>=2; i=i-1) begin
        local   [i*BIT_WIDTH-1     -: BIT_WIDTH] 
        <= local[(i-1)*BIT_WIDTH-1 -: BIT_WIDTH];
      end
    end else local <= local;
  end
  assign out = local[LENGTH*BIT_WIDTH-1 -: BIT_WIDTH];
endmodule

// 串转并
module deserialize #(
  parameter LENGTH = 4,
  parameter BIT_WIDTH = 64
) (
  input clk,
  input read_enable,
  input [BIT_WIDTH-1 : 0] in,
  output [LENGTH*BIT_WIDTH-1 : 0] out
);
  reg [LENGTH*BIT_WIDTH-1 : 0] local = 0;
  integer i;
  always @(posedge clk) begin
    if (read_enable) begin
      for (i = LENGTH; i>=2; i=i-1) begin
        local   [i*BIT_WIDTH-1     -: BIT_WIDTH] 
        <= local[(i-1)*BIT_WIDTH-1 -: BIT_WIDTH];
      end
      local[BIT_WIDTH-1 -: BIT_WIDTH] <= in;
    end else local <= local;
  end
  assign out = local;
endmodule

module shifter #(
  parameter LENGTH = 3,
  parameter DATA_WIDTH = 16
) (
  input clk,
  input enable,
  input [DATA_WIDTH-1 : 0] in,
  output reg [DATA_WIDTH-1 : 0] out = 0
);
  reg [DATA_WIDTH*LENGTH-1 : 0] inner_shifters = 0;
  integer i;
  always @(posedge clk ) begin
    if (enable) begin
      inner_shifters[DATA_WIDTH-1 : 0] <= in;
      out <= inner_shifters[DATA_WIDTH*LENGTH-1 -: DATA_WIDTH];
      for (i=1; i<LENGTH; i=i+1) 
        inner_shifters[DATA_WIDTH*(i+1) - 1 -: DATA_WIDTH] 
        <= inner_shifters[DATA_WIDTH*i - 1 -: DATA_WIDTH];
    end else begin
      out <= out;
      inner_shifters <= inner_shifters;
    end
  end  
endmodule

module triangle_shifter_array #(
  parameter HIGHT = 4,
  parameter DATA_WIDTH = 16 
) (
  input clk,
  input enable,
  input [DATA_WIDTH*HIGHT-1 : 0] in,
  output [DATA_WIDTH*HIGHT-1 : 0] out
);
  reg [DATA_WIDTH-1:0] lowest = 0;
  genvar i;
  assign out[DATA_WIDTH-1 -: DATA_WIDTH] = lowest;
  always @(posedge clk) 
    lowest <= in[DATA_WIDTH-1 -: DATA_WIDTH];
  generate for( i = 1; i< HIGHT; i=i+1) begin
      shifter #(i, DATA_WIDTH) shifter (clk, enable, in[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH], out[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH]);
  end endgenerate
endmodule


/*** ** 正文 ** ***/

// 除了输入以外的部分，先接在一起比较方便

module linked_PE #(
  parameter TILE_SIZE = 8,      // 最小单位体积
  parameter TILE_CNT = 4,       // 一行/列里有几个PE
  parameter DATA_WIDTH = 16,    // 数据位宽
  parameter TOTAL_SIZE = TILE_CNT*TILE_SIZE
) (
  input clk,
  input pass_w_enable,
  input pass_r_enable,
  input [4:0] tile_signal,
  input [TILE_CNT*TOTAL_SIZE*DATA_WIDTH-1:0] in_up,
  input [TILE_CNT*TOTAL_SIZE*DATA_WIDTH-1:0] in_left,
  output [DATA_WIDTH-1:0] pass_down_serial,  
  output [DATA_WIDTH-1:0] pass_right_serial,  
  output [TOTAL_SIZE*DATA_WIDTH-1:0] result_matrix_serial,
  output [TILE_CNT*TILE_CNT*DATA_WIDTH-1:0] result_diagonal_serial
);
  genvar i,j;
  // input connect
  wire [TILE_CNT*TOTAL_SIZE*DATA_WIDTH-1:0] actual_in_up;
  wire [TILE_CNT*TOTAL_SIZE*DATA_WIDTH-1:0] actual_in_left;
  assign actual_in_up[4*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH] = in_up[4*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH];
  assign actual_in_left[4*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH] = in_left[4*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH];
  // pass data connect
  wire [TILE_CNT*TOTAL_SIZE*DATA_WIDTH-1:0] actual_pass_down;
  wire [TILE_CNT*TOTAL_SIZE*DATA_WIDTH-1:0] actual_pass_right;
  serialize #  (TOTAL_SIZE, DATA_WIDTH) pass_down_serializer (clk, pass_w_enable, pass_r_enable, 
                actual_pass_down[1*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH], pass_down_serial);
  serialize #  (TOTAL_SIZE, DATA_WIDTH) pass_right_serializer (clk, pass_w_enable, pass_r_enable, 
                actual_pass_right[1*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH], pass_right_serial);
  // inner connect              
  assign actual_in_up[2*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH] = tile_signal[4] ? //
                in_up[2*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH] : actual_pass_down[3*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH];
  assign actual_in_up[3*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2] = (tile_signal[4] & tile_signal[3]) ? //
                in_up[3*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2] : actual_pass_down[4*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2];  
  assign actual_in_up[5*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2] = (tile_signal[4] & tile_signal[2]) ?
                in_up[5*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2] : actual_pass_down[7*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2];  
  assign actual_in_up[1*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2] = (tile_signal[4] & tile_signal[1])?
                in_up[1*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2] : actual_pass_down[2*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2];
  assign actual_in_up[1*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2] = (tile_signal[4] & tile_signal[0])?
                in_up[1*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2] : actual_pass_down[3*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2];
  assign actual_in_left[2*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH] = tile_signal[4] ? 
                in_left[2*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH] : actual_pass_right[3*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH];
  assign actual_in_left[3*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2] = (tile_signal[4] & tile_signal[3]) ?
                in_left[3*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2] : actual_pass_right[4*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2];  
  assign actual_in_left[5*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2] = (tile_signal[4] & tile_signal[1]) ?
                in_left[5*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2] : actual_pass_right[7*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2];  
  assign actual_in_left[1*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2] = (tile_signal[4] & tile_signal[2])?
                in_left[1*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2] : actual_pass_right[2*TOTAL_SIZE*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH/2];
  assign actual_in_left[1*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2] = (tile_signal[4] & tile_signal[0])?
                in_left[1*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2] : actual_pass_right[3*TOTAL_SIZE*DATA_WIDTH/2-1 -:TOTAL_SIZE*DATA_WIDTH/2];
  // output connect
  wire [TOTAL_SIZE*TOTAL_SIZE*DATA_WIDTH-1:0] out_matrix;
  generate for (i=TOTAL_SIZE; i>=1; i=i-1) begin
    serialize # (TOTAL_SIZE, DATA_WIDTH) result_matrix_serializer (clk, pass_w_enable, pass_r_enable, 
      out_matrix[((i-1)*TOTAL_SIZE+TOTAL_SIZE)*DATA_WIDTH-1 -:TOTAL_SIZE*DATA_WIDTH], result_matrix_serial[i*DATA_WIDTH-1 -:DATA_WIDTH]);
  end endgenerate
  // output diagonal connect
  wire [TILE_CNT*TILE_CNT*TILE_SIZE*DATA_WIDTH-1:0] out_diagonal;
  generate for (i=TILE_CNT*TILE_CNT; i>=1; i=i-1) begin
    serialize # (TILE_SIZE, DATA_WIDTH) result_diagonal_serializer (clk, pass_w_enable, pass_r_enable, 
      out_diagonal[i*TILE_SIZE*DATA_WIDTH-1 -:TILE_SIZE*DATA_WIDTH], result_diagonal_serial[i*DATA_WIDTH-1 -:DATA_WIDTH]);
  end endgenerate
  // finish signal
  wire [TOTAL_SIZE*TOTAL_SIZE-1:0] finish;
  finish_decider # (TOTAL_SIZE, TOTAL_SIZE/2) decider (clk, tile_signal[4], finish);
  // PE
  generate
    for (i=TILE_CNT; i>=1; i=i-1) begin
      for (j=TILE_CNT; j>=1; j=j-1) begin
        single_kernel # (TILE_SIZE, DATA_WIDTH) kernel (clk, finish[((i-1)*TILE_CNT+j)*TILE_SIZE*TILE_SIZE-1 -:TILE_SIZE*TILE_SIZE], 
        actual_in_up[((i-1)*TILE_CNT+j)*TILE_SIZE*DATA_WIDTH-1   -:TILE_SIZE*DATA_WIDTH], 
        actual_in_left[((j-1)*TILE_CNT+i)*TILE_SIZE*DATA_WIDTH-1   -:TILE_SIZE*DATA_WIDTH], 
        actual_pass_down[((i-1)*TILE_CNT+j)*TILE_SIZE*DATA_WIDTH-1   -:TILE_SIZE*DATA_WIDTH], 
        actual_pass_right[((j-1)*TILE_CNT+i)*TILE_SIZE*DATA_WIDTH-1   -:TILE_SIZE*DATA_WIDTH], 
        out_matrix[((i-1)*TILE_CNT+j)*TILE_SIZE*TILE_SIZE*DATA_WIDTH-1 -:TILE_SIZE*TILE_SIZE*DATA_WIDTH],
        out_diagonal[((i-1)*TILE_CNT+j)*TILE_SIZE*DATA_WIDTH-1   -:TILE_SIZE*DATA_WIDTH]
        ); 
      end
    end
  endgenerate
endmodule

