`timescale 1ns / 1ps

module Add32(result, src_1, src_2);
input unsigned [31:0]src_1,src_2;
output unsigned [31:0]result;
assign result = src_1 + src_2; 
endmodule 

module test();
reg [31:0] a_;
reg [31:0] b_;
wire [31:0] result_;
Add32 a1(result_, a_, b_);
initial begin
  #0   a_ = 100; b_ = 101;
  #1   a_ = -100; b_ = 102;
  #100 $stop;
end
initial $monitor("%d + %d = %d", a_, b_, result_);
endmodule
