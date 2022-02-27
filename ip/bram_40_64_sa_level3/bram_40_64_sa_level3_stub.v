// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Sat Nov 20 09:45:58 2021
// Host        : DESKTOP-8L3D41F running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/Xilinx/project/DecisionTree_IPC_10k/DecisionTree_IPC_10k.srcs/sources_1/ip/bram_40_64_sa_level3/bram_40_64_sa_level3_stub.v
// Design      : bram_40_64_sa_level3
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvu9p-flga2104-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2020.1" *)
module bram_40_64_sa_level3(clka, wea, addra, dina, douta, clkb, web, addrb, dinb, 
  doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[5:0],dina[39:0],douta[39:0],clkb,web[0:0],addrb[5:0],dinb[39:0],doutb[39:0]" */;
  input clka;
  input [0:0]wea;
  input [5:0]addra;
  input [39:0]dina;
  output [39:0]douta;
  input clkb;
  input [0:0]web;
  input [5:0]addrb;
  input [39:0]dinb;
  output [39:0]doutb;
endmodule
