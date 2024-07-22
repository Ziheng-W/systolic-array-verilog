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

module triangle_shifter_array_4 #(
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

module test();
  reg clk = 0;
  reg [31:0] in;
  reg enable = 1;
  wire [31:0] out;
  triangle_shifter_array_4 #(4,8) hahaha (clk, enable, in, out);
  
  always # 1 begin 
    // $display("out[3]: %d, out[2]: %d, out[1]: %d, out[0]: %d", out[31:24], out[23:16], out[15:8], out[7:0]);
    $display("%d  %d  %d  %d", out[31:24], out[23:16], out[15:8], out[7:0]);
    clk = !clk; 
  end
  
  initial begin
    # 0 in = 0;
    # 1 in[31:24] = 0; in[23:16] = 0; in[15:8] = 0; in[7:0] = 0;
    # 1 in[31:24] = 0; in[23:16] = 0; in[15:8] = 0; in[7:0] = 0;
    # 1 in[31:24] = 0; in[23:16] = 0; in[15:8] = 0; in[7:0] = 0;
    # 1 in[31:24] = 1; in[23:16] = 1; in[15:8] = 1; in[7:0] = 1;
    # 1 in[31:24] = 1; in[23:16] = 1; in[15:8] = 1; in[7:0] = 1;
    # 1 in[31:24] = 0; in[23:16] = 0; in[15:8] = 0; in[7:0] = 0;
    # 1 in[31:24] = 0; in[23:16] = 0; in[15:8] = 0; in[7:0] = 0;
    # 1 in[31:24] = 1; in[23:16] = 1; in[15:8] = 1; in[7:0] = 1;
    # 1 in[31:24] = 1; in[23:16] = 1; in[15:8] = 1; in[7:0] = 1;
    # 1 in[31:24] = 0; in[23:16] = 0; in[15:8] = 0; in[7:0] = 0;
    # 1 in[31:24] = 0; in[23:16] = 0; in[15:8] = 0; in[7:0] = 0;
    # 20 $stop;
  end
  
endmodule