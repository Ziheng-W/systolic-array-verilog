// [PE Array Generater]: size: 8, bit width:16

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

module PE_Array_8_8_16 #(
  parameter BIT_WIDTH = 16,
  parameter SIZE = 8
)(
// finish 信号
  input finish_8_8,  input finish_8_7,  input finish_8_6,  input finish_8_5,  input finish_8_4,  input finish_8_3,  input finish_8_2,  input finish_8_1,
  input finish_7_8,  input finish_7_7,  input finish_7_6,  input finish_7_5,  input finish_7_4,  input finish_7_3,  input finish_7_2,  input finish_7_1,
  input finish_6_8,  input finish_6_7,  input finish_6_6,  input finish_6_5,  input finish_6_4,  input finish_6_3,  input finish_6_2,  input finish_6_1,
  input finish_5_8,  input finish_5_7,  input finish_5_6,  input finish_5_5,  input finish_5_4,  input finish_5_3,  input finish_5_2,  input finish_5_1,
  input finish_4_8,  input finish_4_7,  input finish_4_6,  input finish_4_5,  input finish_4_4,  input finish_4_3,  input finish_4_2,  input finish_4_1,
  input finish_3_8,  input finish_3_7,  input finish_3_6,  input finish_3_5,  input finish_3_4,  input finish_3_3,  input finish_3_2,  input finish_3_1,
  input finish_2_8,  input finish_2_7,  input finish_2_6,  input finish_2_5,  input finish_2_4,  input finish_2_3,  input finish_2_2,  input finish_2_1,
  input finish_1_8,  input finish_1_7,  input finish_1_6,  input finish_1_5,  input finish_1_4,  input finish_1_3,  input finish_1_2,  input finish_1_1,
// 两个方向的 input
  input [BIT_WIDTH-1:0] input_up_8,  input [BIT_WIDTH-1:0] input_up_7,  input [BIT_WIDTH-1:0] input_up_6,  input [BIT_WIDTH-1:0] input_up_5,  input [BIT_WIDTH-1:0] input_up_4,  input [BIT_WIDTH-1:0] input_up_3,  input [BIT_WIDTH-1:0] input_up_2,  input [BIT_WIDTH-1:0] input_up_1,
  input [BIT_WIDTH-1:0] input_left_8,  input [BIT_WIDTH-1:0] input_left_7,  input [BIT_WIDTH-1:0] input_left_6,  input [BIT_WIDTH-1:0] input_left_5,  input [BIT_WIDTH-1:0] input_left_4,  input [BIT_WIDTH-1:0] input_left_3,  input [BIT_WIDTH-1:0] input_left_2,  input [BIT_WIDTH-1:0] input_left_1,
// 两个方向的 pass
  output [BIT_WIDTH-1:0] pass_down_8,  output [BIT_WIDTH-1:0] pass_down_7,  output [BIT_WIDTH-1:0] pass_down_6,  output [BIT_WIDTH-1:0] pass_down_5,  output [BIT_WIDTH-1:0] pass_down_4,  output [BIT_WIDTH-1:0] pass_down_3,  output [BIT_WIDTH-1:0] pass_down_2,  output [BIT_WIDTH-1:0] pass_down_1,
  output [BIT_WIDTH-1:0] pass_right_8,  output [BIT_WIDTH-1:0] pass_right_7,  output [BIT_WIDTH-1:0] pass_right_6,  output [BIT_WIDTH-1:0] pass_right_5,  output [BIT_WIDTH-1:0] pass_right_4,  output [BIT_WIDTH-1:0] pass_right_3,  output [BIT_WIDTH-1:0] pass_right_2,  output [BIT_WIDTH-1:0] pass_right_1,
// 结果输出
  output [BIT_WIDTH-1:0] output_8_8,  output [BIT_WIDTH-1:0] output_8_7,  output [BIT_WIDTH-1:0] output_8_6,  output [BIT_WIDTH-1:0] output_8_5,  output [BIT_WIDTH-1:0] output_8_4,  output [BIT_WIDTH-1:0] output_8_3,  output [BIT_WIDTH-1:0] output_8_2,  output [BIT_WIDTH-1:0] output_8_1,
  output [BIT_WIDTH-1:0] output_7_8,  output [BIT_WIDTH-1:0] output_7_7,  output [BIT_WIDTH-1:0] output_7_6,  output [BIT_WIDTH-1:0] output_7_5,  output [BIT_WIDTH-1:0] output_7_4,  output [BIT_WIDTH-1:0] output_7_3,  output [BIT_WIDTH-1:0] output_7_2,  output [BIT_WIDTH-1:0] output_7_1,
  output [BIT_WIDTH-1:0] output_6_8,  output [BIT_WIDTH-1:0] output_6_7,  output [BIT_WIDTH-1:0] output_6_6,  output [BIT_WIDTH-1:0] output_6_5,  output [BIT_WIDTH-1:0] output_6_4,  output [BIT_WIDTH-1:0] output_6_3,  output [BIT_WIDTH-1:0] output_6_2,  output [BIT_WIDTH-1:0] output_6_1,
  output [BIT_WIDTH-1:0] output_5_8,  output [BIT_WIDTH-1:0] output_5_7,  output [BIT_WIDTH-1:0] output_5_6,  output [BIT_WIDTH-1:0] output_5_5,  output [BIT_WIDTH-1:0] output_5_4,  output [BIT_WIDTH-1:0] output_5_3,  output [BIT_WIDTH-1:0] output_5_2,  output [BIT_WIDTH-1:0] output_5_1,
  output [BIT_WIDTH-1:0] output_4_8,  output [BIT_WIDTH-1:0] output_4_7,  output [BIT_WIDTH-1:0] output_4_6,  output [BIT_WIDTH-1:0] output_4_5,  output [BIT_WIDTH-1:0] output_4_4,  output [BIT_WIDTH-1:0] output_4_3,  output [BIT_WIDTH-1:0] output_4_2,  output [BIT_WIDTH-1:0] output_4_1,
  output [BIT_WIDTH-1:0] output_3_8,  output [BIT_WIDTH-1:0] output_3_7,  output [BIT_WIDTH-1:0] output_3_6,  output [BIT_WIDTH-1:0] output_3_5,  output [BIT_WIDTH-1:0] output_3_4,  output [BIT_WIDTH-1:0] output_3_3,  output [BIT_WIDTH-1:0] output_3_2,  output [BIT_WIDTH-1:0] output_3_1,
  output [BIT_WIDTH-1:0] output_2_8,  output [BIT_WIDTH-1:0] output_2_7,  output [BIT_WIDTH-1:0] output_2_6,  output [BIT_WIDTH-1:0] output_2_5,  output [BIT_WIDTH-1:0] output_2_4,  output [BIT_WIDTH-1:0] output_2_3,  output [BIT_WIDTH-1:0] output_2_2,  output [BIT_WIDTH-1:0] output_2_1,
  output [BIT_WIDTH-1:0] output_1_8,  output [BIT_WIDTH-1:0] output_1_7,  output [BIT_WIDTH-1:0] output_1_6,  output [BIT_WIDTH-1:0] output_1_5,  output [BIT_WIDTH-1:0] output_1_4,  output [BIT_WIDTH-1:0] output_1_3,  output [BIT_WIDTH-1:0] output_1_2,  output [BIT_WIDTH-1:0] output_1_1,

  input clk
);
// interconnect a: from left to right
  wire [BIT_WIDTH-1:0] inner_a_8_8;  wire [BIT_WIDTH-1:0] inner_a_8_7;  wire [BIT_WIDTH-1:0] inner_a_8_6;  wire [BIT_WIDTH-1:0] inner_a_8_5;  wire [BIT_WIDTH-1:0] inner_a_8_4;  wire [BIT_WIDTH-1:0] inner_a_8_3;  wire [BIT_WIDTH-1:0] inner_a_8_2;
  wire [BIT_WIDTH-1:0] inner_a_7_8;  wire [BIT_WIDTH-1:0] inner_a_7_7;  wire [BIT_WIDTH-1:0] inner_a_7_6;  wire [BIT_WIDTH-1:0] inner_a_7_5;  wire [BIT_WIDTH-1:0] inner_a_7_4;  wire [BIT_WIDTH-1:0] inner_a_7_3;  wire [BIT_WIDTH-1:0] inner_a_7_2;
  wire [BIT_WIDTH-1:0] inner_a_6_8;  wire [BIT_WIDTH-1:0] inner_a_6_7;  wire [BIT_WIDTH-1:0] inner_a_6_6;  wire [BIT_WIDTH-1:0] inner_a_6_5;  wire [BIT_WIDTH-1:0] inner_a_6_4;  wire [BIT_WIDTH-1:0] inner_a_6_3;  wire [BIT_WIDTH-1:0] inner_a_6_2;
  wire [BIT_WIDTH-1:0] inner_a_5_8;  wire [BIT_WIDTH-1:0] inner_a_5_7;  wire [BIT_WIDTH-1:0] inner_a_5_6;  wire [BIT_WIDTH-1:0] inner_a_5_5;  wire [BIT_WIDTH-1:0] inner_a_5_4;  wire [BIT_WIDTH-1:0] inner_a_5_3;  wire [BIT_WIDTH-1:0] inner_a_5_2;
  wire [BIT_WIDTH-1:0] inner_a_4_8;  wire [BIT_WIDTH-1:0] inner_a_4_7;  wire [BIT_WIDTH-1:0] inner_a_4_6;  wire [BIT_WIDTH-1:0] inner_a_4_5;  wire [BIT_WIDTH-1:0] inner_a_4_4;  wire [BIT_WIDTH-1:0] inner_a_4_3;  wire [BIT_WIDTH-1:0] inner_a_4_2;
  wire [BIT_WIDTH-1:0] inner_a_3_8;  wire [BIT_WIDTH-1:0] inner_a_3_7;  wire [BIT_WIDTH-1:0] inner_a_3_6;  wire [BIT_WIDTH-1:0] inner_a_3_5;  wire [BIT_WIDTH-1:0] inner_a_3_4;  wire [BIT_WIDTH-1:0] inner_a_3_3;  wire [BIT_WIDTH-1:0] inner_a_3_2;
  wire [BIT_WIDTH-1:0] inner_a_2_8;  wire [BIT_WIDTH-1:0] inner_a_2_7;  wire [BIT_WIDTH-1:0] inner_a_2_6;  wire [BIT_WIDTH-1:0] inner_a_2_5;  wire [BIT_WIDTH-1:0] inner_a_2_4;  wire [BIT_WIDTH-1:0] inner_a_2_3;  wire [BIT_WIDTH-1:0] inner_a_2_2;
  wire [BIT_WIDTH-1:0] inner_a_1_8;  wire [BIT_WIDTH-1:0] inner_a_1_7;  wire [BIT_WIDTH-1:0] inner_a_1_6;  wire [BIT_WIDTH-1:0] inner_a_1_5;  wire [BIT_WIDTH-1:0] inner_a_1_4;  wire [BIT_WIDTH-1:0] inner_a_1_3;  wire [BIT_WIDTH-1:0] inner_a_1_2;
