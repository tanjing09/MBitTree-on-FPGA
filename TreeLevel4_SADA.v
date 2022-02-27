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


module TreeLevel4_SADA #(
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
    input wire [NODE_WIDTH-1:0]      node_in1,
    input wire                       matched_in1,
    input wire [PACKET_WIDTH-1:0]    packet_in2,
    input wire                       data_valid_in2,
    input wire [NODE_WIDTH-1:0]      node_in2,
    input wire                       matched_in2,
        
    //output to the second
    output reg [PACKET_WIDTH-1:0]     packet_out1,
    output reg [NODE_WIDTH-1:0]       node_out1,
    output reg                        data_valid_out1,
    
    output reg [PACKET_WIDTH-1:0]     packet_out2,
    output reg                        data_valid_out2,
    output reg [NODE_WIDTH-1:0]       node_out2
    
    );
    
    //temp value to store index of childnode array
    wire [2:0] temp_Ebits1, temp_Ebits2;
    wire [2:0] Ebits1, Ebits2;
    
    //input and output of dram
    wire [5:0]   addr1, addr2;
    wire [NODE_WIDTH-1:0] dout1, dout2;

       
    //存储该流水线级别的树节点，叶节点和内部节点位宽一致
    bram_40_64_sada_level5 bram_level5_sada(
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
      
    // handle the first packet
    assign temp_Ebits1[0] = packet_in1[node_in1[FIRST_BIT -: BIT_WIDTH]];
    assign temp_Ebits1[1] = packet_in1[node_in1[SECOND_BIT -: BIT_WIDTH]];
    assign temp_Ebits1[2] = packet_in1[node_in1[THIRD_BIT -: BIT_WIDTH]];
    assign Ebits1 = temp_Ebits1 & node_in1[6:4];
    assign addr1 = node_in1[(NODE_WIDTH-1) -: NODE_ADDR] + Ebits1;
             
    
    //handle the second packet
    assign temp_Ebits2[0] = packet_in2[node_in2[FIRST_BIT -: BIT_WIDTH]];
    assign temp_Ebits2[1] = packet_in2[node_in2[SECOND_BIT -: BIT_WIDTH]];
    assign temp_Ebits2[2] = packet_in2[node_in2[THIRD_BIT -: BIT_WIDTH]];
    assign Ebits2 = temp_Ebits2 & node_in2[6:4];
    assign addr2 = node_in2[(NODE_WIDTH-1) -: NODE_ADDR] + Ebits2;

    // tranmist these data after two cycles due to two cycle letency in BRAM
    reg [PACKET_WIDTH-1:0] temp_packet1, temp_packet2, sec_temp_packet1, sec_temp_packet2;
    reg  temp_valid1, temp_valid2, sec_temp_valid1, sec_temp_valid2;
    reg [NODE_WIDTH-1:0] temp_node1, temp_node2, sec_temp_node1, sec_temp_node2;
    reg  temp_matched1, sec_temp_matched1, temp_matched2, sec_temp_matched2;
    
    always@(posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            packet_out1 <= 104'b0;
            data_valid_out1 <= 1'b0;
            node_out1 <= 40'b0;
        end else begin
            // transmit packet and valid
            temp_packet1 <= packet_in1;
            sec_temp_packet1 <= temp_packet1;
            packet_out1 <= sec_temp_packet1;           
            temp_valid1 <= data_valid_in1;
            sec_temp_valid1 <= temp_valid1;
            data_valid_out1 <= sec_temp_valid1; 
            //transmit node info                    
            temp_node1 <= node_in1;
            sec_temp_node1 <= temp_node1;
            temp_matched1 <= matched_in1;
            sec_temp_matched1 <= temp_matched1; 
                            
            if(sec_temp_matched1 == 1'b1) begin
                node_out1 <= sec_temp_node1;
            end else begin
                node_out1 <= dout1;
            end
        end
    end
    
    always@(posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            packet_out2 <= 104'b0;
            data_valid_out2 <= 1'b0;
            node_out2 <= 40'b0;
        end else begin
            // transmit packet and valid
            temp_packet2 <= packet_in2;
            sec_temp_packet2 <= temp_packet2;
            packet_out2 <= sec_temp_packet2;           
            temp_valid2 <= data_valid_in2;
            sec_temp_valid2 <= temp_valid2;
            data_valid_out2 <= sec_temp_valid2; 
            //transmit node info                    
            temp_node2 <= node_in2;
            sec_temp_node2 <= temp_node2;
            temp_matched2 <= matched_in2;
            sec_temp_matched2 <= temp_matched2;              
                            
            if(sec_temp_matched2 == 1'b1) begin
                node_out2 <= sec_temp_node2;
            end else begin
                node_out2 <= dout2;
            end
        end
    end       
                
endmodule
