`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/27 08:27:49
// Design Name: 
// Module Name: level2_lelvel3
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

module Reg_level2_level3 #(
    // the width of packet header and node
    parameter   PACKET_WIDTH = 104,
    parameter   NODE_WIDTH = 40
)

(
    //reset and clock
    input   clk,
    input   RSTn,
    
    //input from last stage 
    input wire [PACKET_WIDTH-1:0]    packet_in1,
    input wire                       data_valid_in1,
    input wire [NODE_WIDTH-1:0]      node_in1,
    input wire                       matched_in1,
    
    input wire [PACKET_WIDTH-1:0]    packet_in2,
    input wire                       data_valid_in2,
    input wire [NODE_WIDTH-1:0]      node_in2,
    input wire                       matched_in2, 
    
    //output to the node in level2 of tree 
    output reg [PACKET_WIDTH-1:0]    packet_out1,
    output reg                      data_valid_out1,
    output reg [NODE_WIDTH-1:0]      node_out1,
    output reg                       matched_out1,
    
    output reg [PACKET_WIDTH-1:0]    packet_out2,
    output reg                       data_valid_out2,
    output reg [NODE_WIDTH-1:0]      node_out2,
    output reg                       matched_out2
    
    );
    
    // handle the first packet
    always@(posedge clk or negedge RSTn)    begin
        if(!RSTn)   begin
            packet_out1 <= 104'b0;
            data_valid_out1 <= 1'b0;
            node_out1 <= 40'b0;
            matched_out1 <= 1'b0;            
        end else begin
            packet_out1 <= packet_in1;
            data_valid_out1 <= data_valid_in1;
            node_out1 <= node_in1;
            matched_out1 <= matched_in1;           
        end
    end
     
    // handle the second packet
    always@(posedge clk or negedge RSTn)    begin
        if(!RSTn)   begin
            packet_out2 <= 104'b0;
            data_valid_out2 <= 1'b0;
            node_out2 <= 40'b0;
            matched_out2 <= 1'b0;            
        end else begin
            packet_out2 <= packet_in2;
            data_valid_out2 <= data_valid_in2;
            node_out2 <= node_in2;
            matched_out2 <= matched_in2;           
        end
    end

        
 endmodule
