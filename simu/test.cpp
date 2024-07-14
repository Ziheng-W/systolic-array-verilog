# include <iostream>
# include <time.h>
# include <ctime>
# include <stdlib.h>
# include <vector>
# include <algorithm>
#include <cstdlib>

using namespace std;

int main(){
  vector<vector<int>> v{};
  v.push_back({});
  v.push_back({});
  v[0].push_back(1);
  v[1].push_back(2);
  cout<<v[0][0]<<" "<<v[1][0]<<endl;
  // v.pushback(vector<int>{});
  // v[0].push_back(1);
  // v.push_back(vector<int>{2});
  // cout<<v[0][0]<<endl;
}