`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/20 16:16:36
// Design Name: 
// Module Name: root
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


module root_DA #(
    // the width of packet header and node
    parameter   PACKET_WIDTH = 104,
    parameter   NODE_WIDTH = 40,
    // data structure of the internal node
    parameter   FIRST_BIT = 14,
    parameter   SECOND_BIT = 22,
    parameter   THIRD_BIT = 30,
    parameter   BIT_WIDTH = 8,
    parameter   NODE_ADDR = 9,
    // data structure of leafnode
    parameter   LEAF_ADDR = 12,
    parameter   RULE_ID = 14
)

(
    //reset and clock
    input   clk,
    input   RSTn,
    
    //input packet, dual port
    input wire [PACKET_WIDTH-1:0]    packet_in1,
    input wire                       data_valid_in1,    
    input wire [PACKET_WIDTH-1:0]    packet_in2,
    input wire                       data_valid_in2,
    
    //output to the next stage 
    output reg [PACKET_WIDTH-1:0]    packet_out1,
    output reg                       data_valid_out1,
    output reg [NODE_WIDTH-1:0]      node_out1,
    output reg                       matched_out1,
    
    output reg [PACKET_WIDTH-1:0]    packet_out2,
    output reg                       data_valid_out2,
    output reg [NODE_WIDTH-1:0]      node_out2,
    output reg                       matched_out2
    
    );
        
    /*  Nonleaf-node data structure
    reg [0:0]  nodetype;             // 1 bits, which '0' means internal node, and '1' means leafnode
    reg [3:1]  level;               // 3 bits, the level of the tree node lie
    reg [6:4]  mask;                // 3 bits, decide which bits is effective, 000 means internode
    reg [30:7]  Pos_Ebits;          // 24 bits, 8 bits for one ebits, 14-7th, 22-15th, 30-23th
    reg [39:31] baseAddr;       `  // 9 bits, the addresss of the first child node
    or reg[42:31] baseAddr;        // 12 bits, for 100K rulesets
    */
    
    /*  Leaf-node data structure
    reg [0:0]  nodetype;                // 1 bits, which '0' means internal node, and '1' means leafnode
    reg [3:1]  level;                   // 4 bits, the level of the tree node lie
    reg [11:4] NumRules                  // 8 bits, number of rules in leaf node, which use the one hot code
    reg [23:12] baseAddr;       `       // 12 bits for leafnode pointer, can indicate 4096 leafnodes
    or reg [26:12]                      // 15 bits, for 100k rulesets
    */
    
    //store the root node
    reg [NODE_WIDTH-1:0] root_node = 40'b000000000_00011111_00001101_00000010_111_000_0;
    
    //temp value to store index of childnode array
    wire [2:0] temp_Ebits1, temp_Ebits2;
    wire [2:0] Ebits1, Ebits2;
    
    //input and output of dram
    wire [3:0]   addr1, addr2;
    wire [NODE_WIDTH-1:0] dout1, dout2;
    
    // extract the index from header and computer the address of childnode
    // handle the first packet
    assign temp_Ebits1[0] = packet_in1[root_node[FIRST_BIT -: BIT_WIDTH]];
    assign temp_Ebits1[1] = packet_in1[root_node[SECOND_BIT -: BIT_WIDTH]];
    assign temp_Ebits1[2] = packet_in1[root_node[THIRD_BIT -: BIT_WIDTH]];
    assign Ebits1 = temp_Ebits1 & root_node[6:4];
    assign addr1 = root_node[(NODE_WIDTH-1) -: NODE_ADDR] + Ebits1; 
    
    //handle the second packet
    assign temp_Ebits2[0] = packet_in2[root_node[FIRST_BIT -: BIT_WIDTH]];
    assign temp_Ebits2[1] = packet_in2[root_node[SECOND_BIT -: BIT_WIDTH]];
    assign temp_Ebits2[2] = packet_in2[root_node[THIRD_BIT -: BIT_WIDTH]];
    assign Ebits2 = temp_Ebits2 & root_node[6:4];
    assign addr2 = root_node[(NODE_WIDTH-1) -: NODE_ADDR] + Ebits2; 

    
    // store the node in level-2 of tree use bram
    bram_40_8_da_level2 bram_level2_da(
        .clka (clk),
        .wea (1'b0),
        .addra (addr1),
        .dina (40'b0),
        .douta (dout1),
        .clkb (clk),
        .web (1'b0),
        .addrb (addr2),
        .dinb (40'b0),
        .doutb (dout2)
    );
    
    // tranmist these data after two cycles   
    reg [PACKET_WIDTH-1:0] temp_packet1, temp_packet2, sec_temp_packet1, sec_temp_packet2, t_temp_packet1, t_temp_packet2;
    reg  temp_valid1, temp_valid2, sec_temp_valid1, sec_temp_valid2, t_temp_valid1, t_temp_valid2;
    
    always@(posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            packet_out1 <= 104'b0;
            data_valid_out1 <= 1'b0;
            node_out1 <= 40'b0;
            matched_out1 <= 1'b0;
        end else begin
            // transmit packet and valid
            temp_packet1 <= packet_in1;
            sec_temp_packet1 <= temp_packet1;
            t_temp_packet1 <= sec_temp_packet1;
            packet_out1 <= t_temp_packet1;
                       
            temp_valid1 <= data_valid_in1;
            sec_temp_valid1 <= temp_valid1;
            t_temp_valid1 <= sec_temp_valid1;
            data_valid_out1 <= t_temp_valid1; 
            //transmit node info                    
            node_out1 <= dout1;
            matched_out1 <= dout1[0];
        end
    end
    
    always@(posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            packet_out2 <= 104'b0;
            data_valid_out2 <= 1'b0;
            node_out2 <= 40'b0;
            matched_out2 <= 1'b0;
        end else begin
            // transmit packet and valid
            temp_packet2 <= packet_in2;
            sec_temp_packet2 <= temp_packet2;
            t_temp_packet2 <= sec_temp_packet2;
            packet_out2 <= t_temp_packet2;          
                      
            temp_valid2 <= data_valid_in2;
            sec_temp_valid2 <= temp_valid2;
            t_temp_valid2 <= sec_temp_valid2;
            data_valid_out2 <= t_temp_valid2; 
            
            node_out2 <= dout2;
            matched_out2 <= dout2[0];
        end
    end    
    
    
    /*   store the node in level-2 of tree use dram
    dram_40_16_da_level2 dram_level2_da(
        .clk (clk),
        .we (1'b0),
        .a (addr1),
        .d (40'b0),
        .spo (dout1),
        .dpra (addr2),
        .dpo (dout2)
    );
    */            
    
 endmodule