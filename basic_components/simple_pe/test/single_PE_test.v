module single_PE_rounded #(
  parameter DATA_WIDTH = 8,
  parameter Half_WIDTH = 4
)(
  input clk,
  input finish,
  input[DATA_WIDTH-1 : 0] i_up,
  input[DATA_WIDTH-1 : 0] i_left,
  output reg[DATA_WIDTH-1 : 0] o_down,
  output reg[DATA_WIDTH-1 : 0] o_right,
  output reg[DATA_WIDTH-1 : 0] o_result = 0  
);
  reg [DATA_WIDTH-1 : 0] partial_sum = 0;
  wire [DATA_WIDTH-1 : 0] x;
  assign x = (i_up*i_left) >> Half_WIDTH;
  always @(posedge clk) begin
    o_down      <= i_up;
    o_right     <= i_left;
    o_result    <= finish ? partial_sum : o_result;
    partial_sum <= finish ? x : (partial_sum + x);
  end
endmodule
/* 
  1. 限制精度的乘累加计算 
  2. finish信号能否重置partial result 
 */

module main #(parameter DATA_WIDTH = 16)();
  integer currTime = 0;
  reg clk = 0;
  reg finish = 0;
  reg [DATA_WIDTH-1 : 0] i_up = 0;
  reg [DATA_WIDTH-1 : 0] i_left = 0;
  wire [DATA_WIDTH-1 : 0] o_down = 0;
  wire [DATA_WIDTH-1 : 0] o_right = 0;
  wire [DATA_WIDTH-1 : 0] o_result = 0;
  single_PE_rounded # (16,8) test (clk, finish, i_up, i_left, o_down, o_right, o_result);

  // 修改input、显示初态
  initial begin
    # 0 
    $display("single pe test");
    $display("Time: %d, clk: %d, partial_sum: %d", currTime, clk, test.partial_sum);
    # 2 i_up = 100; i_left = 20;
    # 6 i_up = 100; i_left = 40;
    # 2 finish = 1;
    # 2 finish = 0;
    # 4 $finish;
  end
  // 计时并间隔输出
  always #2 begin
    currTime = currTime + 1;
    $display(" ");
  end
  // output
  always #1 begin
    clk = ~clk;
    $display("Time: %d, clk: %d, partial_sum: %d, o_down: %d, o_right: %d, o_result", currTime, clk, test.partial_sum, test.o_down, test.o_right, test.o_result);
  end

endmodule