// interconnect b: from up to low
  wire [BIT_WIDTH-1:0] inner_b_8_8;  wire [BIT_WIDTH-1:0] inner_b_8_7;  wire [BIT_WIDTH-1:0] inner_b_8_6;  wire [BIT_WIDTH-1:0] inner_b_8_5;  wire [BIT_WIDTH-1:0] inner_b_8_4;  wire [BIT_WIDTH-1:0] inner_b_8_3;  wire [BIT_WIDTH-1:0] inner_b_8_2;  wire [BIT_WIDTH-1:0] inner_b_8_1;
  wire [BIT_WIDTH-1:0] inner_b_7_8;  wire [BIT_WIDTH-1:0] inner_b_7_7;  wire [BIT_WIDTH-1:0] inner_b_7_6;  wire [BIT_WIDTH-1:0] inner_b_7_5;  wire [BIT_WIDTH-1:0] inner_b_7_4;  wire [BIT_WIDTH-1:0] inner_b_7_3;  wire [BIT_WIDTH-1:0] inner_b_7_2;  wire [BIT_WIDTH-1:0] inner_b_7_1;
  wire [BIT_WIDTH-1:0] inner_b_6_8;  wire [BIT_WIDTH-1:0] inner_b_6_7;  wire [BIT_WIDTH-1:0] inner_b_6_6;  wire [BIT_WIDTH-1:0] inner_b_6_5;  wire [BIT_WIDTH-1:0] inner_b_6_4;  wire [BIT_WIDTH-1:0] inner_b_6_3;  wire [BIT_WIDTH-1:0] inner_b_6_2;  wire [BIT_WIDTH-1:0] inner_b_6_1;
  wire [BIT_WIDTH-1:0] inner_b_5_8;  wire [BIT_WIDTH-1:0] inner_b_5_7;  wire [BIT_WIDTH-1:0] inner_b_5_6;  wire [BIT_WIDTH-1:0] inner_b_5_5;  wire [BIT_WIDTH-1:0] inner_b_5_4;  wire [BIT_WIDTH-1:0] inner_b_5_3;  wire [BIT_WIDTH-1:0] inner_b_5_2;  wire [BIT_WIDTH-1:0] inner_b_5_1;
  wire [BIT_WIDTH-1:0] inner_b_4_8;  wire [BIT_WIDTH-1:0] inner_b_4_7;  wire [BIT_WIDTH-1:0] inner_b_4_6;  wire [BIT_WIDTH-1:0] inner_b_4_5;  wire [BIT_WIDTH-1:0] inner_b_4_4;  wire [BIT_WIDTH-1:0] inner_b_4_3;  wire [BIT_WIDTH-1:0] inner_b_4_2;  wire [BIT_WIDTH-1:0] inner_b_4_1;
  wire [BIT_WIDTH-1:0] inner_b_3_8;  wire [BIT_WIDTH-1:0] inner_b_3_7;  wire [BIT_WIDTH-1:0] inner_b_3_6;  wire [BIT_WIDTH-1:0] inner_b_3_5;  wire [BIT_WIDTH-1:0] inner_b_3_4;  wire [BIT_WIDTH-1:0] inner_b_3_3;  wire [BIT_WIDTH-1:0] inner_b_3_2;  wire [BIT_WIDTH-1:0] inner_b_3_1;
  wire [BIT_WIDTH-1:0] inner_b_2_8;  wire [BIT_WIDTH-1:0] inner_b_2_7;  wire [BIT_WIDTH-1:0] inner_b_2_6;  wire [BIT_WIDTH-1:0] inner_b_2_5;  wire [BIT_WIDTH-1:0] inner_b_2_4;  wire [BIT_WIDTH-1:0] inner_b_2_3;  wire [BIT_WIDTH-1:0] inner_b_2_2;  wire [BIT_WIDTH-1:0] inner_b_2_1;
