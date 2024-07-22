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


module singple_kernel #(
  parameter DATA_WIDTH = 16,
  parameter SIZE = 32
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

