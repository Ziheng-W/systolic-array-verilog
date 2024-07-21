module single_PE_rounded #(
  parameter DATA_WIDTH = 8,
  parameter Half_WIDTH = 4
)(
  input clk,
  input finish,
  input[DATA_WIDTH-1 : 0] i_up,
  input[DATA_WIDTH-1 : 0] i_left,
  output reg[DATA_WIDTH-1 : 0] o_down,
  output reg[DATA_WIDTH-1 : 0] o_right,
  output reg[DATA_WIDTH-1 : 0] o_result = 0  
);
  reg [DATA_WIDTH-1 : 0] partial_sum = 0;
  wire [DATA_WIDTH-1 : 0] x;
  assign x = (i_up*i_left) >> Half_WIDTH;
  always @(posedge clk) begin
    o_down <= i_up;
    o_right <= i_left;
    if(finish) begin
      o_result <= partial_sum;
      partial_sum <= x;
    end else begin
      o_result <= o_result;
      partial_sum <= partial_sum + x;
    end
  end
endmodule


/*
  编号规则：
          n_n    n_1        

          1_n    1_1
  serial_index(i,j) = (i-1)*SIZE + j
*/
module singple_kernel #(
  parameter DATA_WIDTH = 16,
  parameter SIZE = 8
) (
  input clk,
  input [SIZE*SIZE-1:0] finish,
  input [SIZE*DATA_WIDTH-1:0] in_up, 
  input [SIZE*DATA_WIDTH-1:0] in_left, 
  output [SIZE*DATA_WIDTH-1:0] pass_down, 
  output [SIZE*DATA_WIDTH-1:0] pass_right, 
  output [SIZE*SIZE*DATA_WIDTH-1:0] out_matrix,
  output [SIZE*DATA_WIDTH-1:0] out_diagonal
);
  genvar i,j,k;
  wire [SIZE*SIZE*DATA_WIDTH-1:0] inner_pass_down;
  wire [SIZE*SIZE*DATA_WIDTH-1:0] inner_pass_right;
  generate
    for (i=SIZE; i>=1; i=i-1) begin
      for (j=SIZE; j>=1; j=j-1) begin
        if (i==SIZE && j==SIZE) begin // 左上角
          single_PE_rounded # (DATA_WIDTH, DATA_WIDTH/2) 
          pe (clk, finish      [(i-1)*SIZE+j-1], 
              in_up            [j*DATA_WIDTH-1                -:DATA_WIDTH], 
              in_left          [i*DATA_WIDTH-1                -:DATA_WIDTH],
              inner_pass_down  [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH], 
              inner_pass_right [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH],
              out_matrix       [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH]);
        end else if (i==SIZE && j!=SIZE) begin // 最上侧一行
          single_PE_rounded # (DATA_WIDTH, DATA_WIDTH/2) 
          pe (clk, finish      [(i-1)*SIZE+j-1], 
              in_up            [j*DATA_WIDTH-1 -:DATA_WIDTH], 
              inner_pass_right [((i-1)*SIZE+j+1)*DATA_WIDTH-1 -:DATA_WIDTH],
              inner_pass_down  [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH], 
              inner_pass_right [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH],
              out_matrix       [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH]);
        end else if (i!=SIZE && j==SIZE) begin  // 最左侧一列
          single_PE_rounded # (DATA_WIDTH, DATA_WIDTH/2) 
          pe (clk, finish      [(i-1)*SIZE+j-1], 
              inner_pass_down  [((i-1+1)*SIZE+j)*DATA_WIDTH-1 -:DATA_WIDTH], 
              in_left          [i*DATA_WIDTH-1                -:DATA_WIDTH],
              inner_pass_down  [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH], 
              inner_pass_right [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH],
              out_matrix       [((i-1)*SIZE+j)*DATA_WIDTH-1   -:DATA_WIDTH]);
        end else begin
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
    for (j=SIZE; j>=1; j=j-1) begin
      assign pass_down [j*DATA_WIDTH-1              -:DATA_WIDTH] 
     = inner_pass_down [((1-1)*SIZE+j)*DATA_WIDTH-1 -:DATA_WIDTH];
    end
    for (i=SIZE; i>=1; i=i-1) begin
      assign pass_right [i*DATA_WIDTH-1              -:DATA_WIDTH] 
     = inner_pass_right [((i-1)*SIZE+1)*DATA_WIDTH-1 -:DATA_WIDTH];     
    end
  endgenerate
  generate
    for (k=SIZE; k>=1; k=k-1) begin
      assign out_diagonal [k*DATA_WIDTH-1              -:DATA_WIDTH]
           = out_matrix   [((k-1)*SIZE+k)*DATA_WIDTH-1 -:DATA_WIDTH];      
    end
  endgenerate
endmodule