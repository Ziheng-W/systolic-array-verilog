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

// [PE Array Generater]: size: 4, bit width:16

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

module PE_Array_4_4_16 #(
  parameter BIT_WIDTH = 16,
  parameter SIZE = 4
)(
// 两个方向的 input
  input [BIT_WIDTH-1:0] input_up_4,  input [BIT_WIDTH-1:0] input_up_3,  input [BIT_WIDTH-1:0] input_up_2,  input [BIT_WIDTH-1:0] input_up_1,
  input [BIT_WIDTH-1:0] input_left_4,  input [BIT_WIDTH-1:0] input_left_3,  input [BIT_WIDTH-1:0] input_left_2,  input [BIT_WIDTH-1:0] input_left_1,
// 两个方向的 pass
  // output [BIT_WIDTH-1:0] pass_down_4,  output [BIT_WIDTH-1:0] pass_down_3,  output [BIT_WIDTH-1:0] pass_down_2,  output [BIT_WIDTH-1:0] pass_down_1,
  // output [BIT_WIDTH-1:0] pass_right_4,  output [BIT_WIDTH-1:0] pass_right_3,  output [BIT_WIDTH-1:0] pass_right_2,  output [BIT_WIDTH-1:0] pass_right_1,
  output [BIT_WIDTH-1:0] pass_down_se,
  output [BIT_WIDTH-1:0] pass_right_se,
// 结果输出
  output [BIT_WIDTH-1:0] output_4, output [BIT_WIDTH-1:0] output_3, output [BIT_WIDTH-1:0] output_2, output [BIT_WIDTH-1:0] output_1,
  input tile, input r_e, input w_e,
  input clk
);
// interconnect a: from left to right
  wire [BIT_WIDTH-1:0] inner_a_4_4;  wire [BIT_WIDTH-1:0] inner_a_4_3;  wire [BIT_WIDTH-1:0] inner_a_4_2;
  wire [BIT_WIDTH-1:0] inner_a_3_4;  wire [BIT_WIDTH-1:0] inner_a_3_3;  wire [BIT_WIDTH-1:0] inner_a_3_2;
  wire [BIT_WIDTH-1:0] inner_a_2_4;  wire [BIT_WIDTH-1:0] inner_a_2_3;  wire [BIT_WIDTH-1:0] inner_a_2_2;
  wire [BIT_WIDTH-1:0] inner_a_1_4;  wire [BIT_WIDTH-1:0] inner_a_1_3;  wire [BIT_WIDTH-1:0] inner_a_1_2;
// interconnect b: from up to low
  wire [BIT_WIDTH-1:0] inner_b_4_4;  wire [BIT_WIDTH-1:0] inner_b_4_3;  wire [BIT_WIDTH-1:0] inner_b_4_2;  wire [BIT_WIDTH-1:0] inner_b_4_1;
  wire [BIT_WIDTH-1:0] inner_b_3_4;  wire [BIT_WIDTH-1:0] inner_b_3_3;  wire [BIT_WIDTH-1:0] inner_b_3_2;  wire [BIT_WIDTH-1:0] inner_b_3_1;
  wire [BIT_WIDTH-1:0] inner_b_2_4;  wire [BIT_WIDTH-1:0] inner_b_2_3;  wire [BIT_WIDTH-1:0] inner_b_2_2;  wire [BIT_WIDTH-1:0] inner_b_2_1;
// finish
  wire[SIZE*SIZE-1:0] finish;
  finish_decider # (4, 2) decider (clk, tile, finish);
