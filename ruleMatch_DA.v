`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/24 14:54:13
// Design Name: 
// Module Name: rule_pipeline
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ruleMatch_DA #(
    // the width of packet header and node
    parameter   PACKET_WIDTH = 104,
    parameter   NODE_WIDTH = 40, 
    // data structure of leafnode
    parameter   LEAF_ADDR = 12,
    // the width of a rule in ruleset, sip/prefix, dip/prefix, sport_low, sport_high, dport_low, dport_high, proto/prefix, priority, action
    parameter   RULE_ID = 14,
    parameter   RULE_WIDTH = 171
)

(
    input clk,
    input RSTn,
    
    input wire [NODE_WIDTH-1:0]     node_in1,
    input wire [PACKET_WIDTH-1:0]   packet_in1,
    input wire                      data_valid_in1,
    input wire [NODE_WIDTH-1:0]     node_in2,
    input wire [PACKET_WIDTH-1:0]   packet_in2,
    input wire                      data_valid_in2,
        
    output reg [8*RULE_ID-1:0]     rule_pri1,
    output reg [8-1:0]             match_flag1,
    output reg                     data_valid_out1,
    output reg [8*RULE_ID-1:0]     rule_pri2,
    output reg [8-1:0]             match_flag2,
    output reg                     data_valid_out2
    );
    
    /*  Leaf-node data structure
    reg [0:0]  nodetype;                // 1 bits, which '0' means internal node, and '1' means leafnode
    reg [3:1]  level;                   // 4 bits, the level of the tree node lie
    reg [11:4] NumRules                  // 8 bits, number of rules in leaf node, which use the one hot code
    reg [23:12] baseAddr;       `       // 12 bits for leafnode pointer, can indicate 4096 leafnodes
    or reg [26:12]                      // 15 bits, for 100k rulesets
    */
    
     /* rule structure
    reg [31:0]  sip;       [37:32] prefix_sip;         // sip and prefix length,32+6 bit
    reg [69:38]  dip;      [75:70] perfix_sip;         // dip and prefxi length, 32+6 bit
    reg [91:76] sp_low;    [107:92] sp_high;           // bodunry of sport, 16+16 bit
    reg [123:108] dp_low;  [139:124] dp_high;      `   // bodunry of dport, 16+16 bit
    reg [147:140] pro;     [148]  prefix_pro;          // bodunry of pro,   8+1 bit
    reg [162:149] priority;                            // priority of rules, 14 bit
    reg [170:163] action;                              // action if matched , 8 bit
    or reg[165:149] priority;                           //17 bits for 100k rulesets
    reg [170:166] action;                               //5 bits for 100k rulesets
    */
    
    wire [8*RULE_WIDTH-1:0] dout1, dout2;
    wire [RULE_WIDTH-1:0]   rule_node1 [7:0];
    wire [RULE_WIDTH-1:0]   rule_node2 [7:0];
    wire [8-1:0] addr1, addr2;
    
    wire [8-1:0] temp_flag1, temp_flag2;
    
    assign addr1 = node_in1[21:12];
    assign addr2 = node_in2[21:12];
    
    bram_171_da rule_da(
    .clka (clk),
    .wea (1'b0),
    .addra (addr1),
    .dina (),
    .douta (dout1),
    .clkb (clk),
    .web (1'b0),
    .addrb (addr2),
    .dinb (),
    .doutb (dout2)
    );  

    //get the value of eaah rule    
    assign {rule_node1[7], rule_node1[6], rule_node1[5], rule_node1[4],
            rule_node1[3], rule_node1[2], rule_node1[1], rule_node1[0]}= dout1;
                
    assign {rule_node2[7], rule_node2[6], rule_node2[5], rule_node2[4],
            rule_node2[3], rule_node2[2], rule_node2[1], rule_node2[0]}= dout2;
     
     
     //declare value to transmit the data after two clock cycles
     reg [PACKET_WIDTH-1:0] temp_packet1, sec_temp_packet1, temp_packet2, sec_temp_packet2;
     reg [NODE_WIDTH-1:0]   temp_node1, sec_temp_node1, temp_node2, sec_temp_node2;
     reg  temp_valid1, temp_valid2, sec_temp_valid1, sec_temp_valid2;
     
     // handle the first packet
     always@(posedge clk or negedge RSTn) begin
        if(!RSTn)   begin
            rule_pri1 <= 112'b0;
            match_flag1 <= 8'b0;
            data_valid_out1 <= 1'b0;
        end else begin
            rule_pri1 <= {rule_node1[7][162:149], rule_node1[6][162:149], rule_node1[5][162:149], rule_node1[4][162:149],
                            rule_node1[3][162:149], rule_node1[2][162:149], rule_node1[1][162:149], rule_node1[0][162:149]}; 
            temp_packet1 <= packet_in1;
            sec_temp_packet1 <= temp_packet1;
            
            temp_valid1 <= data_valid_in1;
            sec_temp_valid1 <= temp_valid1;
            data_valid_out1 <= sec_temp_valid1;
            
            temp_node1 <= node_in1;
            sec_temp_node1 <= temp_node1;
            
            match_flag1[0] <= ( rule_node1[0][31:0] == (~(32'hFFFF_FFFF>>rule_node1[0][37:32]) & sec_temp_packet1[31:0]) ) &&
                ( rule_node1[0][69:38] == (~(32'hFFFF_FFFF>>rule_node1[0][75:70]) & sec_temp_packet1[63:32]) ) &&
                ( (sec_temp_packet1[79:64] >= rule_node1[0][91:76]) && (sec_temp_packet1[79:64] <= rule_node1[0][107:92]) ) &&
                ( (sec_temp_packet1[95:80] >= rule_node1[0][123:108]) && (sec_temp_packet1[95:80] <= rule_node1[0][139:124]) ) &&
                ( (sec_temp_packet1[103:96] == rule_node1[0][147:140]) || ~(rule_node1[0][148]) ) && sec_temp_node1[11];

            //match the secnod rule
            match_flag1[1] <= ( rule_node1[1][31:0] == (~(32'hFFFF_FFFF>>rule_node1[1][37:32]) & sec_temp_packet1[31:0]) ) &&
                ( rule_node1[1][69:38] == (~(32'hFFFF_FFFF>>rule_node1[1][75:70]) & sec_temp_packet1[63:32]) ) &&
                ( (sec_temp_packet1[79:64] >= rule_node1[1][91:76]) && (sec_temp_packet1[79:64] <= rule_node1[1][107:92]) ) &&
                ( (sec_temp_packet1[95:80] >= rule_node1[1][123:108]) && (sec_temp_packet1[95:80] <= rule_node1[1][139:124]) ) &&
                ( (sec_temp_packet1[103:96] == rule_node1[1][147:140]) || ~(rule_node1[1][148]) ) && sec_temp_node1[10];
                
            //match the third rule
            match_flag1[2] <= ( rule_node1[2][31:0] == (~(32'hFFFF_FFFF>>rule_node1[2][37:32]) & sec_temp_packet1[31:0]) ) &&
                ( rule_node1[2][69:38] == (~(32'hFFFF_FFFF>>rule_node1[2][75:70]) & sec_temp_packet1[63:32]) ) &&
                ( (sec_temp_packet1[79:64] >= rule_node1[2][91:76]) && (sec_temp_packet1[79:64] <= rule_node1[2][107:92]) ) &&
                ( (sec_temp_packet1[95:80] >= rule_node1[2][123:108]) && (sec_temp_packet1[95:80] <= rule_node1[2][139:124]) ) &&
                ( (sec_temp_packet1[103:96] == rule_node1[2][147:140]) || ~(rule_node1[2][148]) ) && sec_temp_node1[9];
                
            //match the fourth rule
            match_flag1[3] <= ( rule_node1[3][31:0] == (~(32'hFFFF_FFFF>>rule_node1[3][37:32]) & sec_temp_packet1[31:0]) ) &&
                ( rule_node1[3][69:38] == (~(32'hFFFF_FFFF>>rule_node1[3][75:70]) & sec_temp_packet1[63:32]) ) &&
                ( (sec_temp_packet1[79:64] >= rule_node1[3][91:76]) && (sec_temp_packet1[79:64] <= rule_node1[3][107:92]) ) &&
                ( (sec_temp_packet1[95:80] >= rule_node1[3][123:108]) && (sec_temp_packet1[95:80] <= rule_node1[3][139:124]) ) &&
                ( (sec_temp_packet1[103:96] == rule_node1[3][147:140]) || ~(rule_node1[3][148]) ) && sec_temp_node1[8];
                
            //match the fifth rule
            match_flag1[4] <= ( rule_node1[4][31:0] == (~(32'hFFFF_FFFF>>rule_node1[4][37:32]) & sec_temp_packet1[31:0]) ) &&
                ( rule_node1[4][69:38] == (~(32'hFFFF_FFFF>>rule_node1[4][75:70]) & sec_temp_packet1[63:32]) ) &&
                ( (sec_temp_packet1[79:64] >= rule_node1[4][91:76]) && (sec_temp_packet1[79:64] <= rule_node1[4][107:92]) ) &&
                ( (sec_temp_packet1[95:80] >= rule_node1[4][123:108]) && (sec_temp_packet1[95:80] <= rule_node1[4][139:124]) ) &&
                ( (sec_temp_packet1[103:96] == rule_node1[4][147:140]) || ~(rule_node1[4][148]) ) && sec_temp_node1[7];
                
            //match the sixth rule
            match_flag1[5] <= ( rule_node1[5][31:0] == (~(32'hFFFF_FFFF>>rule_node1[5][37:32]) & sec_temp_packet1[31:0]) ) &&
                ( rule_node1[5][69:38] == (~(32'hFFFF_FFFF>>rule_node1[5][75:70]) & sec_temp_packet1[63:32]) ) &&
                ( (sec_temp_packet1[79:64] >= rule_node1[5][91:76]) && (sec_temp_packet1[79:64] <= rule_node1[5][107:92]) ) &&
                ( (sec_temp_packet1[95:80] >= rule_node1[5][123:108]) && (sec_temp_packet1[95:80] <= rule_node1[5][139:124]) ) &&
                ( (sec_temp_packet1[103:96] == rule_node1[5][147:140]) || ~(rule_node1[5][148]) ) && sec_temp_node1[6];
                
            //match the seventh rule
            match_flag1[6] <= ( rule_node1[6][31:0] == (~(32'hFFFF_FFFF>>rule_node1[6][37:32]) & sec_temp_packet1[31:0]) ) &&
                ( rule_node1[6][69:38] == (~(32'hFFFF_FFFF>>rule_node1[6][75:70]) & sec_temp_packet1[63:32]) ) &&
                ( (sec_temp_packet1[79:64] >= rule_node1[6][91:76]) && (sec_temp_packet1[79:64] <= rule_node1[6][107:92]) ) &&
                ( (sec_temp_packet1[95:80] >= rule_node1[6][123:108]) && (sec_temp_packet1[95:80] <= rule_node1[6][139:124]) ) &&
                ( (sec_temp_packet1[103:96] == rule_node1[6][147:140]) || ~(rule_node1[6][148]) ) && sec_temp_node1[5];
                
            //match the eigth rule
            match_flag1[7] <= ( rule_node1[7][31:0] == (~(32'hFFFF_FFFF>>rule_node1[7][37:32]) & sec_temp_packet1[31:0]) ) &&
                ( rule_node1[7][69:38] == (~(32'hFFFF_FFFF>>rule_node1[7][75:70]) & sec_temp_packet1[63:32]) ) &&
                ( (sec_temp_packet1[79:64] >= rule_node1[7][91:76]) && (sec_temp_packet1[79:64] <= rule_node1[7][107:92]) ) &&
                ( (sec_temp_packet1[95:80] >= rule_node1[7][123:108]) && (sec_temp_packet1[95:80] <= rule_node1[7][139:124]) ) &&
                ( (sec_temp_packet1[103:96] == rule_node1[7][147:140]) || ~(rule_node1[7][148]) ) && sec_temp_node1[4]; 
        end   
     end
                   
    // handle the first packet
     always@(posedge clk or negedge RSTn) begin
        if(!RSTn)   begin
            rule_pri2 <= 112'b0;
            match_flag2 <= 8'b0;
            data_valid_out2 <= 1'b0;
        end else begin
            rule_pri2 <= {rule_node2[7][162:149], rule_node2[6][162:149], rule_node2[5][162:149], rule_node2[4][162:149],
                            rule_node2[3][162:149], rule_node2[2][162:149], rule_node2[1][162:149], rule_node2[0][162:149]}; 
            temp_packet2 <= packet_in2;
            sec_temp_packet2 <= temp_packet2;
            temp_valid2 <= data_valid_in2;
            sec_temp_valid2 <= temp_valid2;
            data_valid_out2 <= sec_temp_valid2;
            
            temp_node2 <= node_in2;
            sec_temp_node2 <= temp_node2;
                        
            match_flag2[0] <= ( rule_node2[0][31:0] == (~(32'hFFFF_FFFF>>rule_node2[0][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[0][69:38] == (~(32'hFFFF_FFFF>>rule_node2[0][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[0][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[0][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[0][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[0][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[0][147:140]) || ~(rule_node2[0][148]) ) && sec_temp_node2[11];

            //match the secnod rule
            match_flag2[1] <= ( rule_node2[1][31:0] == (~(32'hFFFF_FFFF>>rule_node2[1][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[1][69:38] == (~(32'hFFFF_FFFF>>rule_node2[1][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[1][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[1][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[1][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[1][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[1][147:140]) || ~(rule_node2[1][148]) ) && sec_temp_node2[10];
                
            //match the third rule
            match_flag2[2] <= ( rule_node2[2][31:0] == (~(32'hFFFF_FFFF>>rule_node2[2][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[2][69:38] == (~(32'hFFFF_FFFF>>rule_node2[2][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[2][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[2][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[2][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[2][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[2][147:140]) || ~(rule_node2[2][148]) ) && sec_temp_node2[9];
                
            //match the fourth rule
            match_flag2[3] <= ( rule_node2[3][31:0] == (~(32'hFFFF_FFFF>>rule_node2[3][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[3][69:38] == (~(32'hFFFF_FFFF>>rule_node2[3][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[3][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[3][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[3][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[3][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[3][147:140]) || ~(rule_node2[3][148]) ) && sec_temp_node2[8];
                
            //match the fifth rule
            match_flag2[4] <= ( rule_node2[4][31:0] == (~(32'hFFFF_FFFF>>rule_node2[4][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[4][69:38] == (~(32'hFFFF_FFFF>>rule_node2[4][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[4][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[4][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[4][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[4][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[4][147:140]) || ~(rule_node2[4][148]) ) && sec_temp_node2[7];
                
            //match the sixth rule
            match_flag2[5] <= ( rule_node2[5][31:0] == (~(32'hFFFF_FFFF>>rule_node2[5][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[5][69:38] == (~(32'hFFFF_FFFF>>rule_node2[5][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[5][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[5][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[5][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[5][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[5][147:140]) || ~(rule_node2[5][148]) ) && sec_temp_node2[6];
                
            //match the seventh rule
            match_flag2[6] <= ( rule_node2[6][31:0] == (~(32'hFFFF_FFFF>>rule_node2[6][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[6][69:38] == (~(32'hFFFF_FFFF>>rule_node2[6][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[6][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[6][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[6][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[6][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[6][147:140]) || ~(rule_node2[6][148]) ) && sec_temp_node2[5];
                
            //match the eigth rule
            match_flag2[7] <= ( rule_node2[7][31:0] == (~(32'hFFFF_FFFF>>rule_node2[7][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[7][69:38] == (~(32'hFFFF_FFFF>>rule_node2[7][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[7][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[7][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[7][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[7][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[7][147:140]) || ~(rule_node2[7][148]) ) && sec_temp_node2[4];    
        end
     end
    
    
    /*
    // handle the first packet
    assign rule_pri1 = {rule_node2[7][162:149], rule_node2[6][162:149], rule_node2[5][162:149], rule_node2[4][162:149],
                            rule_node2[3][162:149], rule_node2[2][162:149], rule_node2[1][162:149], rule_node2[0][162:149]}; 
    assign temp_flag1[0] = ( rule_node2[0][31:0] == (~(32'hFFFF_FFFF>>rule_node2[0][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[0][69:38] == (~(32'hFFFF_FFFF>>rule_node2[0][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[0][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[0][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[0][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[0][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[0][147:140]) || ~(rule_node2[0][148]) ) ? 1:0;

            //match the secnod rule
    assign temp_flag1[1] = ( rule_node2[1][31:0] == (~(32'hFFFF_FFFF>>rule_node2[1][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[1][69:38] == (~(32'hFFFF_FFFF>>rule_node2[1][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[1][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[1][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[1][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[1][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[1][147:140]) || ~(rule_node2[1][148]) ) ? 1:0;
                
            //match the third rule
    assign temp_flag1[2] = ( rule_node2[2][31:0] == (~(32'hFFFF_FFFF>>rule_node2[2][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[2][69:38] == (~(32'hFFFF_FFFF>>rule_node2[2][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[2][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[2][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[2][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[2][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[2][147:140]) || ~(rule_node2[2][148]) ) ? 1:0;
                
            //match the fourth rule
    assign temp_flag1[3] = ( rule_node2[3][31:0] == (~(32'hFFFF_FFFF>>rule_node2[3][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[3][69:38] == (~(32'hFFFF_FFFF>>rule_node2[3][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[3][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[3][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[3][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[3][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[3][147:140]) || ~(rule_node2[3][148]) ) ? 1:0;
                
            //match the fifth rule
    assign temp_flag1[4] = ( rule_node2[4][31:0] == (~(32'hFFFF_FFFF>>rule_node2[4][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[4][69:38] == (~(32'hFFFF_FFFF>>rule_node2[4][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[4][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[4][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[4][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[4][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[4][147:140]) || ~(rule_node2[4][148]) ) ? 1:0;
                
            //match the sixth rule
    assign temp_flag1[5] = ( rule_node2[5][31:0] == (~(32'hFFFF_FFFF>>rule_node2[5][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[5][69:38] == (~(32'hFFFF_FFFF>>rule_node2[5][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[5][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[5][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[5][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[5][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[5][147:140]) || ~(rule_node2[5][148]) ) ? 1:0;
                
            //match the seventh rule
    assign temp_flag1[6] = ( rule_node2[6][31:0] == (~(32'hFFFF_FFFF>>rule_node2[6][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[6][69:38] == (~(32'hFFFF_FFFF>>rule_node2[6][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[6][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[6][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[6][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[6][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[6][147:140]) || ~(rule_node2[6][148]) ) ? 1:0;
                
            //match the eigth rule
    assign temp_flag1[7] = ( rule_node2[7][31:0] == (~(32'hFFFF_FFFF>>rule_node2[7][37:32]) & sec_temp_packet2[31:0]) ) &&
                ( rule_node2[7][69:38] == (~(32'hFFFF_FFFF>>rule_node2[7][75:70]) & sec_temp_packet2[63:32]) ) &&
                ( (sec_temp_packet2[79:64] >= rule_node2[7][91:76]) && (sec_temp_packet2[79:64] <= rule_node2[7][107:92]) ) &&
                ( (sec_temp_packet2[95:80] >= rule_node2[7][123:108]) && (sec_temp_packet2[95:80] <= rule_node2[7][139:124]) ) &&
                ( (sec_temp_packet2[103:96] == rule_node2[7][147:140]) || ~(rule_node2[7][148]) ) ? 1:0;                                                                  

    assign match_flag1 = temp_flag1 & {node_in1[4], node_in1[5], node_in1[6], node_in1[7],node_in1[8], node_in1[9], node_in1[10], node_in1[11]}; 
    */
    
    /*
    // handle the second packet
    assign rule_pri2 = {rule_node2[7][162:149], rule_node2[6][162:149], rule_node2[5][162:149], rule_node2[4][162:149],
                            rule_node2[3][162:149], rule_node2[2][162:149], rule_node2[1][162:149], rule_node2[0][162:149]};
                                        
    assign temp_flag2[0] = ( rule_node2[0][31:0] == (~(32'hFFFF_FFFF>>rule_node2[0][37:32]) & packet_in2[31:0]) ) &&
                ( rule_node2[0][69:38] == (~(32'hFFFF_FFFF>>rule_node2[0][75:70]) & packet_in2[63:32]) ) &&
                ( (packet_in2[79:64] >= rule_node2[0][91:76]) && (packet_in2[79:64] <= rule_node2[0][107:92]) ) &&
                ( (packet_in2[95:80] >= rule_node2[0][123:108]) && (packet_in2[95:80] <= rule_node2[0][139:124]) ) &&
                ( (packet_in2[103:96] == rule_node2[0][147:140]) || ~(rule_node2[0][148]) ) ? 1:0;
               

            //match the secnod rule
    assign temp_flag2[1] = ( rule_node2[1][31:0] == (~(32'hFFFF_FFFF>>rule_node2[1][37:32]) & packet_in2[31:0]) ) &&
                ( rule_node2[1][69:38] == (~(32'hFFFF_FFFF>>rule_node2[1][75:70]) & packet_in2[63:32]) ) &&
                ( (packet_in2[79:64] >= rule_node2[1][91:76]) && (packet_in2[79:64] <= rule_node2[1][107:92]) ) &&
                ( (packet_in2[95:80] >= rule_node2[1][123:108]) && (packet_in2[95:80] <= rule_node2[1][139:124]) ) &&
                ( (packet_in2[103:96] == rule_node2[1][147:140]) || ~(rule_node2[1][148]) ) ? 1:0;
 
            //match the third rule
    assign temp_flag2[2] = ( rule_node2[2][31:0] == (~(32'hFFFF_FFFF>>rule_node2[2][37:32]) & packet_in2[31:0]) ) &&
                ( rule_node2[2][69:38] == (~(32'hFFFF_FFFF>>rule_node2[2][75:70]) & packet_in2[63:32]) ) &&
                ( (packet_in2[79:64] >= rule_node2[2][91:76]) && (packet_in2[79:64] <= rule_node2[2][107:92]) ) &&
                ( (packet_in2[95:80] >= rule_node2[2][123:108]) && (packet_in2[95:80] <= rule_node2[2][139:124]) ) &&
                ( (packet_in2[103:96] == rule_node2[2][147:140]) || ~(rule_node2[2][148]) ) ? 1:0;

            //match the fourth rule
    assign temp_flag2[3] = ( rule_node2[3][31:0] == (~(32'hFFFF_FFFF>>rule_node2[3][37:32]) & packet_in2[31:0]) ) &&
                ( rule_node2[3][69:38] == (~(32'hFFFF_FFFF>>rule_node2[3][75:70]) & packet_in2[63:32]) ) &&
                ( (packet_in2[79:64] >= rule_node2[3][91:76]) && (packet_in2[79:64] <= rule_node2[3][107:92]) ) &&
                ( (packet_in2[95:80] >= rule_node2[3][123:108]) && (packet_in2[95:80] <= rule_node2[3][139:124]) ) &&
                ( (packet_in2[103:96] == rule_node2[3][147:140]) || ~(rule_node2[3][148]) ) ? 1:0;
                          
            //match the fifth rule
    assign temp_flag2[4] = ( rule_node2[4][31:0] == (~(32'hFFFF_FFFF>>rule_node2[4][37:32]) & packet_in2[31:0]) ) &&
                ( rule_node2[4][69:38] == (~(32'hFFFF_FFFF>>rule_node2[4][75:70]) & packet_in2[63:32]) ) &&
                ( (packet_in2[79:64] >= rule_node2[4][91:76]) && (packet_in2[79:64] <= rule_node2[4][107:92]) ) &&
                ( (packet_in2[95:80] >= rule_node2[4][123:108]) && (packet_in2[95:80] <= rule_node2[4][139:124]) ) &&
                ( (packet_in2[103:96] == rule_node2[4][147:140]) || ~(rule_node2[4][148]) ) ? 1:0;
               
            //match the sixth rule
    assign temp_flag2[5] = ( rule_node2[5][31:0] == (~(32'hFFFF_FFFF>>rule_node2[5][37:32]) & packet_in2[31:0]) ) &&
                ( rule_node2[5][69:38] == (~(32'hFFFF_FFFF>>rule_node2[5][75:70]) & packet_in2[63:32]) ) &&
                ( (packet_in2[79:64] >= rule_node2[5][91:76]) && (packet_in2[79:64] <= rule_node2[5][107:92]) ) &&
                ( (packet_in2[95:80] >= rule_node2[5][123:108]) && (packet_in2[95:80] <= rule_node2[5][139:124]) ) &&
                ( (packet_in2[103:96] == rule_node2[5][147:140]) || ~(rule_node2[5][148]) ) ? 1:0;

            //match the seventh rule
    assign temp_flag2[6] = ( rule_node2[6][31:0] == (~(32'hFFFF_FFFF>>rule_node2[6][37:32]) & packet_in2[31:0]) ) &&
                ( rule_node2[6][69:38] == (~(32'hFFFF_FFFF>>rule_node2[6][75:70]) & packet_in2[63:32]) ) &&
                ( (packet_in2[79:64] >= rule_node2[6][91:76]) && (packet_in2[79:64] <= rule_node2[6][107:92]) ) &&
                ( (packet_in2[95:80] >= rule_node2[6][123:108]) && (packet_in2[95:80] <= rule_node2[6][139:124]) ) &&
                ( (packet_in2[103:96] == rule_node2[6][147:140]) || ~(rule_node2[6][148]) ) ? 1:0;
             
            //match the eigth rule
    assign temp_flag2[7] = ( rule_node2[7][31:0] == (~(32'hFFFF_FFFF>>rule_node2[7][37:32]) & packet_in2[31:0]) ) &&
                ( rule_node2[7][69:38] == (~(32'hFFFF_FFFF>>rule_node2[7][75:70]) & packet_in2[63:32]) ) &&
                ( (packet_in2[79:64] >= rule_node2[7][91:76]) && (packet_in2[79:64] <= rule_node2[7][107:92]) ) &&
                ( (packet_in2[95:80] >= rule_node2[7][123:108]) && (packet_in2[95:80] <= rule_node2[7][139:124]) ) &&
                ( (packet_in2[103:96] == rule_node2[7][147:140]) || ~(rule_node2[7][148]) ) ? 1:0;                               

        
   assign match_flag2 = temp_flag2 & {node_in2[4], node_in2[5], node_in2[6], node_in2[7],node_in2[8], node_in2[9], node_in2[10], node_in2[11]};
   */
     
endmodule
