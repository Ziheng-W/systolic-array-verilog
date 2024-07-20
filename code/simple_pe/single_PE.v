module single_PE #(
  parameter DATA_WIDTH = 8,
  parameter Half_WIDTH = 4
)(
  input clk,
  input finish,
  input[DATA_WIDTH-1 : 0] i_up,
  input[DATA_WIDTH-1 : 0] i_left,
  output reg[DATA_WIDTH-1 : 0] o_down,
  output reg[DATA_WIDTH-1 : 0] o_right,
  output reg[2*DATA_WIDTH-1 : 0] o_result = 0  
);
  reg [2*DATA_WIDTH-1 : 0] partial_sum = 0;
  wire [DATA_WIDTH-1 : 0] x;
  assign x = i_up*i_left;
  always @(posedge clk) begin
    o_down <= i_up;
    o_right <= i_left;
    if(finish) begin
      o_result <= partial_sum;
      partial_sum <= x;
    end else begin
      o_result <= o_result;
      partial_sum <= partial_sum + x;
    end
  end
endmodule

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
    o_down <= i_up;
    o_right <= i_left;
    if(finish) begin
      o_result <= partial_sum;
      partial_sum <= x;
    end else begin
      o_result <= o_result;
      partial_sum <= partial_sum + x;
    end
  end
endmodule