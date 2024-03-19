// 2d脉动阵列。每个pe使用三个reg（乘累加结果1个，向相邻pe传递数据用2个）
// 编号对应规则：
// 在面积 dim_1*dim_2、字宽 w 的阵列中，记某pe编号为pe[i_1, i_2], 0 <= i_1 <= dim_1
// 则其向下传递数据的reg为 pass_1[i_1, i_2]
//   其向右传递数据的reg为 pass_2[i_1, i_2]
//   其本地的乘累加结果reg为 result[ (i_1*dim_1 + i_2 + 1)*w -1  :  (i_1*dim_1 + i_2)*w ]
//                     即为 result[((i_1*dim_1 + i_2 + 1)*w -1)  -:  w]
//                         
// TODO: 乘法后的量化移位还没做

/*
  PE阵列，具有向阵列两侧的其他阵列传输数据的接口
*/
module systolic #(
  parameter DATA_WIDTH = 16,
  parameter DIM = 3
)(
  input clk,
  input[DATA_WIDTH*DIM-1:0] i_1, //向下输入
  input[DATA_WIDTH*DIM-1:0] i_2, //向右输入
  output[DATA_WIDTH*DIM-1:0] o_1, //向下输出
  output[DATA_WIDTH*DIM-1:0] o_2, //向右输出
  output[DATA_WIDTH*DIM*DIM-1 : 0] out
);
  // 每个pe向后传递的被乘数
  reg[DATA_WIDTH-1 : 0] pass_1 [DIM-1 : 0][DIM-1 : 0];  
  reg[DATA_WIDTH-1 : 0] pass_2 [DIM-1 : 0][DIM-1 : 0]; 
  reg[DATA_WIDTH-1 : 0] result [DIM-1 : 0][DIM-1 : 0]; 
  integer m_1, m_2;

  // 初始化
  initial
    for(m_1 = 0; m_1 < DIM; m_1 = m_1+1)
      for(m_2 = 0; m_2 < DIM; m_2 = m_2+1) begin
        pass_1[m_1][m_2] = 0;
        pass_2[m_1][m_2] = 0;
        result[m_1][m_2] = 0;
      end

  // output[7:0] = result[0][0];

  // 每上升沿，传递一次数据并完成一次乘累加
  always @(posedge clk) begin
    // calculate pe[0,0]
    result[0][0] <= result[0][0] + i_1[DATA_WIDTH-1 : 0]*i_2[DATA_WIDTH-1 : 0];
    pass_1[0][0] <= i_1[DATA_WIDTH-1 : 0];
    pass_2[0][0] <= i_2[DATA_WIDTH-1 : 0];
    // pe[0:1]~pe[0:dim_2-1]
    for(m_2 = 1; m_2 < DIM; m_2 = m_2+1) begin
      result[0][m_2] <= result[0][m_2] + pass_2[0][m_2-1] * i_1[((m_2+1)*DATA_WIDTH-1) -: DATA_WIDTH]; 
      pass_1[0][m_2] <= i_1[((m_2+1)*DATA_WIDTH-1) -: DATA_WIDTH];
      pass_2[0][m_2] <= pass_2[0][m_2-1];
    end
    // pe(1:0)~pe[dim_1-1]
    for(m_1 = 1; m_1 < DIM; m_1 = m_1+1) begin
      result[m_1][0] <= result[m_1][0] + pass_1[m_1-1][0] * i_2[((m_1+1)*DATA_WIDTH-1) -: DATA_WIDTH];
      pass_1[m_1][0] <= pass_1[m_1-1][0];
      pass_2[m_1][0] <= i_2[((m_1+1)*DATA_WIDTH-1) -: DATA_WIDTH];
    end
    // all other pe 
    for(m_1 = 1; m_1 < DIM; m_1 = m_1+1)
      for(m_2 = 1; m_2 < DIM; m_2 = m_2+1) begin
        result[m_1][m_2] <= result[m_1][m_2] + pass_1[m_1-1][m_2] * pass_2[m_1][m_2-1];
        pass_1[m_1][m_2] <= pass_1[m_1-1][m_2]; 
        pass_2[m_1][m_2] <= pass_2[m_1][m_2-1]; 
      end
  end
  // 输出
  genvar o_i; generate // PE结果输出
    for(o_i=0; o_i<DIM; o_i=o_i+1) begin: output_result
      assign out[DATA_WIDTH*DIM*(DIM-o_i)-1 -: DATA_WIDTH*DIM] = 0;
    end
  endgenerate
  genvar o1_i; generate // 方向1输出
    for(o1_i=0; o1_i<DIM; o1_i=o1_i+1) begin: output_1
      assign o_1[DATA_WIDTH*(DIM-o1_i)-1 -: DATA_WIDTH] = pass_1[DIM-1][o1_i];
    end
  endgenerate
  genvar o2_i; generate // 方向2输出
    for(o2_i=0; o2_i<DIM; o2_i=o2_i+1) begin: output_2
      assign o_2[DATA_WIDTH*(DIM-o2_i)-1 -: DATA_WIDTH] = pass_2[DIM-1][o2_i];
    end
  endgenerate
