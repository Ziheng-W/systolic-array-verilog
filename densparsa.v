(* use_dsp = "no" *)
module MULTI_32bit(clk, rst,A, B, F);
   `define BIAS 8'b01111111
   input clk, rst;
   input [31:0]A;
   input [31:0]B;

   output [31:0]F;
   reg [31:0]F;
	

//   reg [1:0]sign;
//   reg [49:0]mantissa;

//////////////// PIPE-LINE REGISTERS /////////////////
reg [62:0] P1;
reg [66:0] P2;
reg [31:0] P3; // p1 p2 p3 F
//////////////////////////////////////////////////////

initial
begin	
	P1 = 0;
	P2 = 0;
	P3 = 0;
end

wire [1:0]sign;
wire [49:0]mantissa;

assign sign = A[31]+B[31];

//always @ ( F or A or B )
always @ ( posedge clk )
begin
	//solve for the sign bit part
	/////////////////////////////////////////////////////////
	P1[0] <= (sign == 1'b1) ? 1'b1 : 1'b0;
	P1[31:1] <= A[30:0];
	P1[62:32] <= B[30:0];

	///////////////////////////////////////////////////////////
	P2[0] <= P1[0];
	P2[50:1] <= P1[23:1] * P1[54:32];

	P2[58:51] <= P1[31:24];
	P2[66:59] <= P1[62:55];

///////////////////////////////////////////////////////////
	P3[0] <= P2[0];

	if(P2[50:24] == 0) begin
	   P3[23:1] = P2[23:1];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h00;
	end
	else if(P2[50] == 1) begin
	   P3[23:1] = P2[49:27];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h1a;
	end
	else if(P2[49] == 1) begin
	   P3[23:1] = P2[48:26];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h19;
	end
	else if(P2[48] == 1) begin
	   P3[23:1] = P2[47:25];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h18;
	end
	else if(P2[47] == 1) begin
	   P3[23:1] = P2[46:24];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h17;
	end			
	else if(P2[46] == 1) begin
	   P3[23:1] = P2[45:23];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h16;
	end	
	else if(P2[45] == 1) begin
	   P3[23:1] = P2[44:22];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h15;
	end	
	else if(P2[44] == 1) begin
	   P3[23:1] = P2[43:21];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h14;
	end
	else if(P2[43] == 1) begin
	   P3[23:1] = P2[42:20];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h13;
	end
	else if(P2[42] == 1) begin
	   P3[23:1] = P2[41:19];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h12;
	end
	else if(P2[41] == 1) begin
	   P3[23:1] = P2[40:18];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h11;
	end
	else if(P2[40] == 1) begin
	   P3[23:1] = P2[39:17];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h10;
	end
	else if(P2[39] == 1) begin
	   P3[23:1] = P2[38:16];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h0f;
	end
	else if(P2[38] == 1) begin
	   P3[23:1] = P2[37:15];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h0e;
	end
	else if(P2[37] == 1) begin
	   P3[23:1] = P2[36:14];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h0d;
	end
	else if(P2[36] == 1) begin
	   P3[23:1] = P2[35:13];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h0c;
	end
	else if(P2[35] == 1) begin
	   P3[23:1] = P2[34:12];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h0b;
	end
	else if(P2[34] == 1) begin
	   P3[23:1] = P2[33:11];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h0a;
	end
	else if(P2[33] == 1) begin
	   P3[23:1] = P2[32:10];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h09;
	end
	else if(P2[32] == 1) begin
	   P3[23:1] = P2[31:09];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h08;
	end
	else if(P2[31] == 1) begin
	   P3[23:1] = P2[30:08];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h07;
	end
	else if(P2[30] == 1) begin
	   P3[23:1] = P2[29:07];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h06;
	end
	else if(P2[29] == 1) begin
	   P3[23:1] = P2[28:06];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h05;
	end
	else if(P2[28] == 1) begin
	   P3[23:1] = P2[27:05];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h04;
	end
	else if(P2[27] == 1) begin
	   P3[23:1] = P2[26:04];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h03;
	end
	else if(P2[26] == 1) begin
	   P3[23:1] = P2[25:03];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h02;
	end
	else begin
	   P3[23:1] = P2[24:02];
	   P3[31:24] = P2[58:51] + P2[66:59] - `BIAS + 8'h01;
	end