// output
  wire [BIT_WIDTH-1:0] pass_down_4;  wire [BIT_WIDTH-1:0] pass_down_3;  wire [BIT_WIDTH-1:0] pass_down_2;  wire [BIT_WIDTH-1:0] pass_down_1;
  wire [BIT_WIDTH-1:0] pass_right_4;  wire [BIT_WIDTH-1:0] pass_right_3;  wire [BIT_WIDTH-1:0] pass_right_2;  wire [BIT_WIDTH-1:0] pass_right_1;
  serialize #(4, 16) se_pa_down (clk, w_e, r_e, {pass_down_4, pass_down_3, pass_down_2, pass_down_1} , pass_down_se);  
  serialize #(4, 16) se_pa_right (clk, w_e, r_e, {pass_right_4, pass_right_3, pass_right_2, pass_right_1} , pass_right_se);  
  wire [BIT_WIDTH-1:0] output_4_4;  wire [BIT_WIDTH-1:0] output_4_3;  wire [BIT_WIDTH-1:0] output_4_2;  wire [BIT_WIDTH-1:0] output_4_1;
  wire [BIT_WIDTH-1:0] output_3_4;  wire [BIT_WIDTH-1:0] output_3_3;  wire [BIT_WIDTH-1:0] output_3_2;  wire [BIT_WIDTH-1:0] output_3_1;
  wire [BIT_WIDTH-1:0] output_2_4;  wire [BIT_WIDTH-1:0] output_2_3;  wire [BIT_WIDTH-1:0] output_2_2;  wire [BIT_WIDTH-1:0] output_2_1;
  wire [BIT_WIDTH-1:0] output_1_4;  wire [BIT_WIDTH-1:0] output_1_3;  wire [BIT_WIDTH-1:0] output_1_2;  wire [BIT_WIDTH-1:0] output_1_1;
  serialize #(4, 16) se_out_4 (clk, w_e, r_e, {output_4_4, output_4_3, output_4_2, output_4_1} , output_4);  
  serialize #(4, 16) se_out_3 (clk, w_e, r_e, {output_3_4, output_3_3, output_3_2, output_3_1} , output_3);  
  serialize #(4, 16) se_out_2 (clk, w_e, r_e, {output_2_4, output_2_3, output_2_2, output_2_1} , output_2);  
  serialize #(4, 16) se_out_1 (clk, w_e, r_e, {output_1_4, output_1_3, output_1_2, output_1_1} , output_1);  
  
// pe
  single_PE_rounded # (16, 8) pe_4_4 (clk, finish[15], input_up_4, input_left_4, inner_b_4_4, inner_a_4_4, output_4_4);
  single_PE_rounded # (16, 8) pe_4_3 (clk, finish[14], input_up_3, inner_a_4_4, inner_b_4_3, inner_a_4_3, output_4_3);
  single_PE_rounded # (16, 8) pe_4_2 (clk, finish[13], input_up_2, inner_a_4_3, inner_b_4_2, inner_a_4_2, output_4_2);
  single_PE_rounded # (16, 8) pe_4_1 (clk, finish[12], input_up_1, inner_a_4_2, inner_b_4_1, pass_right_4, output_4_1);
  single_PE_rounded # (16, 8) pe_3_4 (clk, finish[11], inner_b_4_4, input_left_3, inner_b_3_4, inner_a_3_4, output_3_4);
  single_PE_rounded # (16, 8) pe_3_3 (clk, finish[10], inner_b_4_3, inner_a_3_4, inner_b_3_3, inner_a_3_3, output_3_3);
  single_PE_rounded # (16, 8) pe_3_2 (clk, finish[9], inner_b_4_2, inner_a_3_3, inner_b_3_2, inner_a_3_2, output_3_2);
  single_PE_rounded # (16, 8) pe_3_1 (clk, finish[8], inner_b_4_1, inner_a_3_2, inner_b_3_1, pass_right_3, output_3_1);
  single_PE_rounded # (16, 8) pe_2_4 (clk, finish[7], inner_b_3_4, input_left_2, inner_b_2_4, inner_a_2_4, output_2_4);
  single_PE_rounded # (16, 8) pe_2_3 (clk, finish[6], inner_b_3_3, inner_a_2_4, inner_b_2_3, inner_a_2_3, output_2_3);
  single_PE_rounded # (16, 8) pe_2_2 (clk, finish[5], inner_b_3_2, inner_a_2_3, inner_b_2_2, inner_a_2_2, output_2_2);
  single_PE_rounded # (16, 8) pe_2_1 (clk, finish[4], inner_b_3_1, inner_a_2_2, inner_b_2_1, pass_right_2, output_2_1);
  single_PE_rounded # (16, 8) pe_1_4 (clk, finish[3], inner_b_2_4, input_left_1, pass_down_4, inner_a_1_4, output_1_4);
  single_PE_rounded # (16, 8) pe_1_3 (clk, finish[2], inner_b_2_3, inner_a_1_4, pass_down_3, inner_a_1_3, output_1_3);
  single_PE_rounded # (16, 8) pe_1_2 (clk, finish[1], inner_b_2_2, inner_a_1_3, pass_down_2, inner_a_1_2, output_1_2);
  single_PE_rounded # (16, 8) pe_1_1 (clk, finish[0], inner_b_2_1, inner_a_1_2, pass_down_1, pass_right_1, output_1_1);
endmodule

