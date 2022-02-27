# MBitTree-on-FPGA
FPT 2021 paper: High-performance pipeline architecture for packet classification accelerator in DPU

# 在FPGA上实现决策树算法
决策树等报文分类软件算法具有高度的灵活性，然而其分类速度相比硬件解决方案差距在一个数量级以上，因此在FPGA等硬件平台上实现决策树，能够兼顾软件灵活性和硬件高性能的优点，满足线速度分类的需求。硬件实现决策树的基本思想是将软件构建的决策树映射到FPGA的流水线中。
本文提出了一种基于FPGA的高吞吐量报文分类体系结构，可以实现250Gbps的吞吐量并且在单个NetFPGA-SUME上存储100K的规则集。该体系结构基于一种内存效率高的决策树算法MBitTree（https://github.com/tanjing09/MBitTree）。

# 代码层次
‘MBitTree.v’ 顶层模块，包括三条线性流水线。
‘pipeline_DA.v’、‘pipeline_SA.v’、‘pipeline_SADA.v’ 流水线模块。
‘TreeLevel*’ 树遍历。
‘ruleMatch.v’ 规则匹配。
‘final_prio_solver.v’ 优先级解析。
‘IP’ 项目所需IP，主要为BRAM。
‘testbench_sa.v’ 对流水线进行仿真测试。
