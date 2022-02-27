`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/24 21:57:14
// Design Name: 
// Module Name: final_prio_solver
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


module final_prio_solver #(
    // the width of packet header and node
    parameter   PACKET_WIDTH = 104,
    parameter   NODE_WIDTH = 40,
    // data structure of leafnode
    parameter   RULE_ID = 14
)

(    
    input clk, 
    input RSTn,
    //inut from the last register 
    input wire [RULE_ID-1:0] rule_pipe0_in1,
    input wire [RULE_ID-1:0] rule_pipe0_in2,
    input wire [RULE_ID-1:0] rule_pipe1_in1,
    input wire [RULE_ID-1:0] rule_pipe1_in2,
    input wire [RULE_ID-1:0] rule_pipe2_in1,
    input wire [RULE_ID-1:0] rule_pipe2_in2,
    input wire               valid_pipe0_in1,
    input wire               valid_pipe0_in2,
    input wire               act_valid_pipe0_in1,
    input wire               act_valid_pipe0_in2,
    input wire               act_valid_pipe1_in1,
    input wire               act_valid_pipe1_in2,
    input wire               act_valid_pipe2_in1,
    input wire               act_valid_pipe2_in2,
    /*
    input wire [RULE_ID-1:0] rule_pipe3_in1,
    input wire [RULE_ID-1:0] rule_pipe3_in2,    
    */
    //outut the matched rules with the hihgest pirority
    output reg [RULE_ID-1:0] rule_id1,
    output reg [RULE_ID-1:0] rule_id2,
    output reg               data_valid_out1,
    output reg               data_valid_out2,
    output reg               action_valid_out1,
    output reg               action_valid_out2
    
    );
    
    wire [3:0] big_id1, big_id2;
    
    assign big_id1[0] =  ( (rule_pipe0_in1 > rule_pipe1_in1) && (rule_pipe0_in1 > rule_pipe2_in1) ) ? 1:0;  
    assign big_id1[1] =  ( (rule_pipe1_in1 > rule_pipe0_in1) && (rule_pipe1_in1 > rule_pipe2_in1) ) ? 1:0;
    assign big_id1[2] =  ( (rule_pipe2_in1 > rule_pipe0_in1) && (rule_pipe2_in1 > rule_pipe1_in1) ) ? 1:0;
      
    assign big_id2[0] =  ( (rule_pipe0_in2 > rule_pipe1_in2) && (rule_pipe0_in2 > rule_pipe2_in2) ) ? 1:0;  
    assign big_id2[1] =  ( (rule_pipe1_in2 > rule_pipe0_in2) && (rule_pipe1_in2 > rule_pipe2_in2) ) ? 1:0;
    assign big_id2[2] =  ( (rule_pipe2_in2 > rule_pipe0_in2) && (rule_pipe2_in2 > rule_pipe1_in2) ) ? 1:0;   
    
    /* if there are four pipelines or three pipelines
    assign big_id1[0] = ( (rule_pipe0_in1 > rule_pipe1_in1) && (rule_pipe0_in1 > rule_pipe2_in1) 
                        && (rule_pipe0_in1 > rule_pipe3_in1) ) ? 1:0;                               
    assign big_id1[1] = ( (rule_pipe1_in1 > rule_pipe0_in1) && (rule_pipe1_in1 > rule_pipe2_in1) 
                        && (rule_pipe1_in1 >= rule_pipe3_in1) ) ? 1:0;                              
    assign big_id1[2] = ( (rule_pipe2_in1 > rule_pipe0_in1) && (rule_pipe2_in1 > rule_pipe1_in1) 
                        && (rule_pipe2_in1 > rule_pipe3_in1) ) ? 1:0;   
    assign big_id1[3] = ( (rule_pipe3_in1 > rule_pipe0_in1) && (rule_pipe3_in1 > rule_pipe1_in1) 
                        && (rule_pipe3_in1 > rule_pipe2_in1) ) ? 1:0;    
    */
    reg [RULE_ID-1:0] temp_id1, temp_id2;
    reg  temp_act_valid1, temp_act_valid2; 
    
    always@ (*) begin
        temp_act_valid1 =  act_valid_pipe0_in1 || act_valid_pipe1_in1 || act_valid_pipe2_in1;
        temp_act_valid2 =  act_valid_pipe0_in2 || act_valid_pipe1_in2 || act_valid_pipe2_in2;
    end
    
    always@(*)    begin                    
        case(big_id1)
            3'b100: temp_id1 <= rule_pipe2_in1;
            3'b010: temp_id1 <= rule_pipe1_in1;
            3'b001: temp_id1 <= rule_pipe0_in1;
            /*
            4'b0010: rule_id1 <= rule_pipe2_in1;
            4'b0001: rule_id1 <= rule_pipe3_in1; 
            */  
            default: temp_id1 <= 14'b0;                           
        endcase       
    end
    
    always@(*)    begin
        case(big_id2)
            3'b100: temp_id2 <= rule_pipe2_in2;
            3'b010: temp_id2 <= rule_pipe1_in2;
            3'b001: temp_id2 <= rule_pipe0_in2;
            /*
            4'b0010: rule_id2 <= rule_pipe2_in2;
            4'b0001: rule_id2 <= rule_pipe3_in2; 
            */   
            default: temp_id2 <= 14'b0;                   
        endcase         
    end
    
    always@(posedge clk or negedge RSTn)    begin
        if(!RSTn)   begin
            rule_id1 <= 14'b0;
            rule_id2 <= 14'b0;
            data_valid_out1 <= 1'b0;
            data_valid_out2 <= 1'b0;
            action_valid_out1 <= 1'b0;
            action_valid_out2 <= 1'b0;
        end else begin
            rule_id1 <= temp_id1;
            rule_id2 <= temp_id2;
            data_valid_out1 <= valid_pipe0_in1;
            data_valid_out2 <= valid_pipe0_in2;
            action_valid_out1 <= temp_act_valid1;
            action_valid_out2 <= temp_act_valid2;
        end               
    end    
    
endmodule
