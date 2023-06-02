`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2023 10:22:52 AM
// Design Name: 
// Module Name: noc_4x4
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


module noc_4x4#(parameter BUS_WIDTH =32)
    (
    input [BUS_WIDTH-1:0] router_in00,
    input [BUS_WIDTH-1:0] router_in01,
    input [BUS_WIDTH-1:0] router_in02,
    input [BUS_WIDTH-1:0] router_in03,
    input [BUS_WIDTH-1:0] router_in10,
    input [BUS_WIDTH-1:0] router_in11,
    input [BUS_WIDTH-1:0] router_in12,
    input [BUS_WIDTH-1:0] router_in13,
    input [BUS_WIDTH-1:0] router_in20,
    input [BUS_WIDTH-1:0] router_in21,
    input [BUS_WIDTH-1:0] router_in22,
    input [BUS_WIDTH-1:0] router_in23,
    input [BUS_WIDTH-1:0] router_in30,
    input [BUS_WIDTH-1:0] router_in31,
    input [BUS_WIDTH-1:0] router_in32,
    input [BUS_WIDTH-1:0] router_in33, 
    output [BUS_WIDTH-1:0] router_out00,
    output [BUS_WIDTH-1:0] router_out01,
    output [BUS_WIDTH-1:0] router_out02,
    output [BUS_WIDTH-1:0] router_out03,
    output [BUS_WIDTH-1:0] router_out10,
    output [BUS_WIDTH-1:0] router_out11,
    output [BUS_WIDTH-1:0] router_out12,
    output [BUS_WIDTH-1:0] router_out13,
    output [BUS_WIDTH-1:0] router_out20,
    output [BUS_WIDTH-1:0] router_out21,
    output [BUS_WIDTH-1:0] router_out22,
    output [BUS_WIDTH-1:0] router_out23,
    output [BUS_WIDTH-1:0] router_out30,
    output [BUS_WIDTH-1:0] router_out31,
    output [BUS_WIDTH-1:0] router_out32,
    output [BUS_WIDTH-1:0] router_out33             
    );
    
    wire [BUS_WIDTH-1:0] s0;
    
    
endmodule
