`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/22 10:52:32
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


module MBitTree #(
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
    input wire                       pkt_valid_in1,
    input wire                       pkt_valid_in2,
    
    output wire [RULE_ID-1:0]        rule_id1,
    output wire [RULE_ID-1:0]        rule_id2,
    output wire                      action_valid1,
    output wire                      action_valid2,
    
    output wire                      pkt_valid_out1,
    output wire                      pkt_valid_out2               
    );
    
    
    //connect input and multi pipeline(the input to drive mutli pipelines, such as four pipelines) 
    wire [RULE_ID-1:0] temp_rule1 [2:0];
    wire [RULE_ID-1:0] temp_rule2 [2:0];
    wire               temp_valid_out1 [2:0];
    wire               temp_valid_out2 [2:0];
    wire               temp_act_valid_in1 [2:0];
    wire               temp_act_valid_in2 [2:0];
    

    pipeline_SA pipeline_SA_inst  (
        .clk (clk),
        .RSTn (RSTn),
        .packet_in1 (packet_in1),
        .packet_in2 (packet_in2),
        .data_valid_in1 (pkt_valid_in1),
        .data_valid_in2 (pkt_valid_in2),
    
        .rule_id1 (temp_rule1[0]),
        .rule_id2 (temp_rule2[0]),      
        .data_valid_out1 (temp_valid_out1[0]),
        .data_valid_out2 (temp_valid_out2[0]),
        .action_valid1 (temp_act_valid_in1[0]),
        .action_valid2 (temp_act_valid_in2[0])
    );
    
    pipeline_DA pipeline_DA_inst  (
        .clk (clk),
        .RSTn (RSTn),
        .packet_in1 (packet_in1),
        .packet_in2 (packet_in2),
        .data_valid_in1 (pkt_valid_in1),
        .data_valid_in2 (pkt_valid_in2),
    
        .rule_id1 (temp_rule1[1]),
        .rule_id2 (temp_rule2[1]),      
        .data_valid_out1 (temp_valid_out1[1]),
        .data_valid_out2 (temp_valid_out2[1]),
        .action_valid1 (temp_act_valid_in1[1]),
        .action_valid2 (temp_act_valid_in2[1])
    );
    
    pipeline_SADA pipeline_SADA_inst  (
        .clk (clk),
        .RSTn (RSTn),
        .packet_in1 (packet_in1),
        .packet_in2 (packet_in2),
        .data_valid_in1 (pkt_valid_in1),
        .data_valid_in2 (pkt_valid_in2),
    
        .rule_id1 (temp_rule1[2]),
        .rule_id2 (temp_rule2[2]),      
        .data_valid_out1 (temp_valid_out1[2]),
        .data_valid_out2 (temp_valid_out2[2]),
        .action_valid1 (temp_act_valid_in1[2]),
        .action_valid2 (temp_act_valid_in2[2])
    );
    
    
    
    //connect four pipelines and register
    wire [RULE_ID-1:0] temp_rule1_out [2:0];
    wire [RULE_ID-1:0] temp_rule2_out [2:0];
    wire               temp_act_valid_out1 [2:0];
    wire               temp_act_valid_out2 [2:0];
    wire               temp_pipe_out1, temp_pipe_out2;
    
    reg_multi_pipeline instance_reg_pipe (
        .clk (clk),
        .RSTn (RSTn),
        
        .rule_pipe0_in1 (temp_rule1[0]),
        .rule_pipe0_in2 (temp_rule2[0]),
        .rule_pipe1_in1 (temp_rule1[1]),
        .rule_pipe1_in2 (temp_rule2[1]),
        .rule_pipe2_in1 (temp_rule1[2]),
        .rule_pipe2_in2 (temp_rule2[2]),
        
        .valid_pipe0_in1 (temp_valid_out1[0]),
        .valid_pipe0_in2 (temp_valid_out2[0]),
        .act_valid_pipe0_in1 (temp_act_valid_in1[0]),
        .act_valid_pipe0_in2 (temp_act_valid_in2[0]),
        .act_valid_pipe1_in1 (temp_act_valid_in1[1]),
        .act_valid_pipe1_in2 (temp_act_valid_in2[1]),
        .act_valid_pipe2_in1 (temp_act_valid_in1[2]),
        .act_valid_pipe2_in2 (temp_act_valid_in2[2]),
        /*
        .rule_pipe3_in1 (temp_rule1[3]),
        .rule_pipe3_in2 (temp_rule2[3]),    
        */
        .rule_pipe0_out1 (temp_rule1_out[0]),
        .rule_pipe0_out2 (temp_rule2_out[0]),
        .rule_pipe1_out1 (temp_rule1_out[1]),
        .rule_pipe1_out2 (temp_rule2_out[1]),
        .rule_pipe2_out1 (temp_rule1_out[2]),
        .rule_pipe2_out2 (temp_rule2_out[2]),
        
        .valid_pipe0_out1 (temp_pipe_out1),
        .valid_pipe0_out2 (temp_pipe_out2),
        .act_valid_pipe0_out1 (temp_act_valid_out1[0]),
        .act_valid_pipe0_out2 (temp_act_valid_out2[0]),
        .act_valid_pipe1_out1 (temp_act_valid_out1[1]),
        .act_valid_pipe1_out2 (temp_act_valid_out2[1]),
        .act_valid_pipe2_out1 (temp_act_valid_out1[2]),
        .act_valid_pipe2_out2 (temp_act_valid_out2[2])
         /*
        .rule_pipe3_out1 (temp_rule1_out[3]),
        .rule_pipe3_out2 (temp_rule2_out[3])
        */
    );
    
    //connect regsiter and final_prio
   final_prio_solver inst_final_prio(
        .clk (clk),
        .RSTn (RSTn),
        //inut from the last register 
        .rule_pipe0_in1 (temp_rule1_out[0]),
        .rule_pipe0_in2 (temp_rule2_out[0]),
        .rule_pipe1_in1 (temp_rule1_out[1]),
        .rule_pipe1_in2 (temp_rule2_out[1]),       
        .rule_pipe2_in1 (temp_rule1_out[2]),
        .rule_pipe2_in2 (temp_rule2_out[2]),
        
        .valid_pipe0_in1 (temp_pipe_out1),
        .valid_pipe0_in2 (temp_pipe_out2),
        .act_valid_pipe0_in1 (temp_act_valid_out1[0]),
        .act_valid_pipe0_in2 (temp_act_valid_out2[0]),
        .act_valid_pipe1_in1 (temp_act_valid_out1[1]),
        .act_valid_pipe1_in2 (temp_act_valid_out2[1]),
        .act_valid_pipe2_in1 (temp_act_valid_out1[2]),
        .act_valid_pipe2_in2 (temp_act_valid_out2[2]),
        /*
        .rule_pipe3_in1 (temp_rule1_out[3]),
        .rule_pipe3_in2 (temp_rule2_out[3]),    
        */
        //outut the matched rules with the hihgest pirority
        .rule_id1 (rule_id1),
        .rule_id2 (rule_id2),
        
        .data_valid_out1 (pkt_valid_out1),
        .data_valid_out2 (pkt_valid_out2),
        .action_valid_out1 (action_valid1),
        .action_valid_out2 (action_valid2)
    );

endmodule