// pe
  single_PE_rounded # (16, 8) pe_8_8 (clk, finish_8_8, input_up_8, input_left_8, inner_b_8_8, inner_a_8_8, output_8_8);
  single_PE_rounded # (16, 8) pe_8_7 (clk, finish_8_7, input_up_7, inner_a_8_8, inner_b_8_7, inner_a_8_7, output_8_7);
  single_PE_rounded # (16, 8) pe_8_6 (clk, finish_8_6, input_up_6, inner_a_8_7, inner_b_8_6, inner_a_8_6, output_8_6);
  single_PE_rounded # (16, 8) pe_8_5 (clk, finish_8_5, input_up_5, inner_a_8_6, inner_b_8_5, inner_a_8_5, output_8_5);
  single_PE_rounded # (16, 8) pe_8_4 (clk, finish_8_4, input_up_4, inner_a_8_5, inner_b_8_4, inner_a_8_4, output_8_4);
  single_PE_rounded # (16, 8) pe_8_3 (clk, finish_8_3, input_up_3, inner_a_8_4, inner_b_8_3, inner_a_8_3, output_8_3);
  single_PE_rounded # (16, 8) pe_8_2 (clk, finish_8_2, input_up_2, inner_a_8_3, inner_b_8_2, inner_a_8_2, output_8_2);
  single_PE_rounded # (16, 8) pe_8_1 (clk, finish_8_1, input_up_1, inner_a_8_2, inner_b_8_1, pass_right_8, output_8_1);
  single_PE_rounded # (16, 8) pe_7_8 (clk, finish_7_8, inner_b_8_8, input_left_7, inner_b_7_8, inner_a_7_8, output_7_8);
  single_PE_rounded # (16, 8) pe_7_7 (clk, finish_7_7, inner_b_8_7, inner_a_7_8, inner_b_7_7, inner_a_7_7, output_7_7);
  single_PE_rounded # (16, 8) pe_7_6 (clk, finish_7_6, inner_b_8_6, inner_a_7_7, inner_b_7_6, inner_a_7_6, output_7_6);
  single_PE_rounded # (16, 8) pe_7_5 (clk, finish_7_5, inner_b_8_5, inner_a_7_6, inner_b_7_5, inner_a_7_5, output_7_5);
  single_PE_rounded # (16, 8) pe_7_4 (clk, finish_7_4, inner_b_8_4, inner_a_7_5, inner_b_7_4, inner_a_7_4, output_7_4);
  single_PE_rounded # (16, 8) pe_7_3 (clk, finish_7_3, inner_b_8_3, inner_a_7_4, inner_b_7_3, inner_a_7_3, output_7_3);
  single_PE_rounded # (16, 8) pe_7_2 (clk, finish_7_2, inner_b_8_2, inner_a_7_3, inner_b_7_2, inner_a_7_2, output_7_2);
  single_PE_rounded # (16, 8) pe_7_1 (clk, finish_7_1, inner_b_8_1, inner_a_7_2, inner_b_7_1, pass_right_7, output_7_1);
  single_PE_rounded # (16, 8) pe_6_8 (clk, finish_6_8, inner_b_7_8, input_left_6, inner_b_6_8, inner_a_6_8, output_6_8);
  single_PE_rounded # (16, 8) pe_6_7 (clk, finish_6_7, inner_b_7_7, inner_a_6_8, inner_b_6_7, inner_a_6_7, output_6_7);
  single_PE_rounded # (16, 8) pe_6_6 (clk, finish_6_6, inner_b_7_6, inner_a_6_7, inner_b_6_6, inner_a_6_6, output_6_6);
  single_PE_rounded # (16, 8) pe_6_5 (clk, finish_6_5, inner_b_7_5, inner_a_6_6, inner_b_6_5, inner_a_6_5, output_6_5);
  single_PE_rounded # (16, 8) pe_6_4 (clk, finish_6_4, inner_b_7_4, inner_a_6_5, inner_b_6_4, inner_a_6_4, output_6_4);
  single_PE_rounded # (16, 8) pe_6_3 (clk, finish_6_3, inner_b_7_3, inner_a_6_4, inner_b_6_3, inner_a_6_3, output_6_3);
  single_PE_rounded # (16, 8) pe_6_2 (clk, finish_6_2, inner_b_7_2, inner_a_6_3, inner_b_6_2, inner_a_6_2, output_6_2);
  single_PE_rounded # (16, 8) pe_6_1 (clk, finish_6_1, inner_b_7_1, inner_a_6_2, inner_b_6_1, pass_right_6, output_6_1);
  single_PE_rounded # (16, 8) pe_5_8 (clk, finish_5_8, inner_b_6_8, input_left_5, inner_b_5_8, inner_a_5_8, output_5_8);
  single_PE_rounded # (16, 8) pe_5_7 (clk, finish_5_7, inner_b_6_7, inner_a_5_8, inner_b_5_7, inner_a_5_7, output_5_7);
  single_PE_rounded # (16, 8) pe_5_6 (clk, finish_5_6, inner_b_6_6, inner_a_5_7, inner_b_5_6, inner_a_5_6, output_5_6);
  single_PE_rounded # (16, 8) pe_5_5 (clk, finish_5_5, inner_b_6_5, inner_a_5_6, inner_b_5_5, inner_a_5_5, output_5_5);
  single_PE_rounded # (16, 8) pe_5_4 (clk, finish_5_4, inner_b_6_4, inner_a_5_5, inner_b_5_4, inner_a_5_4, output_5_4);
  single_PE_rounded # (16, 8) pe_5_3 (clk, finish_5_3, inner_b_6_3, inner_a_5_4, inner_b_5_3, inner_a_5_3, output_5_3);
  single_PE_rounded # (16, 8) pe_5_2 (clk, finish_5_2, inner_b_6_2, inner_a_5_3, inner_b_5_2, inner_a_5_2, output_5_2);
  single_PE_rounded # (16, 8) pe_5_1 (clk, finish_5_1, inner_b_6_1, inner_a_5_2, inner_b_5_1, pass_right_5, output_5_1);
  single_PE_rounded # (16, 8) pe_4_8 (clk, finish_4_8, inner_b_5_8, input_left_4, inner_b_4_8, inner_a_4_8, output_4_8);
  single_PE_rounded # (16, 8) pe_4_7 (clk, finish_4_7, inner_b_5_7, inner_a_4_8, inner_b_4_7, inner_a_4_7, output_4_7);
  single_PE_rounded # (16, 8) pe_4_6 (clk, finish_4_6, inner_b_5_6, inner_a_4_7, inner_b_4_6, inner_a_4_6, output_4_6);
  single_PE_rounded # (16, 8) pe_4_5 (clk, finish_4_5, inner_b_5_5, inner_a_4_6, inner_b_4_5, inner_a_4_5, output_4_5);
  single_PE_rounded # (16, 8) pe_4_4 (clk, finish_4_4, inner_b_5_4, inner_a_4_5, inner_b_4_4, inner_a_4_4, output_4_4);
  single_PE_rounded # (16, 8) pe_4_3 (clk, finish_4_3, inner_b_5_3, inner_a_4_4, inner_b_4_3, inner_a_4_3, output_4_3);
  single_PE_rounded # (16, 8) pe_4_2 (clk, finish_4_2, inner_b_5_2, inner_a_4_3, inner_b_4_2, inner_a_4_2, output_4_2);
  single_PE_rounded # (16, 8) pe_4_1 (clk, finish_4_1, inner_b_5_1, inner_a_4_2, inner_b_4_1, pass_right_4, output_4_1);
  single_PE_rounded # (16, 8) pe_3_8 (clk, finish_3_8, inner_b_4_8, input_left_3, inner_b_3_8, inner_a_3_8, output_3_8);
  single_PE_rounded # (16, 8) pe_3_7 (clk, finish_3_7, inner_b_4_7, inner_a_3_8, inner_b_3_7, inner_a_3_7, output_3_7);
  single_PE_rounded # (16, 8) pe_3_6 (clk, finish_3_6, inner_b_4_6, inner_a_3_7, inner_b_3_6, inner_a_3_6, output_3_6);
  single_PE_rounded # (16, 8) pe_3_5 (clk, finish_3_5, inner_b_4_5, inner_a_3_6, inner_b_3_5, inner_a_3_5, output_3_5);
  single_PE_rounded # (16, 8) pe_3_4 (clk, finish_3_4, inner_b_4_4, inner_a_3_5, inner_b_3_4, inner_a_3_4, output_3_4);
  single_PE_rounded # (16, 8) pe_3_3 (clk, finish_3_3, inner_b_4_3, inner_a_3_4, inner_b_3_3, inner_a_3_3, output_3_3);
  single_PE_rounded # (16, 8) pe_3_2 (clk, finish_3_2, inner_b_4_2, inner_a_3_3, inner_b_3_2, inner_a_3_2, output_3_2);
  single_PE_rounded # (16, 8) pe_3_1 (clk, finish_3_1, inner_b_4_1, inner_a_3_2, inner_b_3_1, pass_right_3, output_3_1);
  single_PE_rounded # (16, 8) pe_2_8 (clk, finish_2_8, inner_b_3_8, input_left_2, inner_b_2_8, inner_a_2_8, output_2_8);
  single_PE_rounded # (16, 8) pe_2_7 (clk, finish_2_7, inner_b_3_7, inner_a_2_8, inner_b_2_7, inner_a_2_7, output_2_7);
  single_PE_rounded # (16, 8) pe_2_6 (clk, finish_2_6, inner_b_3_6, inner_a_2_7, inner_b_2_6, inner_a_2_6, output_2_6);
  single_PE_rounded # (16, 8) pe_2_5 (clk, finish_2_5, inner_b_3_5, inner_a_2_6, inner_b_2_5, inner_a_2_5, output_2_5);
  single_PE_rounded # (16, 8) pe_2_4 (clk, finish_2_4, inner_b_3_4, inner_a_2_5, inner_b_2_4, inner_a_2_4, output_2_4);
  single_PE_rounded # (16, 8) pe_2_3 (clk, finish_2_3, inner_b_3_3, inner_a_2_4, inner_b_2_3, inner_a_2_3, output_2_3);
  single_PE_rounded # (16, 8) pe_2_2 (clk, finish_2_2, inner_b_3_2, inner_a_2_3, inner_b_2_2, inner_a_2_2, output_2_2);
  single_PE_rounded # (16, 8) pe_2_1 (clk, finish_2_1, inner_b_3_1, inner_a_2_2, inner_b_2_1, pass_right_2, output_2_1);
  single_PE_rounded # (16, 8) pe_1_8 (clk, finish_1_8, inner_b_2_8, input_left_1, pass_down_8, inner_a_1_8, output_1_8);
  single_PE_rounded # (16, 8) pe_1_7 (clk, finish_1_7, inner_b_2_7, inner_a_1_8, pass_down_7, inner_a_1_7, output_1_7);
  single_PE_rounded # (16, 8) pe_1_6 (clk, finish_1_6, inner_b_2_6, inner_a_1_7, pass_down_6, inner_a_1_6, output_1_6);
  single_PE_rounded # (16, 8) pe_1_5 (clk, finish_1_5, inner_b_2_5, inner_a_1_6, pass_down_5, inner_a_1_5, output_1_5);
  single_PE_rounded # (16, 8) pe_1_4 (clk, finish_1_4, inner_b_2_4, inner_a_1_5, pass_down_4, inner_a_1_4, output_1_4);
  single_PE_rounded # (16, 8) pe_1_3 (clk, finish_1_3, inner_b_2_3, inner_a_1_4, pass_down_3, inner_a_1_3, output_1_3);
  single_PE_rounded # (16, 8) pe_1_2 (clk, finish_1_2, inner_b_2_2, inner_a_1_3, pass_down_2, inner_a_1_2, output_1_2);
  single_PE_rounded # (16, 8) pe_1_1 (clk, finish_1_1, inner_b_2_1, inner_a_1_2, pass_down_1, pass_right_1, output_1_1);