///////////////////////////////////////////////////////////
	F[31] <= P3[0];
	F[30:0] <= P3[31:1];

////////////////////////////////////////////////////////////
end

endmodule


(* use_dsp = "no" *)
module add_fp32 #(
  parameter I_Width = 32,
  parameter O_Wdith = 32,
  parameter Expo_Length = 8,
  parameter Mant_Length = 23
) (
  input [I_Width-1:0] floatA,
  input [I_Width-1:0] floatB,
  output reg [O_Wdith-1:0] sum
);

reg sign;
reg signed [Expo_Length+1-1:0] exponent; //fifth bit is sign
reg [Mant_Length-1:0] mantissa;
reg [Expo_Length-1:0] exponentA, exponentB;
reg [Mant_Length+1-1:0] fractionA, fractionB, fraction;	//fraction = {1,mantissa}
reg [I_Width-1:0] shiftAmount;
reg cout;
 
always @ (floatA or floatB) begin
	exponentA = floatA[I_Width-1 -: Expo_Length];
	exponentB = floatB[I_Width-1 -: Expo_Length];
	fractionA = {1'b1,floatA[Mant_Length-1:0]};//
	fractionB = {1'b1,floatB[Mant_Length-1:0]}; //
	
	exponent = exponentA;
 
	if (floatA == 0) begin						//special case (floatA = 0)
		sum = floatB;
	end else if (floatB == 0) begin					//special case (floatB = 0)
		sum = floatA;
	end else if (floatA[I_Width-2:0] == floatB[I_Width-2:0] && floatA[I_Width-1]^floatB[I_Width-1]==1'b1) begin
		sum=0;
	end else begin
		if (exponentB > exponentA) begin//对阶
			shiftAmount = exponentB - exponentA;
			fractionA = fractionA >> (shiftAmount);
			exponent = exponentB;
		end else if (exponentA > exponentB) begin //
			shiftAmount = exponentA - exponentB;
			fractionB = fractionB >> (shiftAmount);
			exponent = exponentA;
		end
		if (floatA[I_Width-1] == floatB[I_Width-1]) begin			//same sign
			{cout,fraction} = fractionA + fractionB;
			if (cout == 1'b1) begin//
				{cout,fraction} = {cout,fraction} >> 1;
				exponent = exponent + 1;
			end
			sign = floatA[I_Width-1];
		end else begin						//different signs
			if (floatA[I_Width-1] == 1'b1) begin
				{cout,fraction} = fractionB - fractionA;//
			end else begin
				{cout,fraction} = fractionA - fractionB;//
			end
			sign = cout;
			if (cout == 1'b1) begin
				fraction = -fraction;//
			end else begin
			end
			if (fraction [Mant_Length+1-1] == 0) begin
				if (fraction[Mant_Length-1] == 1'b1) begin//
					fraction = fraction << 1;
					exponent = exponent - 1;
				end else if (fraction[Mant_Length-2] == 1'b1) begin
					fraction = fraction << 2;
					exponent = exponent - 2;
				end else if (fraction[Mant_Length-3] == 1'b1) begin
					fraction = fraction << 3;
					exponent = exponent - 3;
				end else if (fraction[Mant_Length-4] == 1'b1) begin
					fraction = fraction << 4;
					exponent = exponent - 4;
				end else if (fraction[Mant_Length-5] == 1'b1) begin
					fraction = fraction << 5;
					exponent = exponent - 5;
				end else if (fraction[Mant_Length-6] == 1'b1) begin
					fraction = fraction << 6;
					exponent = exponent - 6;
				end else if (fraction[Mant_Length-7] == 1'b1) begin
					fraction = fraction << 7;
					exponent = exponent - 7;
				end else if (fraction[Mant_Length-8] == 1'b1) begin
					fraction = fraction << 8;
					exponent = exponent - 8;
				end else if (fraction[Mant_Length-9] == 1'b1) begin
					fraction = fraction << 9;
					exponent = exponent - 9;
				end else if (fraction[Mant_Length-10] == 1'b1) begin
					fraction = fraction << 10;
					exponent = exponent - 10;
				end else if (fraction[Mant_Length-11] == 1'b1) begin
					fraction = fraction << 11;
					exponent = exponent - 11;
				end else if (fraction[Mant_Length-12] == 1'b1) begin
					fraction = fraction << 12;
					exponent = exponent - 12;
				end else if (fraction[Mant_Length-13] == 1'b1) begin
					fraction = fraction << 13;
					exponent = exponent - 13;
				end else if (fraction[Mant_Length-14] == 1'b1) begin
					fraction = fraction << 14;
					exponent = exponent - 14;
				end else if (fraction[Mant_Length-15] == 1'b1) begin
					fraction = fraction << 15;
					exponent = exponent - 15;
				end else if (fraction[Mant_Length-16] == 1'b1) begin
					fraction = fraction << 16;
					exponent = exponent - 16;
				end else if (fraction[Mant_Length-17] == 1'b1) begin
					fraction = fraction << 17;
					exponent = exponent - 17;
				end else if (fraction[Mant_Length-18] == 1'b1) begin
					fraction = fraction << 18;
					exponent = exponent - 18;
				end else if (fraction[Mant_Length-19] == 1'b1) begin
					fraction = fraction << 19;
					exponent = exponent - 19;
				end else if (fraction[Mant_Length-20] == 1'b1) begin
					fraction = fraction << 20;
					exponent = exponent - 20;
				end else if (fraction[Mant_Length-21] == 1'b1) begin
					fraction = fraction << 21;
					exponent = exponent - 21;
				end else if (fraction[Mant_Length-22] == 1'b1) begin
					fraction = fraction << 22;
					exponent = exponent - 22;
				end else if (fraction[Mant_Length-23] == 1'b1) begin
					fraction = fraction << 23;
					exponent = exponent - 23;
				end
			end
		end
		mantissa = fraction[Mant_Length-1:0];//
		if(exponent[Expo_Length]==1'b1) begin //
			sum = 0;
		end
		else begin
			sum = {sign,exponent[Expo_Length-1:0],mantissa};
		end		
	end		
end
 
endmodule

module fifo #(    // 低位入，高位出
  parameter Data_Width = 16,
  parameter Depth = 4,
  parameter Depth_Witdh = $clog2(Depth)
) (
  input clk,
  input we,
  input [Data_Width-1:0] data_in,
  input re,
  output [Data_Width-1:0] data_out,
  output full
);
  reg [Depth_Witdh-1:0] address;
  (* keep = "true" *) reg [Depth*Data_Width-1:0] local_data;
  integer i;
  always @(posedge clk) begin
    if(we && re) begin
      local_data[Data_Width-1 -:Data_Width] <= data_in;
      for(i=2; i<=Depth; i=i+1)
        local_data[i*Data_Width-1 -:Data_Width] 
        <= local_data[(i-1)*Data_Width-1 -:Data_Width];
      address <= address;
    end else if(we) begin
      local_data[Data_Width-1 -:Data_Width] <= data_in;
      for(i=2; i<=Depth; i=i+1)
        local_data[i*Data_Width-1 -:Data_Width] 
        <= local_data[(i-1)*Data_Width-1 -:Data_Width];
      address <= address+1;
    end else if(re) begin
      address <= address-1;
      local_data <= local_data;
    end else begin
      address <= address;
      local_data <= local_data;
    end
  end
  assign data_out = local_data[(address+1)*Data_Width-1 -:Data_Width];
  assign full = we && (address==Depth-1);
endmodule

(* use_dsp = "no" *)
module MAC_pipe_f32 #(
  parameter Width = 32
) (
  input clk, 
  input rst,
  input [31:0] A,
  input [31:0] B,
  input [31:0] psum,
  output [31:0] result
);
  wire [31:0] product;
  MULTI_32bit mul (clk, rst, A, B, product);
  add_fp32 #(32, 32, 8, 23) add (product, psum, result);
endmodule


// (* use_dsp = "no" *)
// module PE_sparse_pipe_f32 #( 
module sparsa #( 
  parameter Data_Width = 32,
  parameter Mask_Width = 32,
  parameter Depth = 4,
  parameter Index_Width = $clog2(Mask_Width),
  parameter Half_D_Width = Data_Width/2,
  parameter Depth_Witdh = $clog2(Depth)
) (
  input clk,
  input rst,
  input finish,
  // 更新local_mask
  input mask_conf,
  input [Mask_Width-1:0] new_mask,
  // 传入
  input [Index_Width-1:0] index_i_up,
  input [Data_Width-1:0] data_i_up,
  input [Index_Width-1:0] index_i_le,
  input [Data_Width-1:0] data_i_le,
  // 传出
  output reg [Index_Width-1:0] index_o_do,
  output reg [Data_Width-1:0] data_o_do,
  output reg [Index_Width-1:0] index_o_ri,
  output reg [Data_Width-1:0] data_o_ri,
  // 输出
  output reg [Data_Width-1:0] result
  // 乘法流水线结束信号
  // output mul_done
);
  reg [Mask_Width-1:0] local_mask;
  reg [Data_Width-1:0] partial_sum;
  reg [3:0] mul_done_delay; // 将calc信号延迟4个周期（4*乘法pipeline, 1*加法）。P1 P2 P3 F add
  reg calc_en;
  reg parser_do;
  
  wire [Data_Width-1:0] mac_in;
  wire [Data_Width-1:0] p_sum;
  wire [Data_Width-1:0] mac_src_1;
  wire [Data_Width-1:0] mac_src_2;
  // 状态更新
  always @(posedge clk) begin
    // local_mask
    local_mask <= mask_conf ? new_mask : local_mask;
    // result
    result <= finish ? partial_sum : result;
    // data pass
       {index_o_do, index_o_ri, data_o_do, data_o_ri} 
    <= {index_i_up, index_i_le, data_i_up, data_i_le};
    // calc 延时
    mul_done_delay[0] <= calc_en;
    mul_done_delay[1] <= mul_done_delay[0];
    mul_done_delay[2] <= mul_done_delay[1];
    mul_done_delay[3] <= mul_done_delay[2];
  end
  // 计算
  wire left_up, up_up, left_down, up_down, match, left_bigger, left_match, up_match;
  wire [2*Data_Width-1:0] full_product;

  // connect to a fifo
  wire cache_we;
  wire cache_re;
  wire [Data_Width-1:0] data_upload;
  wire [Data_Width-1:0] data_download;
  fifo # (Data_Width,Depth,Depth_Witdh) buffer (clk,  cache_we,data_upload,  cache_re,data_download,  full);
  assign match = index_i_le == index_i_up;        // 一个等于比较器
  assign left_bigger = index_i_le > index_i_up;   // 一个大小比较器
  assign left_match = local_mask[index_i_le]==1;  // 一个取址筛
  assign up_match = local_mask[index_i_up]==1;    // 又一个取址筛
  assign left_up = left_bigger && left_match;  
  assign up_up = !left_bigger && up_match;   
  assign left_down = !left_bigger && left_match;  // match必然left_down，left_down不一定match
  assign up_down = left_bigger && up_match;
  assign cache_we = left_up || up_up;
  assign cache_re = left_down || up_down;  
  assign data_upload = cache_we  ?  (left_up?data_i_le:index_i_up)  :  0;
  always @(posedge clk) begin
    calc_en <= cache_re;
    parser_do <= left_down;
//     partial_sum <= calc_en ? mac_in : partial_sum;
    partial_sum <= mul_done_delay[3] ? mac_in : partial_sum;
  end
  assign p_sum = partial_sum;
  assign mac_src_1 = data_download;
  assign mac_src_2 = parser_do?data_o_do:data_o_ri;

  MAC_pipe_f32 #() mac (clk, rst, mac_src_1, mac_src_2, p_sum, mac_in);

endmodule
