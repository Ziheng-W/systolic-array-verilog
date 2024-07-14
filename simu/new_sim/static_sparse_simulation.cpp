# include <iostream>
# include <time.h>
# include <ctime>
# include <stdlib.h>
# include <vector>
# include <algorithm>
# include <iomanip>
# include <cstdlib>
using namespace std;

// v_size: 原向量长度
// v_cnt:  同侧向量个数
// p:      稀疏度
int monte_carlo(int v_size, int v_cnt, float p, bool display = 0);
void print_vector(vector<int> &v, bool show_size);
void print_vector(vector<bool> &v, bool show_size);
bool random_bit(float p);

int main(int argc, char* argv[]){
  srand((unsigned)time(NULL));
  int size = atoi(argv[1]);
  int cnt = atoi(argv[2]);
  float sparsity = atof(argv[3]);
  float n =0;
  for( int i=0; i<100; i++){
    // n += monte_carlo(size, cnt, sparsity, 1);
    n = max((int)n, monte_carlo(size, cnt, sparsity, 1));

  }
  cout<<"n: ";
  cout<<n<<endl;
  // cout<<n/100<<endl;
  return 0;
}

bool random_bit(float p){
    return (rand()%100000 < p*100000);
}

void print_vector(vector<int> &v, bool show_size = 0){
  for(int i=0; i<v.size(); i++)
    cout<<std::setw(2)<<std::setfill(' ')<<v[i]<<" ";
  if (show_size) 
    cout<<"size: "<<v.size();
  cout<<endl;
}

void print_vector(vector<bool> &v, bool show_size = 0){
  for(int i=0; i<v.size(); i++)
    cout<<std::setw(2)<<std::setfill(' ')<<v[i]<<" ";
  if (show_size) 
    cout<<"size: "<<v.size();
  cout<<endl;
}

int monte_carlo(int v_size, int v_cnt, float p, bool display) {
  int maxi_cycle{};
  int curr_mem_size{};
  vector<vector<int>> curr_mem_sizes{};
  bool pop_request{};
  int maxi_length{};



  // 生成稀疏向量、稠密向量和对应掩码
  vector<vector<int>> sparse_vectors{};
  vector<int> masked_dense{};
  vector<vector<bool>> individual_masks{};
  vector<bool> universal_mask{};
  for (int i=0; i<v_cnt; i++) {
    sparse_vectors.push_back(vector<int>{});
    individual_masks.push_back(vector<bool>{});
    for (int j=0; j<v_size; j++) {
      if (random_bit(p)) {
        sparse_vectors[i].push_back(j);
        individual_masks[i].push_back(1);
      } else {
        individual_masks[i].push_back(0);
      }
    }
  }
  for (int i=0; i<v_size; i++) {
    bool temp{};
    for (int j=0; j<v_cnt; j++)
      temp = temp || individual_masks[j][i];
    universal_mask.push_back(temp);
    if(temp)
      masked_dense.push_back(i);
  }
  // 生成左侧输入
  vector<vector<int>> left_input{};
  for(int i=0; i<v_cnt; i++){
    left_input.push_back(vector<int>{});
    if(sparse_vectors[i].size()*3 > masked_dense.size()){
      for(int j=0; j<sparse_vectors[i].size(); j++){
        left_input[i].push_back(sparse_vectors[i][j]);
        left_input[i].push_back(sparse_vectors[i][j]);
      }  
    }else{
      for(int j=0; j<sparse_vectors[i].size(); j++){
        left_input[i].push_back(sparse_vectors[i][j]);
        left_input[i].push_back(sparse_vectors[i][j]);
        // left_input[i].push_back(sparse_vectors[i][j]);
      }  
    }
    
  }
  
  if(display){
    cout<<"left inputs: "<<endl;
    for(int m=0; m<v_cnt; m++)
      print_vector(left_input[m]);
    cout<<"up inputs: "<<endl;
    print_vector(masked_dense);
    cout<<"simulation: "<<endl;
  }

 

  for (int k=0; k<v_cnt; k++){
    curr_mem_sizes.push_back(vector<int>{});  
    for(int kk=0; kk<k; kk++) {
      curr_mem_sizes[k].push_back(0);
    }
    maxi_cycle = max(masked_dense.size(), left_input[k].size());
    curr_mem_size = 0;
    pop_request = 0;
    int last_left{-1};
    for(int i=masked_dense.size(); i<maxi_cycle; i++){
      masked_dense.push_back(99);
    }
    for(int i=left_input[k].size(); i<maxi_cycle; i++){
      left_input[k].push_back(99);
    }
    for(int i=0; i<maxi_cycle; i++){
      // 若收到出栈请求，则出栈一次
      if(pop_request){
        pop_request = false;
        curr_mem_size--;
      }
      if (left_input[k][i] > masked_dense[i]) {
        if (last_left == left_input[k][i] && left_input[k][i]!=99) 
          curr_mem_size++;
        if (individual_masks[k][masked_dense[i]])
          pop_request = true;
      }
      if (left_input[k][i] < masked_dense[i]) {
        if (last_left != left_input[k][i]) 
          pop_request = true;
        if (individual_masks[k][masked_dense[i]])
          curr_mem_size++;
      }
      curr_mem_sizes[k].push_back(curr_mem_size);
      last_left = left_input[k][i];
    }
    // maxi_length = min(maxi_length, (int)curr_mem_sizes[k].size());
  }

  if(display){
    for(int k = 0; k<v_cnt; k++)
      print_vector(curr_mem_sizes[k],1);
  }

  int maxi_mem_size{};
  int temp{};
  for(int i=0; i<curr_mem_sizes[0].size(); i++){
    temp = 0;
    for(int j=0; j<v_cnt; j++){
      temp += curr_mem_sizes[j][i];
    }
    cout<<std::setw(2)<<std::setfill(' ')<<temp<<" ";
    maxi_mem_size = max(maxi_mem_size, temp);
  }
  cout<<endl;
  return maxi_mem_size; 
}
