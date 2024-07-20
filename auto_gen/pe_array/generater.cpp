#include<iostream>
#include<fstream>

using namespace std;

// 一些常用的字符串
const string my_name = "[PE Array Generater]: ";
const string comment = "// ";
const string BIT_WIDTH = "BIT_WIDTH";
const string SIZE = "SIZE";
const string SINGLE_PE_ROUNDED = "single_PE_rounded";
const string WIRE = "wire ";
const string TAB = "  ";
const string INPUT = "input ";

// 用函数生成带编号的实例名
string finish(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}
string input_up(int i){return (string)__func__+"_"+to_string(i);}
string input_left(int i){return (string)__func__+"_"+to_string(i);}
string pass_right(int i){return (string)__func__+"_"+to_string(i);}
string pass_down(int i){return (string)__func__+"_"+to_string(i);}
string output(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}
string inner_a(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}
string inner_b(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}
string pe(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}
string range(int i){return (string)"[" + to_string(i-1) + ":0] ";}
string finish_decider(){return (string)__func__;}
string finish_decider(int i){return (string)__func__ + "_" + to_string(i);}
string finish(int i, int j, int size)
{return (string)__func__+"["+to_string(size*size - size*(i-1) - j)+"]";}

// 复制文件。生成verilog代码不依赖头文件，所有子模块放在同一个文件里
void dump_file(string s, fstream & f);
// 插入大注释 
void large_comment(string s, fstream & f);

// 生成一个面积为size*size，位宽为bitwidth的普通PE阵列
void make_array(fstream &o_f, int size, int bit_width);
void make_top(fstream &o_f, int size, int bit_width);
void make_input(fstream &o_f, int size, int tile_size, int bit_width);  

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

  // large_comment("[Part 1]: 纯阵列", o_f);
  // dump_file("./source/single_pe.v", o_f);
  // make_array(o_f, size, bit_width);
  // large_comment("[Part 1] Over: 纯阵列生成完毕", o_f);

  // large_comment("[Part 2]: 输入模块生成", o_f);
  dump_file("./source/input.v", o_f);
  make_input(o_f, size, 4, bit_width);
  // large_comment("[Part 2] Over: 输入模块生成完毕", o_f);



  // large_comment("[Part 3]: 输出模块", o_f);
  // dump_file("./source/output_decider.v", o_f);
  // large_comment("[Part 3] Over: 输出模块生成完毕", o_f);

  // large_comment("[Part 4]: 组装接线", o_f);
  // make_top(o_f, size, bit_width);
  // large_comment("[Part 4] Over: 组装接线完毕", o_f);
  
  o_f.close();
  return 0;
}



void dump_file(string s, fstream & f){
  ifstream input(s);
  string line;
  while (getline(input,line)){
    f<<line<<"\n";
  } f<<endl;
}

void large_comment(string s, fstream & f){
  f<<"/**"<<endl;
  f<<"    "<<s<<endl;
  f<<"**/"<<endl<<endl;
}



void make_array(fstream &o_f, int size, int bit_width){
  /** module：普通pe阵列 **/
  o_f<<"module PE_Array_"<<size<<"_"<<size<<"_"<<bit_width<<" #("<<endl;
  /** parameter **/
  o_f<<"  parameter "<<BIT_WIDTH<<" = "<<bit_width<<","<<endl;
  o_f<<"  parameter "<<SIZE<<" = "<<size<<endl;
  o_f<<")("<<endl;
  /** IO port **/
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
  o_f<<endl;
  o_f<<"  input clk"<<endl;
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
         // output   
         <<output(i,j)<<");"                              
         <<endl;
    }
  }
  o_f<<"endmodule"<<endl<<endl;
}

void make_top(fstream &o_f, int size, int bit_width) {
  /** module：普通pe阵列 **/
  o_f<<"module top_"<<size<<"_"<<size<<"_"<<bit_width<<" #("<<endl;
  /** parameter **/
  o_f<<"  parameter "<<BIT_WIDTH<<" = "<<bit_width<<","<<endl;
  o_f<<"  parameter "<<SIZE<<" = "<<size<<endl;
  o_f<<")("<<endl;
   /** IO port **/
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
  // tile
  o_f<<"  input tile,"<<endl;
  o_f<<"  input clk"<<endl;
  o_f<<");"<<endl;

  /** content **/
  // 实例化output decider
  o_f<<TAB<<comment<<"实例化output decider"<<endl;
  o_f<<TAB<<WIRE<<range(size*size)<<"finish;"<<endl;
  o_f<<TAB<<finish_decider()<<" #("<<size<<", "<<(int)size/2<<") "
     <<finish_decider(0)<<" ("<<"clk, tile, finish"<<");"<<endl;
  // 实例化纯阵列
  o_f<<TAB<<comment<<"实例化纯阵列"<<endl;
  o_f<<TAB<<"PE_Array_"<<size<<"_"<<size<<"_"<<bit_width<<" #("
     <<bit_width<<","<<size<<") array ("<<endl;
  for (int i=size; i>=1; i--){
    for (int j=size; j>=1; j--){
      o_f<<TAB<<TAB<<finish(i,j,size)<<",";
    }o_f<<endl;
  }
  o_f<<TAB<<TAB<<comment<<"两个方向的 input"<<endl;
  for (int i=size; i>=1; i--){
    o_f<<TAB<<TAB<<input_up(i)<<",";
  } o_f<<endl;
  for (int i=size; i>=1; i--){
    o_f<<TAB<<TAB<<input_left(i)<<",";
  } o_f<<endl;
  o_f<<TAB<<TAB<<comment<<"两个方向的 pass"<<endl;
  for (int i=size; i>=1; i--){
    o_f<<TAB<<TAB<<pass_down(i)<<",";
  } o_f<<endl;
  for (int i=size; i>=1; i--){
    o_f<<TAB<<TAB<<pass_right(i)<<",";
  } o_f<<endl;
   // output
  o_f<<TAB<<TAB<<comment<<"结果输出"<<endl;
  for(int i=size; i>=1; i--){
    for(int j=size; j>=1; j--){
      o_f<<TAB<<TAB<<output(i,j)<<",";
    } o_f<<endl;
  }
  o_f<<TAB<<TAB<<"clk"<<endl;
  o_f<<TAB<<TAB<<");"<<endl;


  o_f<<"endmodule"<<endl;
}


void make_input(fstream &o_f, int size, int tile_size, int bit_width){

}