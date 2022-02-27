`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/20 16:10:30
// Design Name: 
// Module Name: MBitTree
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


module pipeline_DA #(
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
    input clk,
    input RSTn,
    
    //dual port
    input wire [PACKET_WIDTH-1:0]    packet_in1,
    input wire [PACKET_WIDTH-1:0]    packet_in2,
    input wire                       data_valid_in1,
    input wire                       data_valid_in2,
    
    output wire [RULE_ID-1:0] rule_id1,
    output wire [RULE_ID-1:0] rule_id2,
    output wire               data_valid_out1,
    output wire               data_valid_out2,
    output wire               action_valid1,
    output wire               action_valid2               
    
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
    
    /*
     connetc root and level-2
    */
    //output of root
    wire [PACKET_WIDTH-1:0]    packet_root_out1;
    wire [NODE_WIDTH-1:0]      node_root_out1;
    wire                       matched_root_out1;
    wire [PACKET_WIDTH-1:0]    packet_root_out2;
    wire [NODE_WIDTH-1:0]      node_root_out2;
    wire                       matched_root_out2;
    wire                       valid_root_out1;
    wire                       valid_root_out2;
    
    root_DA root_inst(
        //reset and clock
        .clk (clk),
        .RSTn (RSTn),   
        //input packet, dual port
        .packet_in1 (packet_in1),
        .packet_in2 (packet_in2),   
        //output to the next stage 
        .packet_out1 (packet_root_out1),
        .node_out1 (node_root_out1),
        .matched_out1 (matched_root_out1),
        .packet_out2 (packet_root_out2),
        .node_out2 (node_root_out2),
        .matched_out2 (matched_root_out2),
        
        .data_valid_in1 (data_valid_in1),
        .data_valid_in2 (data_valid_in2),
        .data_valid_out1 (valid_root_out1),
        .data_valid_out2 (valid_root_out2)
    );
    
    //input and output of level-2
    wire [PACKET_WIDTH-1:0]    packet_level2_in1;
    wire [NODE_WIDTH-1:0]      node_level2_in1;
    wire                       matched_level2_in1;
    wire [PACKET_WIDTH-1:0]    packet_level2_in2;
    wire [NODE_WIDTH-1:0]      node_level2_in2;
    wire                       matched_level2_in2;
    wire                       valid_level2_in1;
    wire                       valid_level2_in2;
           
    wire [PACKET_WIDTH-1:0]    packet_level2_out1;
    wire [NODE_WIDTH-1:0]      node_level2_out1;
    wire                       matched_level2_out1;
    wire [PACKET_WIDTH-1:0]    packet_level2_out2;
    wire [NODE_WIDTH-1:0]      node_level2_out2;
    wire                       matched_level2_out2;
    wire                       valid_level2_out1;
    wire                       valid_level2_out2;
    
    
    Register_root_level2 Reg_root_level2_inst(
        //reset and clock
        .clk (clk),
        .RSTn (RSTn),
        //input from last stage 
        .packet_in1 (packet_root_out1),
        .node_in1 (node_root_out1),
        .matched_in1 (matched_root_out1),
        .packet_in2 (packet_root_out2),
        .node_in2 (node_root_out2),
        .matched_in2 (matched_root_out2), 
        //output to the node in level2 of tree 
        .packet_out1 (packet_level2_in1),
        .node_out1 (node_level2_in1),
        .matched_out1 (matched_level2_in1),        
        .packet_out2 (packet_level2_in2),
        .node_out2 (node_level2_in2),
        .matched_out2 (matched_level2_in2),
        
        .data_valid_in1 (valid_root_out1),
        .data_valid_in2 (valid_root_out2),
        .data_valid_out1 (valid_level2_in1),
        .data_valid_out2 (valid_level2_in2)
        
        );
    
    TreeLevel2_DA level2_inst(
        //reset and clock
        .clk (clk),
        .RSTn (RSTn),
        //input packet, dual port
        .packet_in1 (packet_level2_in1),
        .node_in1 (node_level2_in1),
        .matched_in1 (matched_level2_in1),
        .packet_in2 (packet_level2_in2),
        .node_in2 (node_level2_in2),
        .matched_in2 (matched_level2_in2),     
        //output to the second
        .packet_out1 (packet_level2_out1),
        .node_out1 (node_level2_out1),
        .matched_out1 (matched_level2_out1),
        .packet_out2 (packet_level2_out2),
        .node_out2 (node_level2_out2),
        .matched_out2 (matched_level2_out2),
        
        .data_valid_in1 (valid_level2_in1),
        .data_valid_in2 (valid_level2_in2),
        .data_valid_out1 (valid_level2_out1),
        .data_valid_out2 (valid_level2_out2)
        
        );
    
    /*
     connetc level-2 and level-3
    */
    //input and output of level-3
    wire [PACKET_WIDTH-1:0]    packet_level3_in1;
    wire [NODE_WIDTH-1:0]      node_level3_in1;
    wire                       matched_level3_in1;
    wire [PACKET_WIDTH-1:0]    packet_level3_in2;
    wire [NODE_WIDTH-1:0]      node_level3_in2;
    wire                       matched_level3_in2;
    wire                       valid_level3_in1;
    wire                       valid_level3_in2;
    
    wire [PACKET_WIDTH-1:0]    packet_level3_out1;
    wire [NODE_WIDTH-1:0]      node_level3_out1;
    wire                       matched_level3_out1;   
    wire [PACKET_WIDTH-1:0]    packet_level3_out2;
    wire [NODE_WIDTH-1:0]      node_level3_out2;
    wire                       matched_level3_out2;
    wire                       valid_level3_out1;
    wire                       valid_level3_out2;
       
    
    Reg_level2_level3 Reg_level2_level3_inst(
        //reset and clock
        .clk (clk),
        .RSTn (RSTn),
        //input from last stage 
        .packet_in1 (packet_level2_out1),
        .node_in1 (node_level2_out1),
        .matched_in1 (matched_level2_out1),
        .packet_in2 (packet_level2_out2),
        .node_in2 (node_level2_out2),
        .matched_in2 (matched_level2_out2), 
        //output to the node in level2 of tree 
        .packet_out1 (packet_level3_in1),
        .node_out1 (node_level3_in1),
        .matched_out1 (matched_level3_in1),        
        .packet_out2 (packet_level3_in2),
        .node_out2 (node_level3_in2),
        .matched_out2 (matched_level3_in2),
        
        .data_valid_in1 (valid_level2_out1),
        .data_valid_in2 (valid_level2_out2),
        .data_valid_out1 (valid_level3_in1),
        .data_valid_out2 (valid_level3_in2)
        
        );
    
    TreeLevel3_DA level3_inst(
        //reset and clock
        .clk (clk),
        .RSTn (RSTn),
        //input packet, dual port
        .packet_in1 (packet_level3_in1),
        .node_in1 (node_level3_in1),
        .matched_in1 (matched_level3_in1),
        .packet_in2 (packet_level3_in2),
        .node_in2 (node_level3_in2),
        .matched_in2 (matched_level3_in2),           
        //output to the second
        .packet_out1 (packet_level3_out1),
        .node_out1 (node_level3_out1),
        .matched_out1 (matched_level3_out1),
        .packet_out2 (packet_level3_out2),
        .node_out2 (node_level3_out2),
        .matched_out2 (matched_level3_out2),
        
        .data_valid_in1 (valid_level3_in1),
        .data_valid_in2 (valid_level3_in2),
        .data_valid_out1 (valid_level3_out1),
        .data_valid_out2 (valid_level3_out2)
        
        );

    /*
     connetc level-3 and level-4
    */
    //input and output of level-4
    wire [PACKET_WIDTH-1:0]    packet_level4_in1;
    wire [NODE_WIDTH-1:0]      node_level4_in1;
    wire                       matched_level4_in1;   
    wire [PACKET_WIDTH-1:0]    packet_level4_in2;
    wire [NODE_WIDTH-1:0]      node_level4_in2;
    wire                       matched_level4_in2;
    wire                       valid_level4_in1;
    wire                       valid_level4_in2;
    
    wire [PACKET_WIDTH-1:0]    packet_level4_out1;
    wire [NODE_WIDTH-1:0]      node_level4_out1;
    wire [PACKET_WIDTH-1:0]    packet_level4_out2;
    wire [NODE_WIDTH-1:0]      node_level4_out2;  
    wire                       valid_level4_out1;
    wire                       valid_level4_out2;
    
    
    Reg_level3_level4 Reg_level3_level4_inst(
        //reset and clock
        .clk (clk),
        .RSTn (RSTn),
        //input from last stage 
        .packet_in1 (packet_level3_out1),
        .node_in1 (node_level3_out1),
        .matched_in1 (matched_level3_out1),      
        .packet_in2 (packet_level3_out2),
        .node_in2 (node_level3_out2),
        .matched_in2 (matched_level3_out2), 
        //output to the node in level2 of tree 
        .packet_out1 (packet_level4_in1),
        .node_out1 (node_level4_in1),
        .matched_out1 (matched_level4_in1),       
        .packet_out2 (packet_level4_in2),
        .node_out2 (node_level4_in2),
        .matched_out2 (matched_level4_in2),
        
        .data_valid_in1 (valid_level3_out1),
        .data_valid_in2 (valid_level3_out2),
        .data_valid_out1 (valid_level4_in1),
        .data_valid_out2 (valid_level4_in2)
        
        );
    
    TreeLevel4_DA level4_DA_inst(
        //reset and clock
        .clk (clk),
        .RSTn (RSTn),
        //input packet, dual port
        .packet_in1 (packet_level4_in1),
        .node_in1 (node_level4_in1),
        .matched_in1 (matched_level4_in1),
        .packet_in2 (packet_level4_in2),
        .node_in2 (node_level4_in2),
        .matched_in2 (matched_level4_in2),   
        //output to the second
        .packet_out1 (packet_level4_out1),
        .node_out1 (node_level4_out1),
        .packet_out2 (packet_level4_out2),
        .node_out2 (node_level4_out2),
        
        .data_valid_in1 (valid_level4_in1),
        .data_valid_in2 (valid_level4_in2),
        .data_valid_out1 (valid_level4_out1),
        .data_valid_out2 (valid_level4_out2)
        
        );         
    
    /*
     connetc level-4 and ruleMatch
    */
    wire [PACKET_WIDTH-1:0]    packet_ruleMatch_in1;
    wire [NODE_WIDTH-1:0]      node_ruleMatch_in1;  
    wire [PACKET_WIDTH-1:0]    packet_ruleMatch_in2;
    wire [NODE_WIDTH-1:0]      node_ruleMatch_in2;   
    wire                       valid_ruleMatch_in1;
    wire                       valid_ruleMatch_in2;
    wire                       valid_ruleMatch_out1;
    wire                       valid_ruleMatch_out2;   
    
    
    Reg_tree_rulematch Reg_tree_ruleMatch_inst(
        //reset and clock
        .clk (clk),
        .RSTn (RSTn),       
        //input from last stage 
        .packet_in1 (packet_level4_out1),
        .node_in1 (node_level4_out1),
        .packet_in2 (packet_level4_out2),
        .node_in2 (node_level4_out2),
        //output to the node in level2 of tree 
        .packet_out1 (packet_ruleMatch_in1),
        .node_out1 (node_ruleMatch_in1),        
        .packet_out2 (packet_ruleMatch_in2),
        .node_out2 (node_ruleMatch_in2),
        
        .data_valid_in1 (valid_level4_out1),
        .data_valid_in2 (valid_level4_out2),
        .data_valid_out1 (valid_ruleMatch_in1),
        .data_valid_out2 (valid_ruleMatch_in2)
        
        );
    
    wire    [8*RULE_ID-1:0] rule_pri1;
    wire    [8-1:0]         match_flag1;
    wire    [8*RULE_ID-1:0] rule_pri2;
    wire    [8-1:0]         match_flag2;
    
    ruleMatch_DA ruleMatch_DA_inst(
        //reset and clock
        .clk (clk),
        .RSTn (RSTn),
        //input packet, dual port
        .packet_in1 (packet_ruleMatch_in1),
        .node_in1 (node_ruleMatch_in1),
        .packet_in2 (packet_ruleMatch_in2),
        .node_in2 (node_ruleMatch_in2),           
        //output to the second
        .rule_pri1 (rule_pri1),
        .match_flag1 (match_flag1),       
        .rule_pri2 (rule_pri2),
        .match_flag2 (match_flag2),
        
        .data_valid_in1 (valid_ruleMatch_in1),
        .data_valid_in2 (valid_ruleMatch_in2),
        .data_valid_out1 (valid_ruleMatch_out1),
        .data_valid_out2 (valid_ruleMatch_out2)
        
        );       
    
    /*
     connect ruleMatch and prioritySolver
    */
    wire    [8*RULE_ID-1:0] rule_pri_solver1;
    wire    [8-1:0]         match_flag_solver1;
    wire    [8*RULE_ID-1:0] rule_pri_solver2;
    wire    [8-1:0]         match_flag_solver2;
    wire                    valid_solver_in1;
    wire                    valid_solver_in2;
    
    Reg_match_priority  Reg_match_priority_inst(
        .clk (clk),
        .RSTn (RSTn),
        .rule_pri_in1 (rule_pri1),
        .match_flag_in1 (match_flag1),
        .rule_pri_in2 (rule_pri2),
        .match_flag_in2 (match_flag2),   
        .rule_pri_out1 (rule_pri_solver1),
        .match_flag_out1 (match_flag_solver1),
        .rule_pri_out2 (rule_pri_solver2),
        .match_flag_out2 (match_flag_solver2),
        
        .data_valid_in1 (valid_ruleMatch_out1),
        .data_valid_in2 (valid_ruleMatch_out2),
        .data_valid_out1 (valid_solver_in1),
        .data_valid_out2 (valid_solver_in2)
        
    );
    
    prioritySolver prioritySolver_inst(
        .clk (clk),
        .RSTn (RSTn),       
        .rule_pri1 (rule_pri_solver1),
        .match_flag1 (match_flag_solver1),
        .rule_pri2 (rule_pri_solver2),
        .match_flag2 (match_flag_solver2),
        .rule_id1 (rule_id1),
        .rule_id2 (rule_id2),
        
        .data_valid_in1 (valid_solver_in1),
        .data_valid_in2 (valid_solver_in2),
        .data_valid_out1 (data_valid_out1),
        .data_valid_out2 (data_valid_out2),
        .is_matched1 (action_valid1),
        .is_matched2 (action_valid2)
    );
    
endmodule
