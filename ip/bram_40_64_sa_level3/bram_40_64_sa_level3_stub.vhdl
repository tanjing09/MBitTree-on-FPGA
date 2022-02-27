-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Sat Nov 20 09:45:58 2021
-- Host        : DESKTOP-8L3D41F running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               e:/Xilinx/project/DecisionTree_IPC_10k/DecisionTree_IPC_10k.srcs/sources_1/ip/bram_40_64_sa_level3/bram_40_64_sa_level3_stub.vhdl
-- Design      : bram_40_64_sa_level3
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcvu9p-flga2104-2L-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bram_40_64_sa_level3 is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 5 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 39 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 39 downto 0 );
    clkb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 5 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 39 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 39 downto 0 )
  );

end bram_40_64_sa_level3;

architecture stub of bram_40_64_sa_level3 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[5:0],dina[39:0],douta[39:0],clkb,web[0:0],addrb[5:0],dinb[39:0],doutb[39:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_4,Vivado 2020.1";
begin
end;
