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

// 串转并
module deserialize #(
  parameter LENGTH = 4,
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