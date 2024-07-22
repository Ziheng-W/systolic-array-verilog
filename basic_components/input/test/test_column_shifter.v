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

module test();
  reg clk = 0;
  reg [31:0] in;
  reg enable = 1;
  wire [31:0] out;
  column_shifter #(2,16) hahaha (clk, enable, in, out);
  
  always # 1 begin 
    $display("out[1]: %d, out[0]: %d", out[31:16], out[15:0]);
    clk = !clk; 
  end
  
  initial begin
    # 0 in = 0;
    # 1 in[31:16] = 3; in[15:0] = 1;
    # 1 in[31:16] = 3; in[15:0] = 1;
    # 1 in[31:16] = 2; in[15:0] = 4;
    # 1 in[31:16] = 2; in[15:0] = 4;
    # 3 $stop;
  end
  
endmodule