/* 这里的逻辑是，脉动阵列输入的矩阵需要有向量间的时间差，而256bit/512bit的带宽下，原始数据是没有时间差的。
 * 因此，需要用寄存器来人为制造时间差，实际上就是用一块三角形的位移寄存器阵列。 
 * 所有输入端使用的寄存器阵列都在这个文件里。
*/

/*---------------------------------- Basic Components ----------------------------------*/

// 最基础的移位寄存器
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
      out <= inner_shifters[DATA_WIDTH*LENGTH-1 : DATA_WIDTH*LENGTH - LENGTH];
      for (i=1; i<LENGTH; i=i+1) 
        inner_shifters[DATA_WIDTH*(i+1) - 1 -: DATA_WIDTH] 
        <= inner_shifters[DATA_WIDTH*i - 1 -:DATA_WIDTH];
    end else begin
      out <= out;
      inner_shifters <= inner_shifters;
    end
  end  
endmodule

// 长条寄存器
module column_shifter #(
  parameter LENGTH = 4,
  parameter DATA_WIDTH = 16
) (
  input clk,
  input enable,
  input [LENGTH*DATA_WIDTH-1 : 0] in,
  output reg [LENGTH*DATA_WIDTH-1 : 0] out  
);
  reg [DATA_WIDTH*LENGTH-1 : 0] inner_shifters = 0;
  always @(posedge clk) begin
    inner_shifters <= enable ? in : inner_shifters;
    out <= enable ? inner_shifters : out;
  end
endmodule

// mux
module mux #(
  parameter LENGTH = 4,
  parameter DATA_WIDTH = 16
)(
  input flag,
  input [LENGTH*DATA_WIDTH-1 : 0] in_0,
  input [LENGTH*DATA_WIDTH-1 : 0] in_1,  
  output [LENGTH*DATA_WIDTH-1 : 0] out  
);
  assign out = flag ? in_1 : in_0;
endmodule

// 反序接线
module invert #(
  parameter LENGTH = 4,
  parameter DATA_WIDTH = 16
) (
  input [LENGTH*DATA_WIDTH-1 : 0] in,
  output reg [LENGTH*DATA_WIDTH-1 : 0] out
);
  integer i;
  always @ (in) for (i=1; i<=LENGTH; i=i+1)
      out[DATA_WIDTH*i -1 -: DATA_WIDTH] 
    = in[DATA_WIDTH*(LENGTH-i+1) -1 -: DATA_WIDTH];
endmodule

/*---------------------------------- Triangle Register Arrays ----------------------------------*/

// 给 4*4 PE阵列用的移位寄存器阵列，给每个向量制造 0 1 2 3 拍的延迟
module triangle_shifter_array_4 #(
  parameter HIGHT = 4,
  parameter DATA_WIDTH = 16 
) (
  input clk,
  input enable,
  input [DATA_WIDTH*HIGHT-1 : 0] in,
  output [DATA_WIDTH*HIGHT-1 : 0] out
);
  assign out[DATA_WIDTH-1 -: DATA_WIDTH] = in[DATA_WIDTH-1 -: DATA_WIDTH];
  shifter #(1, DATA_WIDTH) shifter1 (clk, enable, in[DATA_WIDTH*2-1 -: DATA_WIDTH], out[DATA_WIDTH*2-1 -: DATA_WIDTH]);
  shifter #(2, DATA_WIDTH) shifter2 (clk, enable, in[DATA_WIDTH*3-1 -: DATA_WIDTH], out[DATA_WIDTH*3-1 -: DATA_WIDTH]);
  shifter #(3, DATA_WIDTH) shifter3 (clk, enable, in[DATA_WIDTH*4-1 -: DATA_WIDTH], out[DATA_WIDTH*4-1 -: DATA_WIDTH]);
endmodule

