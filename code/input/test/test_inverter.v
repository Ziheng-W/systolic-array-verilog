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

module test();
  reg [31:0] in;
  wire [31:0] out;
  invert #(4,8) hahaha (in, out);
  always # 1   $display("from high to low: %d %d %d %d", out[31:24], out[23:16], out[15:8], out[7:0]);
  initial begin
    # 0 in = 0;
    # 1 in[31:24] = 4; in[23:16] = 3; in[15:8] = 2; in[7:0] = 1;
    # 1 in[31:24] = -8; in[23:16] = 7; in[15:8] = 6; in[7:0] = 5;
    # 1 $stop;
  end
endmodule