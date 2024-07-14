// 命名规则：cache_x 即为x入x出的cache。多pe共用cache，分担存储压力。

// 按照稀疏比 0.1 vs 0.4 的模拟，平均每个pe额外使用4*Data_Width个reg，一共需要32个word。
// word的组成是data + index
module cache_8 #(
  parameter Data_Width = 16,
  parameter Address_Width = 5
) (
  input clk,
  // write enable
  input WE_0, input WE_1, input WE_2, input WE_3,
  input WE_4, input WE_5, input WE_6, input WE_7,
  // write address
  input [Address_Width-1:0] W_Add_0, input [Address_Width-1:0] W_Add_1, 
  input [Address_Width-1:0] W_Add_2, input [Address_Width-1:0] W_Add_3, 
  input [Address_Width-1:0] W_Add_4, input [Address_Width-1:0] W_Add_5, 
  input [Address_Width-1:0] W_Add_6, input [Address_Width-1:0] W_Add_7,
  // read address
  input [Address_Width-1:0] R_Add_0, input [Address_Width-1:0] R_Add_1, 
  input [Address_Width-1:0] R_Add_2, input [Address_Width-1:0] R_Add_3, 
  input [Address_Width-1:0] R_Add_4, input [Address_Width-1:0] R_Add_5, 
  input [Address_Width-1:0] R_Add_6, input [Address_Width-1:0] R_Add_7, 
  // write data
  input [Data_Width-1:0] W_Data_0, input [Data_Width-1:0] W_Data_1, 
  input [Data_Width-1:0] W_Data_2, input [Data_Width-1:0] W_Data_3, 
  input [Data_Width-1:0] W_Data_4, input [Data_Width-1:0] W_Data_5, 
  input [Data_Width-1:0] W_Data_6, input [Data_Width-1:0] W_Data_7,
  // read data
  output reg [Data_Width-1:0] R_Data_0, output reg [Data_Width-1:0] R_Data_1, 
  output reg [Data_Width-1:0] R_Data_2, output reg [Data_Width-1:0] R_Data_3, 
  output reg [Data_Width-1:0] R_Data_4, output reg [Data_Width-1:0] R_Data_5, 
  output reg [Data_Width-1:0] R_Data_6, output reg [Data_Width-1:0] R_Data_7
);
  reg [Data_Width+Address_Width-1:0] ram [31:0];

  
endmodule


module brake_for_ #(
  parameter non = 1 
) (
  input clk
  , input [19:0] bit_mask
  , output [4:0] available_0
  , output [4:0] available_1
  , output [4:0] available_2
  , output [4:0] available_3
);
  integer i; // 0 ~ 19
  integer j; // 0 ~ 3
  reg [4:0] availables [3:0];
  always @(posedge clk) begin
    j = 3;
    for(i = 0; i<20; i=i+1) begin
      if(bit_mask[i] == 1) begin
        availables[j] = i; 
        j = j>0 ? j-1 : j;
        end end
  end
  assign available_0 = availables[0];
  assign available_1 = availables[1];
  assign available_2 = availables[2];
  assign available_3 = availables[3];
endmodule






module cache_4 #(
  parameter Data_Width = 16,
  parameter Address_Width = 5
) (
  input clk,
  // write enable
  input WE_0, input WE_1, input WE_2, input WE_3,
  input WE_4, input WE_5, input WE_6, input WE_7,
  // write address
  input [Address_Width-1:0] W_Add_0, input [Address_Width-1:0] W_Add_1, 
  input [Address_Width-1:0] W_Add_2, input [Address_Width-1:0] W_Add_3, 
  // read address
  input [Address_Width-1:0] R_Add_0, input [Address_Width-1:0] R_Add_1, 
  input [Address_Width-1:0] R_Add_2, input [Address_Width-1:0] R_Add_3, 
  // write data
  input [Data_Width-1:0] W_Data_0, input [Data_Width-1:0] W_Data_1, 
  input [Data_Width-1:0] W_Data_2, input [Data_Width-1:0] W_Data_3, 
  // read data
  output reg [Data_Width-1:0] R_Data_0, output reg [Data_Width-1:0] R_Data_1, 
  output reg [Data_Width-1:0] R_Data_2, output reg [Data_Width-1:0] R_Data_3
);
  reg [Data_Width+Address_Width-1:0] ram [31:0];
  // write
  always @(posedge clk ) begin
    if (WE_0) begin
      
    end    
  end
  
endmodule


