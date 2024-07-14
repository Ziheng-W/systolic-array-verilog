# include <iostream>
# include <time.h>
# include <ctime>
# include <stdlib.h>
# include <vector>
# include <algorithm>
#include <iomanip>
#include <cstdlib>

using namespace std;

bool randint(float p);
int max_stack_size_1(int vector_size, float p1, float p2);
int max_stack_size_2(int vector_size, float p1, float p2);
int max_stack_size_4(int vector_size, float p1, float p2);
int max_stack_size_8(int vector_size, float p1, float p2);
int max_stack_size_4_1_static_1(int vector_size, float p);

float monte_carlo(int vector_size, float p1, float p2, int times = 10000000);

int main(int argc, char *argv[]){
  srand((unsigned)time(NULL));

  int size = atoi(argv[1]);
  float p1 = atof(argv[2]);
  float p2 = atof(argv[3]);
  cout<<size<<" "<<p1<<" "<<p2<<", 10000000 times for each"<<endl;
  cout<<"Results: "<<endl;
  for(int j=0; j<8; j++){
    cout<<"      ";
    for (int i=0; i<1; i++){
      cout<<  std::setw(6)<<std::setfill(' ')  <<monte_carlo(size,p1,p2)<<", ";
    } cout<<endl;
  } cout<<endl;
  
  return 0;
}

/* Function Implementations */

bool randint(float p){
    return (rand()%100000 < p*100000);
}