endmodule

/*
  边缘的PE阵列，由于其后没有需要继续传输数据的阵列了，就只安排了计算结果的输出接口
*/
module systolic_edge #(
  parameter DATA_WIDTH = 16,
  parameter DIM = 3
)(
  input clk,
  input[DATA_WIDTH*DIM-1:0] i_1, //向下输入
  input[DATA_WIDTH*DIM-1:0] i_2, //向右输入
  output[DATA_WIDTH*DIM*DIM-1 : 0] out
);
  // 每个pe向后传递的被乘数
  reg[DATA_WIDTH-1 : 0] pass_1 [DIM-1 : 0][DIM-1 : 0];  
  reg[DATA_WIDTH-1 : 0] pass_2 [DIM-1 : 0][DIM-1 : 0]; 
  reg[DATA_WIDTH-1 : 0] result [DIM-1 : 0][DIM-1 : 0]; 
  integer m_1, m_2;

  // 初始化
  initial
    for(m_1 = 0; m_1 < DIM; m_1 = m_1+1)
      for(m_2 = 0; m_2 < DIM; m_2 = m_2+1) begin
        pass_1[m_1][m_2] = 0;
        pass_2[m_1][m_2] = 0;
        result[m_1][m_2] = 0;
      end

  // output[7:0] = result[0][0];

  // 每上升沿，传递一次数据并完成一次乘累加
  always @(posedge clk) begin
    // calculate pe[0,0]
    result[0][0] <= result[0][0] + i_1[DATA_WIDTH-1 : 0]*i_2[DATA_WIDTH-1 : 0];
    pass_1[0][0] <= i_1[DATA_WIDTH-1 : 0];
    pass_2[0][0] <= i_2[DATA_WIDTH-1 : 0];
    // pe[0:1]~pe[0:dim_2-1]
    for(m_2 = 1; m_2 < DIM; m_2 = m_2+1) begin
      result[0][m_2] <= result[0][m_2] + pass_2[0][m_2-1] * i_1[((m_2+1)*DATA_WIDTH-1) -: DATA_WIDTH]; 
      pass_1[0][m_2] <= i_1[((m_2+1)*DATA_WIDTH-1) -: DATA_WIDTH];
      pass_2[0][m_2] <= pass_2[0][m_2-1];
    end
    // pe(1:0)~pe[dim_1-1]
    for(m_1 = 1; m_1 < DIM; m_1 = m_1+1) begin
      result[m_1][0] <= result[m_1][0] + pass_1[m_1-1][0] * i_2[((m_1+1)*DATA_WIDTH-1) -: DATA_WIDTH];
      pass_1[m_1][0] <= pass_1[m_1-1][0];
      pass_2[m_1][0] <= i_2[((m_1+1)*DATA_WIDTH-1) -: DATA_WIDTH];
    end
    // all other pe 
    for(m_1 = 1; m_1 < DIM; m_1 = m_1+1)
      for(m_2 = 1; m_2 < DIM; m_2 = m_2+1) begin
        result[m_1][m_2] <= result[m_1][m_2] + pass_1[m_1-1][m_2] * pass_2[m_1][m_2-1];
        pass_1[m_1][m_2] <= pass_1[m_1-1][m_2]; 
        pass_2[m_1][m_2] <= pass_2[m_1][m_2-1]; 
      end
  end
  // 输出
  genvar o_i; generate // PE结果输出
    for(o_i=0; o_i<DIM; o_i=o_i+1) begin: output_result
      assign out[DATA_WIDTH*DIM*(DIM-o_i)-1 -: DATA_WIDTH*DIM] = 0;
    end
  endgenerate
endmodule
