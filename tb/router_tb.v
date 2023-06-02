`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: NidhinChandran
// 
// Create Date: 05/23/2023 10:09:42 AM
// Design Name: 
// Module Name: router_tb
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


module router_tb();
        parameter BUS_WIDTH = 32;
        
        reg [BUS_WIDTH-1:0] north_in;
        reg [BUS_WIDTH-1:0] south_in;
        reg [BUS_WIDTH-1:0] east_in;
        reg [BUS_WIDTH-1:0] west_in;
        reg [BUS_WIDTH-1:0] local_in;
        
        reg bf_inp_north;
        reg bf_inp_south;
        reg bf_inp_east;
        reg bf_inp_west;
        reg bf_inp_local;
        
        wire bf_op_north;
        wire bf_op_south;
        wire bf_op_east;
        wire bf_op_west;
        wire bf_op_local;
                                
        wire [BUS_WIDTH-1:0] north_out;
        wire [BUS_WIDTH-1:0] south_out;
        wire [BUS_WIDTH-1:0] east_out;
        wire [BUS_WIDTH-1:0] west_out;
        wire [BUS_WIDTH-1:0] local_out;
        reg clk1;
        reg clk2;
        reg rst;

        router #(.LOC_X(1),.LOC_Y(2),.NOC_SIZE(4)) uut                      //<--  can change the address od router
                    (.north_in (north_in),
                    .south_in (south_in),
                    .east_in (east_in),
                    .west_in (west_in),
                    .local_in (local_in),
                    .bf_inp_north (bf_inp_north),
                    .bf_inp_south (bf_inp_south),
                    .bf_inp_east (bf_inp_east),
                    .bf_inp_west (bf_inp_west),
                    .bf_inp_local (bf_inp_local),
                    .bf_op_north (bf_op_north),
                    .bf_op_south (bf_op_south),
                    .bf_op_east (bf_op_east),
                    .bf_op_west (bf_op_west),
                    .bf_op_local (bf_op_local),
                    .north_out (north_out),
                    .south_out (south_out),
                    .east_out (east_out),
                    .west_out (west_out),
                    .local_out (local_out),
                    .clk1 (clk1),
                    .clk2 (clk2),
                    .rst (rst));
                    
        
        
        initial 
            begin 
               forever 
                    begin
                       clk1 = 0;
                       clk2 = 0;
                       #5 clk1 = 1;
                       #5 clk1 = 0;
                       #5 clk2 = 1;
                       #5;
                   end
            end
            
        initial 
            begin 
                
               
                
                               
            end

        initial 
                begin
                
                rst = 1'b1;
                bf_inp_north=1'b0;
                bf_inp_south=1'b0;
                bf_inp_east=1'b0;
                bf_inp_west=1'b0;
                bf_inp_local=1'b0;
                
                #10;
                
                north_in  =  32'h0000000;
                south_in  =  32'h0000000;
                east_in   =  32'h0000000;
                west_in   =  32'h0000000;
                local_in  =  32'h0000000;
                
                #10;       
                rst = 1'b0; 
                #28;
                
                north_in  =  32'h00000000;
                south_in  =  32'h00000000;
                east_in   =  32'h00000000;
                west_in   =  32'h00000000;
                local_in  =  32'h00000000;
                                
                                
                   forever 
                        begin
                           if(!router.bf_op_north)
                                north_in  = $random;
                           if(!router.bf_op_south)
                                south_in  = $random;
                           if(!router.bf_op_west)
                                west_in  = $random;
                           if(!router.bf_op_east)
                                east_in  = $random;
                           if(!router.bf_op_local)
                                local_in  = $random;
                                                                                                                                                       
                           #20;
                       end
                end

         initial
            begin
                #1000;
                $finish;
            end
        
endmodule
