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

module invert #(
  parameter LENGTH = 4,
  parameter DATA_WIDTH = 16
) (
  input [LENGTH*DATA_WIDTH-1 : 0] in,
  output [LENGTH*DATA_WIDTH-1 : 0] out
);
  genvar i; 
  generate for (i=0; i<LENGTH; i=i+1)
    assign out[DATA_WIDTH*(i+1) -1 -: DATA_WIDTH] 
           = in[DATA_WIDTH*(LENGTH-i) -1 -: DATA_WIDTH];
  endgenerate 
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

module column_shifter #(
  parameter LENGTH = 4,
  parameter DATA_WIDTH = 16
) (
  input clk,
  input enable,
  input [LENGTH*DATA_WIDTH-1 : 0] in,
  output reg [LENGTH*DATA_WIDTH-1 : 0] out  
);
  always @(posedge clk) out <= in;
endmodule

// 低位先出
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

module input_parser_1 #(
  parameter Full_Size = 8,
  parameter Half_Size = 4,
  parameter DATA_WIDTH = 16
) (
  input clk,
  input enable,
  input tile,
  input [Full_Size*DATA_WIDTH-1 : 0] in_0,
  input [Full_Size*DATA_WIDTH-1 : 0] in_1,  // 在分块的时候用，分块的时候数据吞吐量会翻倍
  output [Full_Size*DATA_WIDTH-1 : 0] out_0,
  output [Full_Size*DATA_WIDTH-1 : 0] out_1 // 在分块的时候用，分块的时候数据吞吐量会翻倍
);
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_0_out;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_0_out_delayed;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_1_out;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_2_in;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_2_out;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_2_out_inv;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_3_in;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_3_out;
  wire [Half_Size*DATA_WIDTH-1 : 0] inv_3_data_out;

  triangle_shifter_array #(Half_Size, DATA_WIDTH) triangle_0 (clk, enable, in_0[Half_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH], wire_tri_0_out);
  triangle_shifter_array #(Half_Size, DATA_WIDTH) triangle_1 (clk, enable, in_0[Full_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH], wire_tri_1_out);
  mux #(Half_Size,DATA_WIDTH) mux_tri_2_in (tile, wire_tri_1_out, in_1[Full_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH], wire_tri_2_in);
  triangle_shifter_array #(Half_Size, DATA_WIDTH) triangle_2 (clk, enable, wire_tri_2_in, wire_tri_2_out);
  invert #(Half_Size,DATA_WIDTH) invert_2_out (wire_tri_2_out, wire_tri_2_out_inv);
  mux #(Half_Size,DATA_WIDTH) mux_tri_3_in (tile, wire_tri_2_out_inv, in_1[Half_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH], wire_tri_3_in);
  triangle_shifter_array #(Half_Size, DATA_WIDTH) triangle_3 (clk, enable, wire_tri_3_in, wire_tri_3_out);
  invert #(Half_Size,DATA_WIDTH) invert_3_out (wire_tri_3_out, inv_3_data_out);
  column_shifter # (Half_Size, DATA_WIDTH) column (clk, enable, wire_tri_0_out, wire_tri_0_out_delayed);
  assign out_0[Full_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH] = tile ? wire_tri_3_out : inv_3_data_out;
  assign out_0[Half_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH] = tile ? wire_tri_0_out : wire_tri_0_out_delayed;
  assign out_1[Half_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH] = wire_tri_3_out;
  assign out_1[Full_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH] = wire_tri_2_out;
endmodule

module input_parser_2 #(
  parameter Full_Size = 8,
  parameter Half_Size = 4,
  parameter DATA_WIDTH = 16
) (
  input clk,
  input enable,
  input tile,
  input [3:0] sub_tile,
  input [Full_Size*DATA_WIDTH-1 : 0] in_0,
  input [Full_Size*DATA_WIDTH-1 : 0] in_1,  // 在分块的时候用，分块的时候数据吞吐量会翻倍
  output [Full_Size*DATA_WIDTH-1 : 0] out_0,
  output [Full_Size*DATA_WIDTH-1 : 0] out_1 // 在分块的时候用，分块的时候数据吞吐量会翻倍
);
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_0_out;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_0_out_delayed;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_1_out;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_2_in;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_2_out;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_2_out_inv;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_3_in;
  wire [Half_Size*DATA_WIDTH-1 : 0] wire_tri_3_out;
  wire [Half_Size*DATA_WIDTH-1 : 0] inv_3_data_out;

  triangle_shifter_array #(Half_Size, DATA_WIDTH) triangle_0 (clk, enable, in_0[Half_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH], wire_tri_0_out);
  triangle_shifter_array #(Half_Size, DATA_WIDTH) triangle_1 (clk, enable, in_0[Full_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH], wire_tri_1_out);
  mux #(Half_Size,DATA_WIDTH) mux_tri_2_in (tile, wire_tri_1_out, in_1[Full_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH], wire_tri_2_in);
  triangle_shifter_array #(Half_Size, DATA_WIDTH) triangle_2 (clk, enable, wire_tri_2_in, wire_tri_2_out);
  invert #(Half_Size,DATA_WIDTH) invert_2_out (wire_tri_2_out, wire_tri_2_out_inv);
  mux #(Half_Size,DATA_WIDTH) mux_tri_3_in (tile, wire_tri_2_out_inv, in_1[Half_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH], wire_tri_3_in);
  triangle_shifter_array #(Half_Size, DATA_WIDTH) triangle_3 (clk, enable, wire_tri_3_in, wire_tri_3_out);
  invert #(Half_Size,DATA_WIDTH) invert_3_out (wire_tri_3_out, inv_3_data_out);
  column_shifter # (Half_Size, DATA_WIDTH) column (clk, enable, wire_tri_0_out, wire_tri_0_out_delayed);
  assign out_0[Full_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH] = tile ? wire_tri_3_out : inv_3_data_out;
  assign out_0[Half_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH] = tile ? wire_tri_0_out : wire_tri_0_out_delayed;
  assign out_1[Half_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH] = wire_tri_3_out;
  assign out_1[Full_Size*DATA_WIDTH-1 -: Half_Size*DATA_WIDTH] = wire_tri_2_out;
endmodule

