module cache_decider #(
  parameter non = 1 
) (
  input clk
  , input [19:0] bit_mask
  // , output [4:0] available_0
  // , output [4:0] available_1
  // , output [4:0] available_2
  // , output [4:0] available_3
  // , output [4:0] available_4
  // , output [4:0] available_5
  // , output [4:0] available_6
  // , output [4:0] available_7
  // , output [4:0] available_8
  // , output [4:0] available_9
  // , output [4:0] available_10
  // , output [4:0] available_11
);
  integer i; // 0 ~ 19
  integer j; // 0 ~ 3
  reg [4:0] availables [3:0];
  initial begin
    for(i=0; i<4; i=i+1) begin
      availables[i] = 0;
    end
  end

  always @(posedge clk) begin
    j = 0;
    for(i = 0; i<4; i=i+1) begin
      availables[i] = -1;
    end
    for(i = 0; i<20; i=i+1) begin
      if(bit_mask[i] == 1) begin
        availables[j] = i;
        j = j+1;
      end 
    end
  end
  // assign available_0 = availables[0];
  // assign available_1 = availables[1];
  // assign available_2 = availables[2];
  // assign available_3 = availables[3];
  // assign available_4 = availables[4];
  // assign available_5 = availables[5];
  // assign available_6 = availables[6];
  // assign available_7 = availables[7];
  // assign available_8 = availables[8];
  // assign available_9 = availables[9];
  // assign available_10 = availables[10];
  // assign available_11 = availables[11];  
endmodule

module test();
  integer currTime = 0;
  reg clk = 0;
  reg [19:0] bitmask = 0;
  // wire [4:0] available_0;
  // wire [4:0] available_1;
  // wire [4:0] available_2;
  // wire [4:0] available_3;
  // wire [4:0] available_4;
  // wire [4:0] available_5;
  // wire [4:0] available_6;
  // wire [4:0] available_7;
  // wire [4:0] available_8;
  // wire [4:0] available_9;
  // wire [4:0] available_10;
  // wire [4:0] available_11;
  cache_decider # (1) little_cache (clk, bitmask);

  // 修改input、显示初态
  initial begin
    # 0 
    # 2 bitmask = 20'b0000_0000_0000_0000_1100;
    // # 2 bitmask = 20'b0000_1111_0000_1111_1111;
    // # 2 bitmask = 20'b0000_1111_0000_0000_0000;
    // # 2 bitmask = 20'b0000_0000_0111_0000_0000;
    # 2 $finish;
  end
  // 计时并间隔输出
  always #2 begin
    currTime = currTime + 1;
    $display(" ");
  end
  // output
  always #1 begin
    clk = ~clk;
    $display("Time: %d, clk: %d, ava_0: %d, ava_1: %d, ava_2: %d, ava_3: %d", currTime, clk, little_cache.availables[0], little_cache.availables[1], little_cache.availables[2], little_cache.availables[3]);
  end
endmodule
