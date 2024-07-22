module tile_controller_4_4 #(
  parameter TILE_CNT = 4 // 整个阵列被分为 TILE_CNT * TILE_CNT 个小块
) (
  input [4:0] in_signal,
  output [TILE_CNT*TILE_CNT-1:0] out_signal
);
  
endmodule