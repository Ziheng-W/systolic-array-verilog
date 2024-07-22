### Generate Scalable PE Array by Verilog
### 用verilog生成scalable的纯PE阵列

PE单体非常好写，但复数PE接线很麻烦。一开始的做法是用c++写脚本批量化生成，主要有两个问题：
1. 调用脚本比代码本身的parameter麻烦
2. 脚本可拓展性差，改代码需要先研究代码本身怎么改、再研究生成脚本怎么改

用脚本做自动化生成固然是必要的，但是如果底层的纯阵列也要靠脚本，脚本就失去了抽象性，起不到控制复杂度的作用。
因此，在纯阵列这一块上，还是应该转用verilog语言本身的generate来做批量化生成，纯阵列的体积等参数直接使用Verilog本身的parameter来控制。

### How to test correctness of generate-for?
### generate-for 语句内部的接线如何确保正确？

由于之前用脚本写的纯阵列可以确定是靠谱的，我就没有直接测自动生成代码的接线正确性（赶论文没时间了）。
这里留档了两种写法在Vivado里综合出的不同报告，可见logic LUT、DSP用量相同，memory LUT和register的总用量几乎一致，
加上接线的时候严格参考了之前写的脚本逻辑，可以认为功能上是等效的，如果日后有问题再说吧。

至于比原来的脚本版多用了IOB，则是因为新版代码额外增加了对角线的输出接口，便于后续调用。

整个流程给我的经验是
1. 接线规划成熟的话，generate + assign 比 c++ 高效
2. generate 使用的一维数组和 c++ 脚本使用的零散数组综合效率相同