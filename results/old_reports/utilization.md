### each PE with rounding

| bitwidth | LUT | DSP48E1 | register |
| --- | --- | --- | --- |
| 32  | 47  | 3   | 128 |
| 16  | 16  | 1   | 64  |
| 8   | 41  | 0   | 32  |
| 4   | 10  | 0   | 16  |

规整且符合预期，打包成阵列直接乘上PE数目就可以。

### finish decider

| size | LUT | DSP48E1 | register |
| --- | --- | --- | --- |
| 32*32 | 41  | 0   | 38  |
| 16*16 | 19  | 0   | 21  |
| 8*8 | 7   | 0   | 14  |
| 4*4 | 4   | 0   | 8   |