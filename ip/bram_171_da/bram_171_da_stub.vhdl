-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Sat Nov 20 09:46:46 2021
-- Host        : DESKTOP-8L3D41F running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               e:/Xilinx/project/DecisionTree_IPC_10k/DecisionTree_IPC_10k.srcs/sources_1/ip/bram_171_da/bram_171_da_stub.vhdl
-- Design      : bram_171_da
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcvu9p-flga2104-2L-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bram_171_da is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 1367 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 1367 downto 0 );
    clkb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 1367 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 1367 downto 0 )
  );

end bram_171_da;

architecture stub of bram_171_da is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[9:0],dina[1367:0],douta[1367:0],clkb,web[0:0],addrb[9:0],dinb[1367:0],doutb[1367:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_4,Vivado 2020.1";
begin
end;
