`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/27 10:17:28
// Design Name: 
// Module Name: matching_priority
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


module Reg_match_priority #(
    // the width of packet header and node
    parameter   PACKET_WIDTH = 104,
    parameter   NODE_WIDTH = 40, 
    // data structure of leafnode
    parameter   RULE_ID = 14,
    // the width of a rule in ruleset, sip/prefix, dip/prefix, sport_low, sport_high, dport_low, dport_high, proto/prefix, priority, action
    parameter   RULE_WIDTH = 171
)
(
    input clk,
    input RSTn,
        
    input wire      [8*RULE_ID-1:0] rule_pri_in1,
    input wire      [8-1:0]         match_flag_in1,
    input wire                      data_valid_in1,
    input wire      [8*RULE_ID-1:0] rule_pri_in2,
    input wire      [8-1:0]         match_flag_in2,
    input wire                      data_valid_in2,
    
    output reg      [8*RULE_ID-1:0] rule_pri_out1,
    output reg      [8-1:0]         match_flag_out1,
    output reg                      data_valid_out1,
    output reg      [8*RULE_ID-1:0] rule_pri_out2,
    output reg      [8-1:0]         match_flag_out2,
    output reg                      data_valid_out2
    );
    
    always@(posedge clk or negedge RSTn)    begin
        if(!RSTn)   begin
            rule_pri_out1 <= 112'b0;
            match_flag_out1 <= 8'b0;
            data_valid_out1 <= 1'b0;
            rule_pri_out2 <= 112'b0;
            match_flag_out2 <= 8'b0;
            data_valid_out2 <= 1'b0;
        end else begin
            rule_pri_out1 <= rule_pri_in1;
            match_flag_out1 <= match_flag_in1;
            data_valid_out1 <= data_valid_in1;
            rule_pri_out2 <= rule_pri_in2;
            match_flag_out2 <= match_flag_in2;
            data_valid_out2 <= data_valid_in2;
        end
    end
    
endmodule