endmodule

module wrapper_8_8_16 #(
  parameter BIT_WIDTH = 16,
  parameter SIZE = 8
)(
// 两个方向的 input
  input [BIT_WIDTH-1:0] input_up_8,  input [BIT_WIDTH-1:0] input_up_7,  input [BIT_WIDTH-1:0] input_up_6,  input [BIT_WIDTH-1:0] input_up_5,  input [BIT_WIDTH-1:0] input_up_4,  input [BIT_WIDTH-1:0] input_up_3,  input [BIT_WIDTH-1:0] input_up_2,  input [BIT_WIDTH-1:0] input_up_1,
  input [BIT_WIDTH-1:0] input_left_8,  input [BIT_WIDTH-1:0] input_left_7,  input [BIT_WIDTH-1:0] input_left_6,  input [BIT_WIDTH-1:0] input_left_5,  input [BIT_WIDTH-1:0] input_left_4,  input [BIT_WIDTH-1:0] input_left_3,  input [BIT_WIDTH-1:0] input_left_2,  input [BIT_WIDTH-1:0] input_left_1,
// 两个方向的 pass
  output [BIT_WIDTH-1:0] pass_down_8,  output [BIT_WIDTH-1:0] pass_down_7,  output [BIT_WIDTH-1:0] pass_down_6,  output [BIT_WIDTH-1:0] pass_down_5,  output [BIT_WIDTH-1:0] pass_down_4,  output [BIT_WIDTH-1:0] pass_down_3,  output [BIT_WIDTH-1:0] pass_down_2,  output [BIT_WIDTH-1:0] pass_down_1,
  output [BIT_WIDTH-1:0] pass_right_8,  output [BIT_WIDTH-1:0] pass_right_7,  output [BIT_WIDTH-1:0] pass_right_6,  output [BIT_WIDTH-1:0] pass_right_5,  output [BIT_WIDTH-1:0] pass_right_4,  output [BIT_WIDTH-1:0] pass_right_3,  output [BIT_WIDTH-1:0] pass_right_2,  output [BIT_WIDTH-1:0] pass_right_1,
// 结果输出
  output [BIT_WIDTH-1:0] output_8_8,  output [BIT_WIDTH-1:0] output_8_7,  output [BIT_WIDTH-1:0] output_8_6,  output [BIT_WIDTH-1:0] output_8_5,  output [BIT_WIDTH-1:0] output_8_4,  output [BIT_WIDTH-1:0] output_8_3,  output [BIT_WIDTH-1:0] output_8_2,  output [BIT_WIDTH-1:0] output_8_1,
  output [BIT_WIDTH-1:0] output_7_8,  output [BIT_WIDTH-1:0] output_7_7,  output [BIT_WIDTH-1:0] output_7_6,  output [BIT_WIDTH-1:0] output_7_5,  output [BIT_WIDTH-1:0] output_7_4,  output [BIT_WIDTH-1:0] output_7_3,  output [BIT_WIDTH-1:0] output_7_2,  output [BIT_WIDTH-1:0] output_7_1,
  output [BIT_WIDTH-1:0] output_6_8,  output [BIT_WIDTH-1:0] output_6_7,  output [BIT_WIDTH-1:0] output_6_6,  output [BIT_WIDTH-1:0] output_6_5,  output [BIT_WIDTH-1:0] output_6_4,  output [BIT_WIDTH-1:0] output_6_3,  output [BIT_WIDTH-1:0] output_6_2,  output [BIT_WIDTH-1:0] output_6_1,
  output [BIT_WIDTH-1:0] output_5_8,  output [BIT_WIDTH-1:0] output_5_7,  output [BIT_WIDTH-1:0] output_5_6,  output [BIT_WIDTH-1:0] output_5_5,  output [BIT_WIDTH-1:0] output_5_4,  output [BIT_WIDTH-1:0] output_5_3,  output [BIT_WIDTH-1:0] output_5_2,  output [BIT_WIDTH-1:0] output_5_1,
  output [BIT_WIDTH-1:0] output_4_8,  output [BIT_WIDTH-1:0] output_4_7,  output [BIT_WIDTH-1:0] output_4_6,  output [BIT_WIDTH-1:0] output_4_5,  output [BIT_WIDTH-1:0] output_4_4,  output [BIT_WIDTH-1:0] output_4_3,  output [BIT_WIDTH-1:0] output_4_2,  output [BIT_WIDTH-1:0] output_4_1,
  output [BIT_WIDTH-1:0] output_3_8,  output [BIT_WIDTH-1:0] output_3_7,  output [BIT_WIDTH-1:0] output_3_6,  output [BIT_WIDTH-1:0] output_3_5,  output [BIT_WIDTH-1:0] output_3_4,  output [BIT_WIDTH-1:0] output_3_3,  output [BIT_WIDTH-1:0] output_3_2,  output [BIT_WIDTH-1:0] output_3_1,
  output [BIT_WIDTH-1:0] output_2_8,  output [BIT_WIDTH-1:0] output_2_7,  output [BIT_WIDTH-1:0] output_2_6,  output [BIT_WIDTH-1:0] output_2_5,  output [BIT_WIDTH-1:0] output_2_4,  output [BIT_WIDTH-1:0] output_2_3,  output [BIT_WIDTH-1:0] output_2_2,  output [BIT_WIDTH-1:0] output_2_1,
  output [BIT_WIDTH-1:0] output_1_8,  output [BIT_WIDTH-1:0] output_1_7,  output [BIT_WIDTH-1:0] output_1_6,  output [BIT_WIDTH-1:0] output_1_5,  output [BIT_WIDTH-1:0] output_1_4,  output [BIT_WIDTH-1:0] output_1_3,  output [BIT_WIDTH-1:0] output_1_2,  output [BIT_WIDTH-1:0] output_1_1,
  input tile,
  input clk
);
  // 实例化output decider
  wire [63:0] finish;
  finish_decider #(8, 4) finish_decider_0 (clk, tile, finish);
  // 实例化纯阵列
  PE_Array_8_8_16 #(16,8) array (
    finish[0],    finish[1],    finish[2],    finish[3],    finish[4],    finish[5],    finish[6],    finish[7],
    finish[8],    finish[9],    finish[10],    finish[11],    finish[12],    finish[13],    finish[14],    finish[15],
    finish[16],    finish[17],    finish[18],    finish[19],    finish[20],    finish[21],    finish[22],    finish[23],
    finish[24],    finish[25],    finish[26],    finish[27],    finish[28],    finish[29],    finish[30],    finish[31],
    finish[32],    finish[33],    finish[34],    finish[35],    finish[36],    finish[37],    finish[38],    finish[39],
    finish[40],    finish[41],    finish[42],    finish[43],    finish[44],    finish[45],    finish[46],    finish[47],
    finish[48],    finish[49],    finish[50],    finish[51],    finish[52],    finish[53],    finish[54],    finish[55],
    finish[56],    finish[57],    finish[58],    finish[59],    finish[60],    finish[61],    finish[62],    finish[63],
    // 两个方向的 input
    input_up_8,    input_up_7,    input_up_6,    input_up_5,    input_up_4,    input_up_3,    input_up_2,    input_up_1,
    input_left_8,    input_left_7,    input_left_6,    input_left_5,    input_left_4,    input_left_3,    input_left_2,    input_left_1,
    // 两个方向的 pass
    pass_down_8,    pass_down_7,    pass_down_6,    pass_down_5,    pass_down_4,    pass_down_3,    pass_down_2,    pass_down_1,
    pass_right_8,    pass_right_7,    pass_right_6,    pass_right_5,    pass_right_4,    pass_right_3,    pass_right_2,    pass_right_1,
    // 结果输出
    output_8_8,    output_8_7,    output_8_6,    output_8_5,    output_8_4,    output_8_3,    output_8_2,    output_8_1,
    output_7_8,    output_7_7,    output_7_6,    output_7_5,    output_7_4,    output_7_3,    output_7_2,    output_7_1,
    output_6_8,    output_6_7,    output_6_6,    output_6_5,    output_6_4,    output_6_3,    output_6_2,    output_6_1,
    output_5_8,    output_5_7,    output_5_6,    output_5_5,    output_5_4,    output_5_3,    output_5_2,    output_5_1,
    output_4_8,    output_4_7,    output_4_6,    output_4_5,    output_4_4,    output_4_3,    output_4_2,    output_4_1,
    output_3_8,    output_3_7,    output_3_6,    output_3_5,    output_3_4,    output_3_3,    output_3_2,    output_3_1,
    output_2_8,    output_2_7,    output_2_6,    output_2_5,    output_2_4,    output_2_3,    output_2_2,    output_2_1,
    output_1_8,    output_1_7,    output_1_6,    output_1_5,    output_1_4,    output_1_3,    output_1_2,    output_1_1,
    clk
    );
endmodule
