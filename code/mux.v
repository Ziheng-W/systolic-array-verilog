module mux #(
  parameter DATA_WIDTH = 8,
  parameter DIM = 8
)(
  input select,
  input[DATA_WIDTH*DIM-1:0] i_1, 
  input[DATA_WIDTH*DIM-1:0] i_2, 
  output[DATA_WIDTH*DIM-1:0] out
);
  assign out = select ? i_1 : i_2;  
endmodule
