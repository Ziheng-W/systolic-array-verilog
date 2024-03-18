// 2d脉动阵列。每个pe使用三个reg（乘累加结果1个，向相邻pe传递数据用2个）
// 编号对应规则：
// 在面积 dim_1*dim_2、字宽 w 的阵列中，记某pe编号为pe[i_1, i_2], 0 <= i_1 <= dim_1
// 则其向下传递数据的reg为 pass_1[i_1, i_2]
//   其向右传递数据的reg为 pass_2[i_1, i_2]
//   其本地的乘累加结果reg为 result[ (i_1*dim_1 + i_2 + 1)*w -1  :  (i_1*dim_1 + i_2)*w ]
//                     即为 result[((i_1*dim_1 + i_2 + 1)*w -1)  -:  w]
//                         
// TODO: 乘法后的量化移位还没做

// `define SERIALIZE 

module systolic #(
  parameter DATA_WIDTH = 16,
  parameter DIM_1 = 3,
  parameter DIM_2 = 3
)(
  input clk,
  input[DATA_WIDTH*DIM_1-1:0] i_1, //向下输入
  input[DATA_WIDTH*DIM_1-1:0] i_2, //向右输入
  output[DATA_WIDTH*DIM_1-1:0] o_1, //向下输出
  output[DATA_WIDTH*DIM_1-1:0] o_2, //向右输出
  // output reg[DATA_WIDTH-1:0] result_,
  // output reg[DATA_WIDTH-1:0] result_ [DIM_1-1:0][DIM_2-1:0],
  output[DATA_WIDTH*DIM_1*DIM_2-1:0] out
);
  // 每个pe向后传递的被乘数
  reg[DATA_WIDTH-1:0] pass_1 [DIM_1-1:0][DIM_2-1:0]; 
  reg[DATA_WIDTH-1:0] pass_2 [DIM_1-1:0][DIM_2-1:0]; 
  reg[DATA_WIDTH-1:0] result [DIM_1-1:0][DIM_2-1:0]; 
  integer m_1, m_2;

  // 初始化
  initial
    for(m_1 = 0; m_1 < DIM_1; m_1 = m_1+1)
      for(m_2 = 0; m_2 < DIM_2; m_2 = m_2+1) begin
        pass_1[m_1][m_2] = 0;
        pass_2[m_1][m_2] = 0;
        result[m_1][m_2] = 0;
      end

  // output[7:0] = result[0][0];

  // 每上升沿，传递一次数据并完成一次乘累加
  always @(posedge clk) begin
    // calculate pe[0,0]
    result[0][0] <= result[0][0] + i_1[DATA_WIDTH-1:0]*i_2[DATA_WIDTH-1:0];
    pass_1[0][0] <= i_1[DATA_WIDTH-1:0];
    pass_2[0][0] <= i_2[DATA_WIDTH-1:0];
    // pe[0:1]~pe[0:dim_2-1]
    for(m_2 = 1; m_2 < DIM_2; m_2 = m_2+1) begin
      result[0][m_2] <= result[0][m_2] + pass_2[0][m_2-1] * i_1[((m_2+1)*DATA_WIDTH-1) -: DATA_WIDTH]; 
      pass_1[0][m_2] <= i_1[((m_2+1)*DATA_WIDTH-1) -: DATA_WIDTH];
      pass_2[0][m_2] <= pass_2[0][m_2-1];
    end
    // pe(1:0)~pe[dim_1-1]
    for(m_1 = 1; m_1 < DIM_1; m_1 = m_1+1) begin
      result[m_1][0] <= result[m_1][0] + pass_1[m_1-1][0] * i_2[((m_1+1)*DATA_WIDTH-1) -: DATA_WIDTH];
      pass_1[m_1][0] <= pass_1[m_1-1][0];
      pass_2[m_1][0] <= i_2[((m_1+1)*DATA_WIDTH-1) -: DATA_WIDTH];
    end
    // all other pe 
    for(m_1 = 1; m_1 < DIM_1; m_1 = m_1+1)
      for(m_2 = 1; m_2 < DIM_2; m_2 = m_2+1) begin
        result[m_1][m_2] <= result[m_1][m_2] + pass_1[m_1-1][m_2] * pass_2[m_1][m_2-1];
        pass_1[m_1][m_2] <= pass_1[m_1-1][m_2]; 
        pass_2[m_1][m_2] <= pass_2[m_1][m_2-1]; 
      end
  end
endmodule
