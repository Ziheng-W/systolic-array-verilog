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

module test();
  reg flag = 1;
  reg [31:0] in_0 = 0;
  reg [31:0] in_1 = 0;
  wire [31:0] out;
  mux #(2,16) hahaha (flag, in_0, in_1, out);
  always # 1   $display(" %d %d", out[31:16], out[15:0]);
  initial begin
    # 1 in_0[31:16] = 0; in_0[15:0] = 0; in_1[31:16] = 1; in_1[15:0] = 1; flag = 0;
    # 1 flag = 1;
    # 1 flag = 0;
    # 1 flag = 1;
    # 1 flag = 0;
    # 1 $stop;
  end
endmodule