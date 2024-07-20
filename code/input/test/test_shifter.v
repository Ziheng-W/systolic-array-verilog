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

module test();
  reg clk = 0;
  reg [15:0] in;
  reg enable = 1;
  wire [15:0] out;
  shifter #(1,16) hahaha (clk, enable, in, out);
  
  always # 1 begin 
    $display("out[0]: %d", out);
    clk = !clk; 
  end
  
  initial begin
    # 0 in = 0;
    # 1 in = 1;
    # 1 in = 2;
    # 1 in = 3;
    # 1 in = 4;
    # 1 in = 5;
    # 1 in = 6;
    # 1 in = 7;
    # 10 $stop;
  end
  
endmodule