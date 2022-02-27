`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 21:30:19
// Design Name: 
// Module Name: priority_solver
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


module prioritySolver #(
    parameter   RULE_ID = 14
)

(
    input clk,
    input RSTn,
    
    input wire [8*RULE_ID-1:0] rule_pri1,
    input wire [8-1:0]         match_flag1,
    input wire                 data_valid_in1,
    
    input wire [8*RULE_ID-1:0] rule_pri2,
    input wire [8-1:0]         match_flag2,
    input wire                 data_valid_in2,
    
    output reg [RULE_ID-1:0] rule_id1,
    output reg               data_valid_out1,
    output reg               is_matched1,
    
    output reg [RULE_ID-1:0] rule_id2,
    output reg               data_valid_out2,
    output reg               is_matched2
    );

    reg [RULE_ID-1:0] temp_id1, temp_id2;
    reg               temp_matched1, temp_matched2;
    
    always@(*)  begin
        casex(match_flag1)
            8'b1xxxxxxx:    temp_id1 <= rule_pri1[14*8-1 -: 14];
            8'b01xxxxxx:    temp_id1 <= rule_pri1[14*7-1 -: 14];
            8'b001xxxxx:    temp_id1 <= rule_pri1[14*6-1 -: 14];
            8'b0001xxxx:    temp_id1 <= rule_pri1[14*5-1 -: 14];
            8'b00001xxx:    temp_id1 <= rule_pri1[14*4-1 -: 14];
            8'b000001xx:    temp_id1 <= rule_pri1[14*3-1 -: 14];
            8'b0000001x:    temp_id1 <= rule_pri1[14*2-1 -: 14];
            8'b00000001:    temp_id1 <= rule_pri1[14*1-1 -: 14]; 
            default:        temp_id1 <= 14'b0;                                       
        endcase
    end
        
    always@(*)  begin
        casex(match_flag2)
            8'b1xxxxxxx:    temp_id2 <= rule_pri2[14*8-1 -: 14];
            8'b01xxxxxx:    temp_id2 <= rule_pri2[14*7-1 -: 14];
            8'b001xxxxx:    temp_id2 <= rule_pri2[14*6-1 -: 14];
            8'b0001xxxx:    temp_id2 <= rule_pri2[14*5-1 -: 14];
            8'b00001xxx:    temp_id2 <= rule_pri2[14*4-1 -: 14];
            8'b000001xx:    temp_id2 <= rule_pri2[14*3-1 -: 14];
            8'b0000001x:    temp_id2 <= rule_pri2[14*2-1 -: 14];
            8'b00000001:    temp_id2 <= rule_pri2[14*1-1 -: 14];
            default:        temp_id2 <= 14'b0;                                       
        endcase
    end
    
    always@(*)  begin
            temp_matched1 <= (|match_flag1) && data_valid_in1; 
            temp_matched2 <= (|match_flag2) && data_valid_in2;                     
    end
        
    always@(posedge clk or negedge RSTn)  begin
        if(!RSTn)   begin
            rule_id1 <= 14'b0;
            data_valid_out1 <= 1'b0;
            is_matched1 <= 1'b0;
        end else begin
            data_valid_out1 <= data_valid_in1;
            is_matched1 <= temp_matched1;
            rule_id1 <= temp_id1;
        end
    end
  
     always@(posedge clk or negedge RSTn)  begin
        if(!RSTn)   begin
            rule_id2 <= 14'b0;
            data_valid_out2 <= 1'b0;
            is_matched2 <= 1'b0;
        end else begin
            data_valid_out2 <= data_valid_in2;
            is_matched2 <= temp_matched2;
            rule_id2 <= temp_id2;
        end
    end   
       
endmodule
