#include<iostream>
#include<fstream>

using namespace std;

// #define USE_ARRAY

const string my_name = "[PE Array Generater]: ";
const string comment = "// ";
const string BIT_WIDTH = "BIT_WIDTH";
const string SIZE = "SIZE";
const string SINGLE_PE_ROUNDED = "single_PE_rounded";

string finish(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}
string input_up(int i){return (string)__func__+"_"+to_string(i);}
string input_left(int i){return (string)__func__+"_"+to_string(i);}
string pass_right(int i){return (string)__func__+"_"+to_string(i);}
string pass_down(int i){return (string)__func__+"_"+to_string(i);}
string output(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}
string inner_a(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}
string inner_b(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}
string pe(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}

  
int main(int argc, char* argv[]){
  /** 读取命令行参数 **/
  if(argc > 4){
    cout<<my_name<<"Invalid input argument. Exit"<<endl;
    return -1;
  } 
  string o_f_name  = (argc > 1)?argv[1]:"output.v";
  int    size      = (argc > 2)?atoi(argv[2]):4;
  int    bit_width = (argc > 3)?atoi(argv[3]):16;
  cout<<my_name<<"output: "<<o_f_name<<", size: "<<size<<", bit width:"<<bit_width<<endl;

  /** 开始输出 **/
  fstream o_f;
  o_f.open(o_f_name, ios::out);
  o_f<<comment<<my_name<<"size: "<<size<<", bit width:"<<bit_width<<endl<<endl;  
  ifstream input("single_pe.v");
  string line;
  while (getline(input,line)){
    o_f<<line<<"\n";
  } o_f<<endl;

  /** module：普通pe阵列 **/
  o_f<<"module PE_Array_"<<size<<"_"<<size<<"_"<<bit_width<<" #("<<endl;
  /** parameter **/
  o_f<<"  parameter "<<BIT_WIDTH<<" = "<<bit_width<<","<<endl;
  o_f<<"  parameter "<<SIZE<<" = "<<size<<endl;
  o_f<<")("<<endl;
  /** IO port **/
  o_f<<"  input clk,"<<endl;
#ifndef USE_ARRAY
  // finish信号
  o_f<<comment<<"finish 信号"<<endl;
  for(int i=size; i>=1; i--){
    for(int j=size; j>=1; j--){
      o_f<<"  input "<<finish(i,j)<<",";
    } o_f<<endl;
  }
  // 两个方向的 input
  o_f<<comment<<"两个方向的 input"<<endl;
  for (int i=size; i>=1; i--){
    o_f<<"  input ["<<BIT_WIDTH<<"-1:0] "<<input_up(i)<<",";
  } o_f<<endl;
  for (int i=size; i>=1; i--){
    o_f<<"  input ["<<BIT_WIDTH<<"-1:0] "<<input_left(i)<<",";
  } o_f<<endl;
  // 两个方向的 output
  o_f<<comment<<"两个方向的 pass"<<endl;
  for (int i=size; i>=1; i--){
    o_f<<"  output ["<<BIT_WIDTH<<"-1:0] "<<pass_down(i)<<",";
  } o_f<<endl;
  for (int i=size; i>=1; i--){
    o_f<<"  output ["<<BIT_WIDTH<<"-1:0] "<<pass_right(i)<<",";
  } o_f<<endl;
  // output
  o_f<<comment<<"结果输出"<<endl;
  for(int i=size; i>=1; i--){
    for(int j=size; j>=1; j--){
      o_f<<"  output ["<<BIT_WIDTH<<"-1:0] "<<output(i,j)<<",";
    } o_f<<endl;
  }
  o_f<<"  output dot"<<endl;
#else
  o_f<<"  input ["<<SIZE<<"*"<<SIZE<<"-1:0] finish,"<<endl;
  o_f<<"  input ["<<SIZE<<"*"<<BIT_WIDTH<<"-1:0] input_up,"<<endl;
  o_f<<"  input ["<<SIZE<<"*"<<BIT_WIDTH<<"-1:0] input_left,"<<endl;
  o_f<<"  output ["<<SIZE<<"*"<<BIT_WIDTH<<"-1:0] pass_right,"<<endl;
  o_f<<"  output ["<<SIZE<<"*"<<BIT_WIDTH<<"-1:0] pass_down"<<endl;
#endif
  o_f<<");"<<endl;
  /** content **/
  /** wires **/
  o_f<<comment<<"interconnect a: from left to right"<<endl;
  for (int i=size; i>=1; i--){
    for (int j=size; j>=2; j--){
      o_f<<"  wire ["<<BIT_WIDTH<<"-1:0] "<<inner_a(i,j)<<";";
    } o_f<<endl;
  }
  o_f<<comment<<"interconnect b: from up to low"<<endl;
  for (int i=size; i>=2; i--){
    for (int j=size; j>=1; j--){
      o_f<<"  wire ["<<BIT_WIDTH<<"-1:0] "<<inner_b(i,j)<<";";
    } o_f<<endl;
  }
  /** PEs **/
  o_f<<comment<<"pe"<<endl;
  for (int i=size; i>=1; i--){
    for (int j=size; j>=1; j--){
      o_f<<"  "
         <<SINGLE_PE_ROUNDED<<" # ("<<bit_width<<", "<<(int)bit_width/2<<") "
         <<pe(i,j)
         <<" (clk, "<<finish(i,j)<<", "
         // input_up
         <<( (i==size) ? input_up(j)   : inner_b(i+1,j) )<<", "   
         // input_left
         <<( (j==size) ? input_left(i) : inner_a(i,j+1) )<<", "   
         // pass_down
         <<( (i==1)    ? pass_down(j)  : inner_b(i,j)   )<<", "   
         // pass_right
         <<( (j==1)    ? pass_right(i) : inner_a(i,j)   )<<", "   
         <<output(i,j)<<");"                              // output
         <<endl;
    }
  }
  o_f<<endl;
  o_f<<endl;
  o_f<<endl;
  o_f<<"endmodule"<<endl;
  o_f.close();
  return 0;
}





