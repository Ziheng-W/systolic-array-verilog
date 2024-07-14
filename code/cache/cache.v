
module test_cache #(
  parameter Data_Width = 16,
  parameter Index_Width = 5,
  parameter Address_Width = 5
) (
  input clk,
  /********     端口1     ********/
  input WE_0,
  input [Data_Width-1:0] data_i_0,
  input [Index_Width-1:0] index_i_0,
  input [Index_Width-1:0] index_o_0,
  output [Data_Width-1:0] data_o_0
);
  reg [Data_Width+Index_Width+3-1:0] ram [19:0];
  reg [19:0] available_list = -1; // 1意味着可选，0意味着被占用
  reg [Address_Width-1:0] ptr_i_0 = 0;
  reg [Address_Width-1:0] ptr_o_0 = 0;
  integer i;

  initial begin
    for(i=0; i<20; i=i+1) begin
      ram[i] = 0; end end

  /********     端口1     ********/  
  // 写入
  always @(posedge clk ) begin
    if (WE_0) begin
      ram[ptr_i_0] = {3'b000,index_i_0, data_i_0};
      available_list[ptr_i_0] = 0;
    end  
  end
  // 读出
  always @ (index_o_0) begin
    for(i=0; i<20; i++) begin // 检索匹配
      if (ram[i][Data_Width+Index_Width+3-1 : Data_Width] == {3'b000, index_o_0}) begin
        ptr_o_0 = i; 
        available_list[ptr_i_0] = 1;
      end    
    end
  end
  assign data_o_0 = ram[ptr_o_0][Data_Width-1:0]; // 输出
  // // 更新空闲指针
  // always @() begin
    
  // end
endmodule