// 给 8*8 PE阵列用的移位寄存器阵列，给每个向量制造 0 1 2 3 4 5 6 7 拍的延迟
module triangle_shifter_array_8 #(
  parameter HIGHT = 8,
  parameter DATA_WIDTH = 16 
) (
  input clk,
  input enable,
  input [DATA_WIDTH*HIGHT-1 : 0] in,
  output [DATA_WIDTH*HIGHT-1 : 0] out
);
  //
  assign out[DATA_WIDTH-1 -: DATA_WIDTH] = in[DATA_WIDTH-1 -: DATA_WIDTH];
  shifter #(1, DATA_WIDTH) shifter1 (clk, enable, in[DATA_WIDTH*2-1 -: DATA_WIDTH], out[DATA_WIDTH*2-1 -: DATA_WIDTH]);
  shifter #(2, DATA_WIDTH) shifter2 (clk, enable, in[DATA_WIDTH*3-1 -: DATA_WIDTH], out[DATA_WIDTH*3-1 -: DATA_WIDTH]);
  shifter #(3, DATA_WIDTH) shifter3 (clk, enable, in[DATA_WIDTH*4-1 -: DATA_WIDTH], out[DATA_WIDTH*4-1 -: DATA_WIDTH]);
  //
  shifter #(4, DATA_WIDTH) shifter4 (clk, enable, in[DATA_WIDTH*5-1 -: DATA_WIDTH], out[DATA_WIDTH*5-1 -: DATA_WIDTH]);
  shifter #(5, DATA_WIDTH) shifter5 (clk, enable, in[DATA_WIDTH*6-1 -: DATA_WIDTH], out[DATA_WIDTH*6-1 -: DATA_WIDTH]);
  shifter #(6, DATA_WIDTH) shifter6 (clk, enable, in[DATA_WIDTH*7-1 -: DATA_WIDTH], out[DATA_WIDTH*7-1 -: DATA_WIDTH]);
  shifter #(7, DATA_WIDTH) shifter7 (clk, enable, in[DATA_WIDTH*8-1 -: DATA_WIDTH], out[DATA_WIDTH*8-1 -: DATA_WIDTH]);
endmodule

// 给 16*16 PE阵列用的移位寄存器阵列
module triangle_shifter_array_16 #(
  parameter HIGHT = 16,
  parameter DATA_WIDTH = 16 
) (
  input clk,
  input enable,
  input [DATA_WIDTH*HIGHT-1 : 0] in,
  output [DATA_WIDTH*HIGHT-1 : 0] out
);
  //
  assign out[DATA_WIDTH-1 -: DATA_WIDTH] = in[DATA_WIDTH-1 -: DATA_WIDTH];
  shifter #(1, DATA_WIDTH) shifter1 (clk, enable, in[DATA_WIDTH*2-1 -: DATA_WIDTH], out[DATA_WIDTH*2-1 -: DATA_WIDTH]);
  shifter #(2, DATA_WIDTH) shifter2 (clk, enable, in[DATA_WIDTH*3-1 -: DATA_WIDTH], out[DATA_WIDTH*3-1 -: DATA_WIDTH]);
  shifter #(3, DATA_WIDTH) shifter3 (clk, enable, in[DATA_WIDTH*4-1 -: DATA_WIDTH], out[DATA_WIDTH*4-1 -: DATA_WIDTH]);
  //
  shifter #(4, DATA_WIDTH) shifter4 (clk, enable, in[DATA_WIDTH*5-1 -: DATA_WIDTH], out[DATA_WIDTH*5-1 -: DATA_WIDTH]);
  shifter #(5, DATA_WIDTH) shifter5 (clk, enable, in[DATA_WIDTH*6-1 -: DATA_WIDTH], out[DATA_WIDTH*6-1 -: DATA_WIDTH]);
  shifter #(6, DATA_WIDTH) shifter6 (clk, enable, in[DATA_WIDTH*7-1 -: DATA_WIDTH], out[DATA_WIDTH*7-1 -: DATA_WIDTH]);
  shifter #(7, DATA_WIDTH) shifter7 (clk, enable, in[DATA_WIDTH*8-1 -: DATA_WIDTH], out[DATA_WIDTH*8-1 -: DATA_WIDTH]);
  //
  shifter #(8, DATA_WIDTH) shifter8 (clk, enable, in[DATA_WIDTH*9-1 -: DATA_WIDTH], out[DATA_WIDTH*9-1 -: DATA_WIDTH]);
  shifter #(9, DATA_WIDTH) shifter9 (clk, enable, in[DATA_WIDTH*10-1 -: DATA_WIDTH], out[DATA_WIDTH*10-1 -: DATA_WIDTH]);
  shifter #(10, DATA_WIDTH) shifter10 (clk, enable, in[DATA_WIDTH*11-1 -: DATA_WIDTH], out[DATA_WIDTH*11-1 -: DATA_WIDTH]);
  shifter #(11, DATA_WIDTH) shifter11 (clk, enable, in[DATA_WIDTH*12-1 -: DATA_WIDTH], out[DATA_WIDTH*12-1 -: DATA_WIDTH]);
  //
  shifter #(12, DATA_WIDTH) shifter12 (clk, enable, in[DATA_WIDTH*13-1 -: DATA_WIDTH], out[DATA_WIDTH*13-1 -: DATA_WIDTH]);
  shifter #(13, DATA_WIDTH) shifter13 (clk, enable, in[DATA_WIDTH*14-1 -: DATA_WIDTH], out[DATA_WIDTH*14-1 -: DATA_WIDTH]);
  shifter #(14, DATA_WIDTH) shifter14 (clk, enable, in[DATA_WIDTH*15-1 -: DATA_WIDTH], out[DATA_WIDTH*15-1 -: DATA_WIDTH]);
  shifter #(15, DATA_WIDTH) shifter15 (clk, enable, in[DATA_WIDTH*16-1 -: DATA_WIDTH], out[DATA_WIDTH*16-1 -: DATA_WIDTH]);
