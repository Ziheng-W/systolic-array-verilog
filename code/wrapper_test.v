`include "/home/toko/onesa/code/wrapper.v"
module test #(parameter SIZE = 8) ();
  integer currTime = 0;
  reg clk = 0;
  reg tile = 0;
  wire [63 : 0]out;
  finish_decider #(8,4) test(clk, tile, out);
  // 修改input、显示初态
  initial begin
    # 0 tile = 1;
    $display("single pe test");
    $display("Time: %d, clk: %d", currTime, clk);

    #10 $finish;
  end
  // 间隔输出
  always #2 begin
    currTime = currTime + 1;
    $display("Time: %d, clk: %d, _ %d %d %d %d %d %d %d %d _", currTime, clk, test.signal[0], test.signal[1], test.signal[2], test.signal[3], test.signal[4], test.signal[5], test.signal[6], test.signal[7]);
    $display("Time: %d, clk: %d, _ %d %d %d %d %d %d %d %d _", currTime, clk, test.signal[8], test.signal[9], test.signal[10], test.signal[11], test.signal[12], test.signal[13], test.signal[14], test.signal[15]);
    $display("Time: %d, clk: %d, _ %d %d %d %d %d %d %d %d _", currTime, clk, test.signal[16], test.signal[17], test.signal[18], test.signal[19], test.signal[20], test.signal[21], test.signal[22], test.signal[23]);
    $display("Time: %d, clk: %d, _ %d %d %d %d %d %d %d %d _", currTime, clk, test.signal[24], test.signal[25], test.signal[26], test.signal[27], test.signal[28], test.signal[29], test.signal[30], test.signal[31]);
    $display("Time: %d, clk: %d, _ %d %d %d %d %d %d %d %d _", currTime, clk, test.signal[32], test.signal[33], test.signal[34], test.signal[35], test.signal[36], test.signal[37], test.signal[38], test.signal[39]);
    $display("Time: %d, clk: %d, _ %d %d %d %d %d %d %d %d _", currTime, clk, test.signal[40], test.signal[41], test.signal[42], test.signal[43], test.signal[44], test.signal[45], test.signal[46], test.signal[47]);
    $display("Time: %d, clk: %d, _ %d %d %d %d %d %d %d %d _", currTime, clk, test.signal[48], test.signal[49], test.signal[50], test.signal[51], test.signal[52], test.signal[53], test.signal[54], test.signal[55]);
    $display("Time: %d, clk: %d, _ %d %d %d %d %d %d %d %d _", currTime, clk, test.signal[56], test.signal[57], test.signal[58], test.signal[59], test.signal[60], test.signal[61], test.signal[62], test.signal[63]);
    $display("");
  end
  // 
  always #1 begin
    clk = ~clk;
  end

endmodule