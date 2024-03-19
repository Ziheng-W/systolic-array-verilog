/* Module Definition */
void PE(
  int idx, int idy, 
  hls::stream<A_t2> &fifo_A_in, hls::stream<A_t2> &fifo_A_out,  // 竖
  hls::stream<B_t2> &fifo_B_in, hls::stream<B_t2> &fifo_B_out,  // 横
  hls::stream<float> &fifo_C_drain_out) {
#pragma HLS INLINE OFF // 🧐?
  /* Variable Declaration */
  int p0 = idx, p1 = idy; // module id
  A_t1 local_A[1][2];
  #pragma HLS ARRAY_PARTITION variable=local_A dim=0 complete
  B_t1 local_B[1][2];
  #pragma HLS ARRAY_PARTITION variable=local_B dim=0 complete
  C_t1 local_C[8][8];
  #pragma HLS RESOURCE variable=local_C core=RAM_2P_BRAM
  /* Variable Declaration */

  for (ap_uint<3> c0 = 0; c0 <= 3; c0 += 1)       // 0:3
    for (ap_uint<3> c1 = 0; c1 <= 3; c1 += 1) {   // 0:3, c0、c1 both perfect loop
      // array 🧐这个注释对应啥？
      // pe


      // latency 🧐没看懂autosa自己的latency解释，从代码看就是单纯通过无数据依赖的pipeline ii=1来降低延迟
      for (ap_uint<4> c6 = 0; c6 <= 7; c6 += 1) { // 0:8
        // latency
        for (ap_uint<4> c7 = 0; c7 <= 7; c7 += 1) {// 0:8, c6、c7 initialize by perfect loop
        #pragma HLS PIPELINE II=1 // 🧐既然perfect loop，为什么不是unroll？是因为每条循环内容太大了不适合吗
          // simd
          // hls_unroll //🧐然后auto_sa这里又生成了个unroll注释，不知是不是说可以视资源选择pipeline还是unroll
          local_C[c7][c6] = 0;                     
        }
      }




      for (ap_uint<3> c2 = 0; c2 <= 3; c2 += 1) {   // 0:3
        // array 

        // pe
        for (ap_uint<4> c5 = 0; c5 <= 7; c5 += 1) {// c2==3 c5==7则drain, 0:7 🧐没有c3，c4


          // latency
          for (ap_uint<4> c6 = 0; c6 <= 7; c6 += 1) { // 0:7
            // latency
            for (ap_uint<4> c7 = 0; c7 <= 7; c7 += 1) { // 0:7
            #pragma HLS PIPELINE II=1  //跟初始化一样，pipeline ii=1降低latency。这里的c6, c7只有计算乘机时用到，所以也算perfect（autosa管这个叫permutable？）
              {
                { // 读竖
                  A_t2 fifo_data;
                  fifo_data = fifo_A_in.read(); // 🧐这个read在pipeline里怎么运行的
                  for (ap_uint<2> n = 0; n < 2; n++) {
                  #pragma HLS UNROLL
                    union {unsigned int ui; float ut;} u;
                    u.ui = (unsigned int)fifo_data(31, 0);
                    local_A[0][n] = u.ut;
                    fifo_data = fifo_data >> 32; 
                  }
                }
                { // 读横
                  B_t2 fifo_data;
                  fifo_data = fifo_B_in.read();
                  for (ap_uint<2> n = 0; n < 2; n++) {
                  #pragma HLS UNROLL
                    union {unsigned int ui; float ut;} u;
                    u.ui = (unsigned int)fifo_data(31, 0);
                    local_B[0][n] = u.ut;
                    fifo_data = fifo_data >> 32;
                  }
                } // 计算（simd）
                // simd
                for (ap_uint<2> c8 = 0; c8 <= 1; c8 += 1) {
                #pragma HLS UNROLL // 🧐+=有依赖，unroll会不会冲突
                  local_C[c7][c6] = (local_C[c7][c6] + (local_A[0][c8] * local_B[0][c8]));
                }
                if (c2 == 3 && c5 == 7) // 溜满了就drain出去
                  fifo_C_drain_out.write(local_C[c7][c6]);
                { // 横送走
                  B_t2 fifo_data;
                  union {unsigned int ui; float ut;} u1, u0;
                  u1.ut = local_B[0][1];
                  u0.ut = local_B[0][0];
                  fifo_data = (ap_uint<32>(u1.ui), ap_uint<32>(u0.ui));
                  fifo_B_out.write(fifo_data);
                }
                { // 竖送走
                  A_t2 fifo_data;
                  union {unsigned int ui; float ut;} u1, u0;
                  u1.ut = local_A[0][1];
                  u0.ut = local_A[0][0];
                  fifo_data = (ap_uint<32>(u1.ui), ap_uint<32>(u0.ui));
                  fifo_A_out.write(fifo_data);
                }
              }
            }
          }
        }
      }
    }
}


// 🧐autosa的示例里用了8*8的simd（注释里也对应地标了simd），但是代码实现上用的是pipeline。
/* Module Definition */