int max_stack_size_1(int vector_size, float p1, float p2){

/* index vectors  */
  vector<int> v1{-1};
  vector<int> v2{-1};
  vector<int> v_match{-3}; // a record for the matched indices
  for (int i=0; i<vector_size; i++) {
    bool on_1{}, on_2{};
    if (randint(p1)) {v1.push_back(i); on_1 = true;}
    if (randint(p2)) {v2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v_match.push_back(i);  
  }
/* simulate how pe takes in those 2 vectors */
  int max_length;
  int delta = abs((int)(v1.size() - v2.size()));
  if(v1.size() > v2.size()){
    max_length = v1.size();
    for(int i=0; i<delta; i++)
      v2.push_back(999);
  }else{
    max_length = v2.size();
    for(int i=0; i<delta; i++)
      v1.push_back(999);
  }

  // cout<<"v1: (size "<<v1.size()<<")";//test output for generated vectors
  // for (int i=0; i<v1.size(); i++){ 
  //   cout<<std::setw(3)<<std::setfill(' ')<<v1[i]<<" ";
  // } cout<<endl; 
  // cout<<"v2: (size "<<v2.size()<<")";
  // for (int i=0; i<v2.size(); i++){
  //   cout<<std::setw(3)<<std::setfill(' ')<<v2[i]<<" ";
  // } cout<<endl;
  // cout<<"v_m: ";
  // for (int i=0; i<v_match.size(); i++){
  //   cout<<std::setw(3)<<std::setfill(' ')<<v_match[i]<<" ";
  // } cout<<endl;


  int max_stack_size{};
  int current_stack_size{};
  vector<int> local_stack{};
  for (int i=0; i<max_length; i++) {
    // 若两者对齐，继续
    if (v1[i] == v2[i]) continue;
    // 若没对齐，且v1是匹配项
    if (find(v_match.begin(), v_match.end(), v1[i])!=v_match.end()) {
      // 如果v1 > v2，说明v2还没进入pe，那么把v1存入栈中
      if (v1[i] > v2[i]) current_stack_size++;
      // 反之v1 < v2，那么v2必然已在栈内，把v2弹出来就可以了
      else               current_stack_size--;
    }
    // 若没对齐，且v2是匹配项
    if (find(v_match.begin(), v_match.end(), v2[i])!=v_match.end()) {
      // 如果v2 > v1，说明v1还没进入pe，那么把v2存入栈中
      if (v2[i] > v1[i]) current_stack_size++;
      // 反之v2 < v1，那么v1必然已在栈内，把v1弹出来就可以了
      else               current_stack_size--;
    }
    // 此时栈经过一番增减，更新一次最大值
    max_stack_size = max(max_stack_size, current_stack_size);
    // cout<<current_stack_size<<", ";
  }

  return max_stack_size;
}

int max_stack_size_2(int vector_size, float p1, float p2){

/* index vectors  */
  vector<int> v1_1{-1};
  vector<int> v1_2{-1};
  vector<int> v2_1{-1};
  vector<int> v2_2{-1};
  vector<int> v1_match{-3}; // a record for the matched indices
  vector<int> v2_match{-3}; // a record for the matched indices
  for (int i=0; i<vector_size; i++) {
    bool on_1{}, on_2{};
    if (randint(p1)) {v1_1.push_back(i); on_1 = true;}
    if (randint(p2)) {v1_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v1_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v2_1.push_back(i); on_1 = true;}
    if (randint(p2)) {v2_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v2_match.push_back(i);  
  }

/* simulate how pe takes in those 2 vectors */
  int max_length = max(max(v1_1.size(), v1_2.size()), max(v2_1.size(), v2_2.size()));
  int max_stack_size{};
  int current_stack_size_1{};
  int current_stack_size_2{};
  for(int i = 0; i< max_length - (int)v1_1.size(); i++)
    v1_1.push_back(999);
  for(int i = 0; i< max_length - (int)v1_2.size(); i++)
    v1_2.push_back(999);
  for(int i = 0; i< max_length - (int)v2_1.size(); i++)
    v2_1.push_back(999);
  for(int i = 0; i< max_length - (int)v2_2.size(); i++)
    v2_2.push_back(999);

  vector<int> local_stack{};
  for (int i=0; i<max_length; i++) {
    if (v1_1[i] != v1_2[i]) {
      if (find(v1_match.begin(), v1_match.end(), v1_1[i])!=v1_match.end()) {
        if (v1_1[i] > v1_2[i]) current_stack_size_1++;
        else               current_stack_size_1--;
      }
      if (find(v1_match.begin(), v1_match.end(), v1_2[i])!=v1_match.end()) {
        if (v1_2[i] > v1_1[i]) current_stack_size_1++;
        else               current_stack_size_1--;
      }
    }
    if (v2_1[i] != v2_2[i]) {
      if (find(v2_match.begin(), v2_match.end(), v2_1[i])!=v2_match.end()) {
        if (v2_1[i] > v2_2[i]) current_stack_size_2++;
        else               current_stack_size_2--;
      }
      if (find(v2_match.begin(), v2_match.end(), v2_2[i])!=v2_match.end()) {
        if (v2_2[i] > v2_1[i]) current_stack_size_2++;
        else               current_stack_size_2--;
      }
    }

    max_stack_size = max(max_stack_size, current_stack_size_1 + current_stack_size_2);
  }

  return max_stack_size;
}

int max_stack_size_4(int vector_size, float p1, float p2){

/* index vectors  */
  vector<int> v1_1{-1};
  vector<int> v1_2{-1};
  vector<int> v2_1{-1};
  vector<int> v2_2{-1};
  vector<int> v3_1{-1};
  vector<int> v3_2{-1};
  vector<int> v4_1{-1};
  vector<int> v4_2{-1};
  vector<int> v1_match{-3}; // a record for the matched indices
  vector<int> v2_match{-3}; // a record for the matched indices
  vector<int> v3_match{-3}; // a record for the matched indices
  vector<int> v4_match{-3}; // a record for the matched indices
  for (int i=0; i<vector_size; i++) {
    bool on_1{}, on_2{};
    if (randint(p1)) {v1_1.push_back(i); on_1 = true;}
    if (randint(p2)) {v1_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v1_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v2_1.push_back(i); on_1 = true;}
    if (randint(p2)) {v2_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v2_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v3_1.push_back(i); on_1 = true;}
    if (randint(p2)) {v3_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v3_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v4_1.push_back(i); on_1 = true;}
    if (randint(p2)) {v4_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v4_match.push_back(i);  
  }

/* simulate how pe takes in those 2 vectors */
  int max_length = max( max(max(v1_1.size(), v1_2.size()), max(v2_1.size(), v2_2.size()))
                      , max(max(v3_1.size(), v3_2.size()), max(v4_1.size(), v4_2.size())));
  int max_stack_size{};
  int current_stack_size_1{};
  int current_stack_size_2{};
  int current_stack_size_3{};
  int current_stack_size_4{};
  for(int i = 0; i< max_length - (int)v1_1.size(); i++)
    v1_1.push_back(999);
  for(int i = 0; i< max_length - (int)v1_2.size(); i++)
    v1_2.push_back(999);
  for(int i = 0; i< max_length - (int)v2_1.size(); i++)
    v2_1.push_back(999);
  for(int i = 0; i< max_length - (int)v2_2.size(); i++)
    v2_2.push_back(999);
  for(int i = 0; i< max_length - (int)v3_1.size(); i++)
    v3_1.push_back(999);
  for(int i = 0; i< max_length - (int)v3_2.size(); i++)
    v3_2.push_back(999);
  for(int i = 0; i< max_length - (int)v4_1.size(); i++)
    v4_1.push_back(999);
  for(int i = 0; i< max_length - (int)v4_2.size(); i++)
    v4_2.push_back(999);

  for (int i=0; i<max_length; i++) {
    if (v1_1[i] != v1_2[i]) {
      if (find(v1_match.begin(), v1_match.end(), v1_1[i])!=v1_match.end()) {
        if (v1_1[i] > v1_2[i]) current_stack_size_1++;
        else               current_stack_size_1--;
      }
      if (find(v1_match.begin(), v1_match.end(), v1_2[i])!=v1_match.end()) {
        if (v1_2[i] > v1_1[i]) current_stack_size_1++;
        else               current_stack_size_1--;
      }
    }
    if (v2_1[i] != v2_2[i]) {
      if (find(v2_match.begin(), v2_match.end(), v2_1[i])!=v2_match.end()) {
        if (v2_1[i] > v2_2[i]) current_stack_size_2++;
        else               current_stack_size_2--;
      }
      if (find(v2_match.begin(), v2_match.end(), v2_2[i])!=v2_match.end()) {
        if (v2_2[i] > v2_1[i]) current_stack_size_2++;
        else               current_stack_size_2--;
      }
    }
    if (v3_1[i] != v3_2[i]) {
      if (find(v3_match.begin(), v3_match.end(), v3_1[i])!=v3_match.end()) {
        if (v3_1[i] > v3_2[i]) current_stack_size_3++;
        else               current_stack_size_3--;
      }
      if (find(v3_match.begin(), v3_match.end(), v3_2[i])!=v3_match.end()) {
        if (v3_2[i] > v3_1[i]) current_stack_size_3++;
        else               current_stack_size_3--;
      }
    }
    if (v4_1[i] != v4_2[i]) {
      if (find(v4_match.begin(), v4_match.end(), v4_1[i])!=v4_match.end()) {
        if (v4_1[i] > v4_2[i]) current_stack_size_4++;
        else               current_stack_size_4--;
      }
      if (find(v4_match.begin(), v4_match.end(), v4_2[i])!=v4_match.end()) {
        if (v4_2[i] > v4_1[i]) current_stack_size_4++;
        else               current_stack_size_4--;
      }
    }
    max_stack_size = max(max_stack_size, current_stack_size_1 + current_stack_size_2 + current_stack_size_3 + current_stack_size_4);
  }
  return max_stack_size;
}

int max_stack_size_8(int vector_size, float p1, float p2){

/* index vectors  */
  vector<int> v1_1{-1};
  vector<int> v1_2{-1};
  vector<int> v2_1{-1};
  vector<int> v2_2{-1};
  vector<int> v3_1{-1};
  vector<int> v3_2{-1};
  vector<int> v4_1{-1};
  vector<int> v4_2{-1};
  vector<int> v5_1{-1};
  vector<int> v5_2{-1};
  vector<int> v6_1{-1};
  vector<int> v6_2{-1};
  vector<int> v7_1{-1};
  vector<int> v7_2{-1};
  vector<int> v8_1{-1};
  vector<int> v8_2{-1};
  vector<int> v1_match{-3}; // a record for the matched indices
  vector<int> v2_match{-3}; // a record for the matched indices
  vector<int> v3_match{-3}; // a record for the matched indices
  vector<int> v4_match{-3}; // a record for the matched indices
  vector<int> v5_match{-3}; // a record for the matched indices
  vector<int> v6_match{-3}; // a record for the matched indices
  vector<int> v7_match{-3}; // a record for the matched indices
  vector<int> v8_match{-3}; // a record for the matched indices
  for (int i=0; i<vector_size; i++) {
    bool on_1{}, on_2{};
    if (randint(p1)) {v1_1.push_back(i); on_1 = true;} // 1
    if (randint(p2)) {v1_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v1_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v2_1.push_back(i); on_1 = true;} // 2
    if (randint(p2)) {v2_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v2_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v3_1.push_back(i); on_1 = true;} // 3
    if (randint(p2)) {v3_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v3_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v4_1.push_back(i); on_1 = true;} // 4
    if (randint(p2)) {v4_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v4_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v5_1.push_back(i); on_1 = true;} // 5
    if (randint(p2)) {v5_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v5_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v6_1.push_back(i); on_1 = true;} // 6
    if (randint(p2)) {v6_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v6_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v7_1.push_back(i); on_1 = true;} // 7
    if (randint(p2)) {v7_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v7_match.push_back(i);  
    on_1 = false; on_2 = false;
    if (randint(p1)) {v8_1.push_back(i); on_1 = true;} // 8
    if (randint(p2)) {v8_2.push_back(i); on_2 = true;}
    if (on_1 && on_2) v8_match.push_back(i);  
  }

/* simulate how pe takes in those 2 vectors */
  int max_length = max( max( max(max(v1_1.size(), v1_2.size()), max(v2_1.size(), v2_2.size()))
                      , max(max(v3_1.size(), v3_2.size()), max(v4_1.size(), v4_2.size())))
    ,              max( max(max(v5_1.size(), v5_2.size()), max(v6_1.size(), v6_2.size()))
                      , max(max(v7_1.size(), v7_2.size()), max(v8_1.size(), v8_2.size())))
  );
  int max_stack_size{};
  int current_stack_size_1{};
  int current_stack_size_2{};
  int current_stack_size_3{};
  int current_stack_size_4{};
  int current_stack_size_5{};
  int current_stack_size_6{};
  int current_stack_size_7{};
  int current_stack_size_8{};
  for(int i = 0; i< max_length - (int)v1_1.size(); i++)
    v1_1.push_back(999);
  for(int i = 0; i< max_length - (int)v1_2.size(); i++)
    v1_2.push_back(999);
  for(int i = 0; i< max_length - (int)v2_1.size(); i++)
    v2_1.push_back(999);
  for(int i = 0; i< max_length - (int)v2_2.size(); i++)
    v2_2.push_back(999);
  for(int i = 0; i< max_length - (int)v3_1.size(); i++)
    v3_1.push_back(999);
  for(int i = 0; i< max_length - (int)v3_2.size(); i++)
    v3_2.push_back(999);
  for(int i = 0; i< max_length - (int)v4_1.size(); i++)
    v4_1.push_back(999);
  for(int i = 0; i< max_length - (int)v4_2.size(); i++)
    v4_2.push_back(999);
  
  for(int i = 0; i< max_length - (int)v5_1.size(); i++)
    v5_1.push_back(999);
  for(int i = 0; i< max_length - (int)v5_2.size(); i++)
    v5_2.push_back(999);
  for(int i = 0; i< max_length - (int)v6_1.size(); i++)
    v6_1.push_back(999);
  for(int i = 0; i< max_length - (int)v6_2.size(); i++)
    v6_2.push_back(999);
  for(int i = 0; i< max_length - (int)v7_1.size(); i++)
    v7_1.push_back(999);
  for(int i = 0; i< max_length - (int)v7_2.size(); i++)
    v7_2.push_back(999);
  for(int i = 0; i< max_length - (int)v8_1.size(); i++)
    v8_1.push_back(999);
  for(int i = 0; i< max_length - (int)v8_2.size(); i++)
    v8_2.push_back(999);

  for (int i=0; i<max_length; i++) {
    if (v1_1[i] != v1_2[i]) { // 1
      if (find(v1_match.begin(), v1_match.end(), v1_1[i])!=v1_match.end()) {
        if (v1_1[i] > v1_2[i]) current_stack_size_1++;
        else               current_stack_size_1--;
      }
      if (find(v1_match.begin(), v1_match.end(), v1_2[i])!=v1_match.end()) {
        if (v1_2[i] > v1_1[i]) current_stack_size_1++;
        else               current_stack_size_1--;
      }
    }
    if (v2_1[i] != v2_2[i]) { // 2
      if (find(v2_match.begin(), v2_match.end(), v2_1[i])!=v2_match.end()) {
        if (v2_1[i] > v2_2[i]) current_stack_size_2++;
        else               current_stack_size_2--;
      }
      if (find(v2_match.begin(), v2_match.end(), v2_2[i])!=v2_match.end()) {
        if (v2_2[i] > v2_1[i]) current_stack_size_2++;
        else               current_stack_size_2--;
      }
    }
    if (v3_1[i] != v3_2[i]) { // 3
      if (find(v3_match.begin(), v3_match.end(), v3_1[i])!=v3_match.end()) {
        if (v3_1[i] > v3_2[i]) current_stack_size_3++;
        else               current_stack_size_3--;
      }
      if (find(v3_match.begin(), v3_match.end(), v3_2[i])!=v3_match.end()) {
        if (v3_2[i] > v3_1[i]) current_stack_size_3++;
        else               current_stack_size_3--;
      }
    }
    if (v4_1[i] != v4_2[i]) { // 4
      if (find(v4_match.begin(), v4_match.end(), v4_1[i])!=v4_match.end()) {
        if (v4_1[i] > v4_2[i]) current_stack_size_4++;
        else               current_stack_size_4--;
      }
      if (find(v4_match.begin(), v4_match.end(), v4_2[i])!=v4_match.end()) {
        if (v4_2[i] > v4_1[i]) current_stack_size_4++;
        else               current_stack_size_4--;
      }
    }
    if (v5_1[i] != v5_2[i]) { // 5
      if (find(v5_match.begin(), v5_match.end(), v5_1[i])!=v5_match.end()) {
        if (v5_1[i] > v5_2[i]) current_stack_size_5++;
        else               current_stack_size_5--;
      }
      if (find(v5_match.begin(), v5_match.end(), v5_2[i])!=v5_match.end()) {
        if (v5_2[i] > v5_1[i]) current_stack_size_5++;
        else               current_stack_size_5--;
      }
    }
    if (v6_1[i] != v6_2[i]) { // 6
      if (find(v6_match.begin(), v6_match.end(), v6_1[i])!=v6_match.end()) {
        if (v6_1[i] > v6_2[i]) current_stack_size_6++;
        else               current_stack_size_6--;
      }
      if (find(v6_match.begin(), v6_match.end(), v6_2[i])!=v6_match.end()) {
        if (v6_2[i] > v6_1[i]) current_stack_size_6++;
        else               current_stack_size_6--;
      }
    }
    if (v7_1[i] != v7_2[i]) { // 7
      if (find(v7_match.begin(), v7_match.end(), v7_1[i])!=v7_match.end()) {
        if (v7_1[i] > v7_2[i]) current_stack_size_7++;
        else               current_stack_size_7--;
      }
      if (find(v7_match.begin(), v7_match.end(), v7_2[i])!=v7_match.end()) {
        if (v7_2[i] > v7_1[i]) current_stack_size_7++;
        else               current_stack_size_7--;
      }
    }
    if (v8_1[i] != v8_2[i]) { // 8
      if (find(v8_match.begin(), v8_match.end(), v8_1[i])!=v8_match.end()) {
        if (v8_1[i] > v8_2[i]) current_stack_size_8++;
        else               current_stack_size_8--;
      }
      if (find(v8_match.begin(), v8_match.end(), v8_2[i])!=v8_match.end()) {
        if (v8_2[i] > v8_1[i]) current_stack_size_8++;
        else               current_stack_size_8--;
      }
    }
    max_stack_size = max(max_stack_size, current_stack_size_1 + current_stack_size_2 + current_stack_size_3 + current_stack_size_4
                                       + current_stack_size_5 + current_stack_size_6 + current_stack_size_7 + current_stack_size_8);
  }
  return max_stack_size;
}

float monte_carlo(int vector_size, float p1, float p2, int times){
  float temp_sum{};
  float temp_max{};
  for (int i=0; i<times; i++){
    // float temp_result = max_stack_size_1(vector_size, p1, p2);
    // float temp_result = 0.5*max_stack_size_2(vector_size, p1, p2);
    // float temp_result = max_stack_size_4(vector_size, p1, p2);
    float temp_result = max_stack_size_8(vector_size, p1,p2);
    temp_max = max(temp_max, temp_result);
  }
  return temp_max;
}

// 0.1 4   0.2