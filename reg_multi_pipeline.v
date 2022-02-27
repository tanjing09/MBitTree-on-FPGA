`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/24 21:36:51
// Design Name: 
// Module Name: reg_multi-pipeline
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


module reg_multi_pipeline  #(
    // the width of packet header and node
    parameter   PACKET_WIDTH = 104,
    parameter   NODE_WIDTH = 40,
    // data structure of leafnode
    parameter   RULE_ID = 14
)

(
    input clk,
    input RSTn,
    
    //three pipelines, dual port
    input wire [RULE_ID-1:0] rule_pipe0_in1,
    input wire [RULE_ID-1:0] rule_pipe0_in2,
    input wire               valid_pipe0_in1,
    input wire               valid_pipe0_in2,
    input wire               act_valid_pipe0_in1,
    input wire               act_valid_pipe0_in2,
    
    input wire [RULE_ID-1:0] rule_pipe1_in1,
    input wire [RULE_ID-1:0] rule_pipe1_in2,
    input wire               act_valid_pipe1_in1,
    input wire               act_valid_pipe1_in2,
    
    input wire [RULE_ID-1:0] rule_pipe2_in1,
    input wire [RULE_ID-1:0] rule_pipe2_in2,
    input wire               act_valid_pipe2_in1,
    input wire               act_valid_pipe2_in2,
    /*
    input wire [RULE_ID-1:0] rule_pipe3_in1,
    input wire [RULE_ID-1:0] rule_pipe3_in2,    
    */
    //get the highest rule
    output reg [RULE_ID-1:0] rule_pipe0_out1,
    output reg [RULE_ID-1:0] rule_pipe0_out2,
    output reg [RULE_ID-1:0] rule_pipe1_out1,
    output reg [RULE_ID-1:0] rule_pipe1_out2,
    output reg [RULE_ID-1:0] rule_pipe2_out1,
    output reg [RULE_ID-1:0] rule_pipe2_out2,
    output reg               valid_pipe0_out1,
    output reg               valid_pipe0_out2,
    output reg               act_valid_pipe0_out1,
    output reg               act_valid_pipe0_out2,
    output reg               act_valid_pipe1_out1,
    output reg               act_valid_pipe1_out2,
    output reg               act_valid_pipe2_out1,
    output reg               act_valid_pipe2_out2       
    /*
    output reg [RULE_ID-1:0] rule_pipe3_out1,
    output reg [RULE_ID-1:0] rule_pipe3_out2
    */
    );
    
    always@(posedge clk or negedge RSTn)    begin
        if(!RSTn)   begin
            rule_pipe0_out1 <= 14'b0;
            rule_pipe0_out2 <= 14'b0;
            rule_pipe1_out1 <= 14'b0;
            rule_pipe1_out2 <= 14'b0;      
            rule_pipe2_out1 <= 14'b0;
            rule_pipe2_out2 <= 14'b0;
            valid_pipe0_out1 <= 1'b0;
            valid_pipe0_out2 <= 1'b0;
            act_valid_pipe0_out1 <= 1'b0;
            act_valid_pipe0_out2 <= 1'b0;
            act_valid_pipe1_out1 <= 1'b0;
            act_valid_pipe1_out2 <= 1'b0;
            act_valid_pipe2_out1 <= 1'b0;
            act_valid_pipe2_out2 <= 1'b0;
            /*
            rule_pipe3_out1 <= 14'b0;
            rule_pipe3_out2 <= 14'b0;
            */
        end else begin
            rule_pipe0_out1 <= rule_pipe0_in1;
            rule_pipe0_out2 <= rule_pipe0_in2;
            rule_pipe1_out1 <= rule_pipe1_in1;
            rule_pipe1_out2 <= rule_pipe1_in2;           
            rule_pipe2_out1 <= rule_pipe2_in1;
            rule_pipe2_out2 <= rule_pipe2_in2;
            valid_pipe0_out1 <= valid_pipe0_in1;
            valid_pipe0_out2 <= valid_pipe0_in2;
            act_valid_pipe0_out1 <= act_valid_pipe0_in1;
            act_valid_pipe0_out2 <= act_valid_pipe0_in2;
            act_valid_pipe1_out1 <= act_valid_pipe1_in1;
            act_valid_pipe1_out2 <= act_valid_pipe1_in2;
            act_valid_pipe2_out1 <= act_valid_pipe2_in1;
            act_valid_pipe2_out2 <= act_valid_pipe2_in2;
            /*
            rule_pipe3_out1 <= rule_pipe3_in1;
            rule_pipe3_out2 <= rule_pipe3_in2;
            */
        end
    end
    
endmodule
