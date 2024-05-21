/*
  输入输出位宽一致的乘法器。纯组合逻辑。
*/

module multiplier #(
  parameter Half_WIDTH = 4
)(
  input [2*Half_WIDTH-1 : 0] a,
  input [2*Half_WIDTH-1 : 0] b,
  output [2*Half_WIDTH-1 : 0] o
);
  assign o = (a*b) >> Half_WIDTH;
endmodule
