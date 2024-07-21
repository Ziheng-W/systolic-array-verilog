#include<iostream>
#include<fstream>

using namespace std;

// 一些常用的字符串s
const string my_name = "[PE Array Generater]: ";
const string comment = "// ";
const string BIT_WIDTH = "BIT_WIDTH";
const string SIZE = "SIZE";
const string SINGLE_PE_ROUNDED = "single_PE_rounded";
const string WIRE = "wire ";
const string TAB = "  ";
const string INPUT = "input ";

string output(int i, int j){return (string)__func__+"_"+to_string(i)+"_"+to_string(j);}

void connect_finish(fstream &o_f, int size);
void connect_input_up(fstream &o_f, int size, string name);
void connect_output(fstream & o_f, int size);
void instance_output(fstream & o_f, int size, string name);
void output_diagonal(fstream & o_f, int size, string name_dia, string name_out);

int main(int argc, char* argv[]){
  /** 开始输出 **/
  fstream o_f;
  o_f.open("temp.txt", ios::out);
  // o_f<<"hello"<<endl;
  // connect_finish(o_f, 8);
  
  // connect_input_up(o_f, 8, "in_up");
  // o_f<<endl;
  // connect_input_up(o_f, 8, "in_left");
  
  // connect_input_up(o_f, 8, "pass_down");
  // o_f<<endl;
  // connect_input_up(o_f, 8, "pass_right");

  // connect_output(o_f, 8);

  // instance_output(o_f, 8, "output");

  output_diagonal(o_f, 8, "output_dia", "output");
  return 0;
}


void connect_finish(fstream &o_f, int size){
  for(int i = size*size-1; i>=0; i--){
    o_f<<"finish["<<i<<"], ";
  }
}

void connect_input_up(fstream &o_f, int size, string name){
  for( int i = size; i>=1; i--){
    o_f<<name<<"["<<i<<"*BIT_WIDTH-1 -: BIT_WIDTH], ";
  }
}

void connect_output(fstream & o_f, int size){
  for(int i=size; i>=1; i--){
    o_f<<"output [SIZE*BIT_WIDTH-1 : 0] "<<"output_"<<i<<", ";
  }
}

void instance_output(fstream & o_f, int size, string name){
  for(int i = size; i>=1; i--){
    for(int j = size; j>=1; j--){
      o_f<<name<<"_"<<i<<" ["<<j<<"*BIT_WIDTH-1 -: BIT_WIDTH], ";     
    }
  }
}

void output_diagonal(fstream & o_f, int size, string name_dia, string name_out){
  for(int i = size; i>=1; i--) {
    o_f<<"assign "<<name_dia<<" = "<<name_out<<"_"<<i<<" ["<<i<<"*BIT_WIDTH-1 -: BIT_WIDTH]; ";
  }
}
