// two of this stuff is used for a top module

module deserialize #(
  parameter LENGTH = 8,
  parameter BIT_WIDTH = 64
) (
  input clk,
  input read_enable,
  input [BIT_WIDTH-1 : 0] in,
  output [LENGTH*BIT_WIDTH-1 : 0] out
);
  reg [LENGTH*BIT_WIDTH-1 : 0] local = 0;
  integer i;
  always @(posedge clk) begin
    if (read_enable) begin
      for (i = LENGTH; i>=2; i=i-1) begin
        local   [i*BIT_WIDTH-1     -: BIT_WIDTH] 
        <= local[(i-1)*BIT_WIDTH-1 -: BIT_WIDTH];
      end
      local[BIT_WIDTH-1 -: BIT_WIDTH] <= in;
    end else local <= local;
  end
  assign out = local;
endmodule