endmodule

/*-------------------------------- Input parser example ----------------------------------*/

// 给 8*8 分块阵列的例子。田字格分块后是4个4*4，三角形矩阵也对应的分块了。
module input_parser_8_8 #(
  parameter DATA_WIDTH = 16
) (
  input clk,
  input enable,
  input tile,
  input [8*DATA_WIDTH-1 : 0] in_0,
  input [8*DATA_WIDTH-1 : 0] in_1,  // 在分块的时候用，分块的时候数据吞吐量会翻倍
  output [8*DATA_WIDTH-1 : 0] out_0,
  output [8*DATA_WIDTH-1 : 0] out_1 // 在分块的时候用，分块的时候数据吞吐量会翻倍
);
  wire [4*DATA_WIDTH-1 : 0] wire_tri_1_out;
  wire [4*DATA_WIDTH-1 : 0] wire_tri_2_in;
  wire [4*DATA_WIDTH-1 : 0] wire_tri_2_out;
  wire [4*DATA_WIDTH-1 : 0] wire_tri_2_out_inv;
  wire [4*DATA_WIDTH-1 : 0] wire_tri_3_in;
  wire [4*DATA_WIDTH-1 : 0] wire_tri_3_out;
  wire [4*DATA_WIDTH-1 : 0] wire_tri_3_out_inv;
  wire [4*DATA_WIDTH-1 : 0] wire_column_out;

  triangle_shifter_array_4 #(4, 16) triangle_0 (clk, enable, in_0[4*DATA_WIDTH-1 -: 4*DATA_WIDTH], out_0[4*DATA_WIDTH-1 -: 4*DATA_WIDTH]);
  triangle_shifter_array_4 #(4, 16) triangle_1 (clk, enable, in_0[8*DATA_WIDTH-1 -: 4*DATA_WIDTH], wire_tri_1_out);
  mux #(4,16) mux_tri_2_in (tile, wire_tri_1_out, in_1[8*DATA_WIDTH-1 -: 4*DATA_WIDTH], wire_tri_2_in);
  triangle_shifter_array_4 #(4, 16) triangle_2 (clk, enable, wire_tri_2_in, wire_tri_2_out);
  invert #(4,16) invert_2_out (wire_tri_2_out, wire_tri_2_out_inv);
  mux #(4,16) mux_tri_3_in (tile, wire_tri_2_out_inv, in_1[4*DATA_WIDTH-1 -: 4*DATA_WIDTH], wire_tri_3_in);
  triangle_shifter_array_4 #(4, 16) triangle_3 (clk, enable, wire_tri_3_in, wire_tri_3_out);
  invert #(4,16) invert_3_out (wire_tri_3_out, wire_tri_3_out_inv);
  column_shifter #(4,16) column_shift (clk, enable, wire_tri_3_out_inv, wire_column_out); 
  assign out_1[4*DATA_WIDTH-1 -: 4*DATA_WIDTH] = wire_tri_3_out;
  assign out_1[8*DATA_WIDTH-1 -: 4*DATA_WIDTH] = wire_tri_2_out;
  mux #(4,16) mux_out0_high4 (tile, wire_column_out, wire_tri_2_out, out_0[8*DATA_WIDTH-1 -: 4*DATA_WIDTH]);
  
endmodule