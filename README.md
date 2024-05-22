# systolic-array-in-verilog

用verilog实现的脉动阵列。

本代码的目的是用verilog实现可以参数化生成的脉动阵列（包括PE阵列和配套IO），通过eda工具对生成代码进行综合即可估算脉动阵列各部分的资源占用、功耗。
<<<<<<< HEAD
=======

to do:

- ~~output略有些bug~~
- 标定各组件体积和fpga资源用量的关系
  - ~~问题：阵列的资源消耗似乎不是O(n2)而是O(n)~~
  - 散装input可以正常综合，封装后的input综合出来是0功耗
  - xilinx这个动不动综合个zero utilization也太抽象了，我是不明白加法器有啥综合不了的
- 整定计算延时、资源、功耗 与 尺寸、数量的关系
- 搞个自动脚本


>>>>>>> 77500099476f4ef42f9f9d26c668fbf5660b24ab
