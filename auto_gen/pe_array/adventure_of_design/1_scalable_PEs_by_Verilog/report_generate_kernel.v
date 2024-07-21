Utilization Design Information

Table of Contents
-----------------
1. Slice Logic
1.1 Summary of Registers by Type
2. Memory
3. DSP
4. IO and GT Specific
5. Clocking
6. Specific Feature
7. Primitives
8. Black Boxes
9. Instantiated Netlists

1. Slice Logic
--------------

+----------------------------+------+-------+-----------+-------+
|          Site Type         | Used | Fixed | Available | Util% |
+----------------------------+------+-------+-----------+-------+
| Slice LUTs*                | 1312 |     0 |    134600 |  0.97 |
|   LUT as Logic             | 1024 |     0 |    134600 |  0.76 |
|   LUT as Memory            |  288 |     0 |     46200 |  0.62 |
|     LUT as Distributed RAM |    0 |     0 |           |       |
|     LUT as Shift Register  |  288 |     0 |           |       |
| Slice Registers            | 2880 |     0 |    269200 |  1.07 |
|   Register as Flip Flop    | 2880 |     0 |    269200 |  1.07 |
|   Register as Latch        |    0 |     0 |    269200 |  0.00 |
| F7 Muxes                   |    0 |     0 |     67300 |  0.00 |
| F8 Muxes                   |    0 |     0 |     33650 |  0.00 |
+----------------------------+------+-------+-----------+-------+
* Warning! The Final LUT count, after physical optimizations and full implementation, is typically lower. Run opt_design after synthesis, if not already completed, for a more realistic count.


1.1 Summary of Registers by Type
--------------------------------

+-------+--------------+-------------+--------------+
| Total | Clock Enable | Synchronous | Asynchronous |
+-------+--------------+-------------+--------------+
| 0     |            _ |           - |            - |
| 0     |            _ |           - |          Set |
| 0     |            _ |           - |        Reset |
| 0     |            _ |         Set |            - |
| 0     |            _ |       Reset |            - |
| 0     |          Yes |           - |            - |
| 0     |          Yes |           - |          Set |
| 0     |          Yes |           - |        Reset |
| 0     |          Yes |         Set |            - |
| 2880  |          Yes |       Reset |            - |
+-------+--------------+-------------+--------------+


2. Memory
---------

+----------------+------+-------+-----------+-------+
|    Site Type   | Used | Fixed | Available | Util% |
+----------------+------+-------+-----------+-------+
| Block RAM Tile |    0 |     0 |       365 |  0.00 |
|   RAMB36/FIFO* |    0 |     0 |       365 |  0.00 |
|   RAMB18       |    0 |     0 |       730 |  0.00 |
+----------------+------+-------+-----------+-------+
* Note: Each Block RAM Tile only has one FIFO logic available and therefore can accommodate only one FIFO36E1 or one FIFO18E1. However, if a FIFO18E1 occupies a Block RAM Tile, that tile can still accommodate a RAMB18E1


3. DSP
------

+----------------+------+-------+-----------+-------+
|    Site Type   | Used | Fixed | Available | Util% |
+----------------+------+-------+-----------+-------+
| DSPs           |   64 |     0 |       740 |  8.65 |
|   DSP48E1 only |   64 |       |           |       |
+----------------+------+-------+-----------+-------+


4. IO and GT Specific
---------------------

+-----------------------------+------+-------+-----------+--------+
|          Site Type          | Used | Fixed | Available |  Util% |
+-----------------------------+------+-------+-----------+--------+
| Bonded IOB                  | 1729 |     0 |       500 | 345.80 |
| Bonded IPADs                |    0 |     0 |        50 |   0.00 |
| Bonded OPADs                |    0 |     0 |        32 |   0.00 |
| PHY_CONTROL                 |    0 |     0 |        10 |   0.00 |
| PHASER_REF                  |    0 |     0 |        10 |   0.00 |
| OUT_FIFO                    |    0 |     0 |        40 |   0.00 |
| IN_FIFO                     |    0 |     0 |        40 |   0.00 |
| IDELAYCTRL                  |    0 |     0 |        10 |   0.00 |
| IBUFDS                      |    0 |     0 |       480 |   0.00 |
| GTPE2_CHANNEL               |    0 |     0 |        16 |   0.00 |
| PHASER_OUT/PHASER_OUT_PHY   |    0 |     0 |        40 |   0.00 |
| PHASER_IN/PHASER_IN_PHY     |    0 |     0 |        40 |   0.00 |
| IDELAYE2/IDELAYE2_FINEDELAY |    0 |     0 |       500 |   0.00 |
| IBUFDS_GTE2                 |    0 |     0 |         8 |   0.00 |
| ILOGIC                      |    0 |     0 |       500 |   0.00 |
| OLOGIC                      |    0 |     0 |       500 |   0.00 |
+-----------------------------+------+-------+-----------+--------+


5. Clocking
-----------

+------------+------+-------+-----------+-------+
|  Site Type | Used | Fixed | Available | Util% |
+------------+------+-------+-----------+-------+
| BUFGCTRL   |    1 |     0 |        32 |  3.13 |
| BUFIO      |    0 |     0 |        40 |  0.00 |
| MMCME2_ADV |    0 |     0 |        10 |  0.00 |
| PLLE2_ADV  |    0 |     0 |        10 |  0.00 |
| BUFMRCE    |    0 |     0 |        20 |  0.00 |
| BUFHCE     |    0 |     0 |       120 |  0.00 |
| BUFR       |    0 |     0 |        40 |  0.00 |
+------------+------+-------+-----------+-------+


6. Specific Feature
-------------------

+-------------+------+-------+-----------+-------+
|  Site Type  | Used | Fixed | Available | Util% |
+-------------+------+-------+-----------+-------+
| BSCANE2     |    0 |     0 |         4 |  0.00 |
| CAPTUREE2   |    0 |     0 |         1 |  0.00 |
| DNA_PORT    |    0 |     0 |         1 |  0.00 |
| EFUSE_USR   |    0 |     0 |         1 |  0.00 |
| FRAME_ECCE2 |    0 |     0 |         1 |  0.00 |
| ICAPE2      |    0 |     0 |         2 |  0.00 |
| PCIE_2_1    |    0 |     0 |         1 |  0.00 |
| STARTUPE2   |    0 |     0 |         1 |  0.00 |
| XADC        |    0 |     0 |         1 |  0.00 |
+-------------+------+-------+-----------+-------+


7. Primitives
-------------

+----------+------+---------------------+
| Ref Name | Used | Functional Category |
+----------+------+---------------------+
| FDRE     | 2880 |        Flop & Latch |
| OBUF     | 1408 |                  IO |
| LUT3     |  512 |                 LUT |
| LUT2     |  512 |                 LUT |
| IBUF     |  321 |                  IO |
| SRL16E   |  288 |  Distributed Memory |
| CARRY4   |  256 |          CarryLogic |
| DSP48E1  |   64 |    Block Arithmetic |
| BUFG     |    1 |               Clock |
+----------+------+---------------------+


8. Black Boxes
--------------

+----------+------+
| Ref Name | Used |
+----------+------+


9. Instantiated Netlists
------------------------
