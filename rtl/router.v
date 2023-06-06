`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:   Nidhin Chandran
//
// Create Date: 05/17/2023 10:01:33 AM
// Design Name:
// Module Name: router
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
/////////////////////////           HEADER           /////////////////////////////
//
//                         ROUTER GENERAL INFORMATIONS
//
//    +     5 Port router of width 32 bit connecting to 4 directions (North, South, East, West) and the local chiplet
//    +     Assuming this is for a 4X4 mesh so total 16 different router address
//    +     Along with the 5 32 bit line, hand shaking line are also there for the communication of buffer availability
//    +
//    +
//    +
//
//                       INPUT FLIT GENARAL INFORMATIONS
//
//      |  4- bit   |              28 bit               |
//      |destination|               DATA                |
//      |    I D    |                                   |
//       31-------28 27---------------------------------0
//
//     +  Assuming destination I D is in the format
//                     | Y ID | X ID |
//                      31-30  29-28
//        ^
//        |     0000    0001   0010    0011                          N
//        |                                                          |
//        |     0100    0101   0110    0111                     W----|----E
//        Y                                                          |
//        |     1000    1001   1010    1011                          S
//        |
//        |     1100    1101   1110    1111
//        |
//        |------------ X ------------------->
//
////////////////////////////////////////////////////////////////////////////////////
                                                                                  
module router #(parameter BUS_WIDTH =32,
        parameter LOC_X = 2'b01,                                                                   //  Address of this router
        parameter LOC_Y = 2'b10,
	parameter NOC_SIZE = 3'b100 )                                                              //   4X4 network
         
        (
		input [BUS_WIDTH-1:0] north_in,                                                    //    
		input [BUS_WIDTH-1:0] south_in,                                                    //
		input [BUS_WIDTH-1:0] west_in,                                                     //     32 bit width input filts from each directions
		input [BUS_WIDTH-1:0] east_in,                                                     //
		input [BUS_WIDTH-1:0] local_in,                                                    //

		input bf_inp_north,                                                                //
		input bf_inp_south,                                                                //
		input bf_inp_west,                                                                 //      buffer full indication from neighbouring tiles
		input bf_inp_east,                                                                 //        +  to deside wheather to write or not
		input bf_inp_local,                                                                //

		output reg bf_op_north,                                                            //
		output reg bf_op_south,                                                            //
		output reg bf_op_west,                                                             //      buffer full indication for neighbouring tiles
		output reg bf_op_east,                                                             //
		output reg bf_op_local,                                                            //

		output reg [BUS_WIDTH-1:0] north_out,                                              //
		output reg [BUS_WIDTH-1:0] south_out,                                              //
		output reg [BUS_WIDTH-1:0] east_out,                                               //      32 bit output to 5 directions
		output reg [BUS_WIDTH-1:0] west_out,                                               //
		output reg [BUS_WIDTH-1:0] local_out,                                              //

		input clk1,                                                                        //     clock signal
		input clk2,                                                                        //     clock signal

		input rst                                                                          //     reset signal
    );
                //               intermidiate register declaration
                                                                                  
	reg [BUS_WIDTH-1:0] in_north;                                                              //
	reg [BUS_WIDTH-1:0] in_south;                                                              //
	reg [BUS_WIDTH-1:0] in_east;                                                               //
	reg [BUS_WIDTH-1:0] in_west;                                                               //
	reg [BUS_WIDTH-1:0] in_local;                                                              //
        
        reg [3:0] north_route;
        reg [3:0] south_route;
        reg [3:0] east_route;
        reg [3:0] west_route;
        reg [3:0] local_route;
        
        reg [3:0] count;
        
        reg north_taken;
        reg south_taken;
        reg east_taken;
        reg west_taken;
        reg local_taken;
            

        
                                                        //  + can change accordingly
        
        localparam NORTH = 3'b000;
        localparam SOUTH = 3'b001;
        localparam WEST = 3'b010;
        localparam EAST = 3'b011;
        localparam LOCAL = 3'b100;
        
        localparam ADDR_SIZE = $clog2(NOC_SIZE);
        
//___________________________________BUFFER WRITE___________________________________
                                                                                         
        always @(posedge clk2)
            begin
                if(rst)
                    begin
                        in_north      <= 32'b0;
                        in_south      <= 32'b0;
                        in_east       <= 32'b0;
                        in_west       <= 32'b0;
                        in_local      <= 32'b0;
                        
                        bf_op_north   <= 1'b0;
                        bf_op_south   <= 1'b0;
                        bf_op_west    <= 1'b0;
                        bf_op_east    <= 1'b0;
                        bf_op_local   <= 1'b0;
                        
                        count         <= 0;
                    end
                    
                else
                    begin
                        if(!bf_op_north)
                             begin
                                 in_north      <= north_in;
                             end
                        if(!bf_op_south)
                             begin
                                 in_south      <= south_in;
                             end
                        if(!bf_op_east)
                             begin
                                 in_east       <= east_in;
                             end
                        if(!bf_op_west)
                             begin
                                 in_west       <= west_in;
                             end
                        if(!bf_op_local)
                             begin
                                 in_local      <= local_in;
                             end
                    end
            end

             always @ (posedge clk1)                                                         //      for  sycn
                  begin                                                                      //
                       north_taken = 1'b0;                                                   //    indicator for each route wheather that route is allocated in that clock cycle
                       south_taken = 1'b0;                                                   //      +  this will be helpful when multiple input need same direction
                       east_taken  = 1'b0;                                                   //      +  buffer write can be stopped with these as control
                       west_taken  = 1'b0;                                                   //
                       local_taken = 1'b0;                                                   //
                                                                                             
                       if (rst)                                                              //
                           begin                                                             //    a mod 5 counter to change the priority
                               count = 0;                                                    //
                           end                                                               //
                       else if(count == 3'b100)                                              //
                           begin                                                             //
                               count = 0;                                                    //
                           end                                                               //
                       else                                                                  //
                           begin                                                             //
                               count = count + 1;                                            //
                           end                                                               //
                  end                                                                        //


//______________________________ ROUTE COMPUTATING_________________________________
        always @ (posedge clk1)
        
        
            begin
              if(in_north ==32'b0)
                    begin
                        north_route           =3'b111;
                    end
              else if(in_north[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] > LOC_Y)                                       // route computing of input from north
                    begin                                                                                      //
                        north_route           =  SOUTH;                                                        //
                    end                                                                                        //
                else if(in_north[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] < LOC_Y)                                     //
                    begin                                                                                      //
                        north_route           =  NORTH;                                                        //
                    end                                                                                        //
                else                                                                                           // Y match
                    begin                                                                                      //
                        if(in_north[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] > LOC_X)                    //
                            begin                                                                              //
                                north_route   = EAST;                                                          //
                            end                                                                                //
                         else if (in_north[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] < LOC_X)             //
                            begin                                                                              //
                                north_route   = WEST;                                                          //
                            end                                                                                //
                        else if ((in_north[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] == LOC_Y) && (in_north[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] == LOC_X ) )                    
                            begin                                                                              //
                                north_route   = LOCAL;                                                         // X match
                            end
                        else    north_route   = 3'b111;                                                        //
                    end 
                    
                
                
              if(in_south ==32'b0)
                          begin
                              south_route           =3'b111;
                          end
                    else if(in_south[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] > LOC_Y)                                          // route computing of input from south
                        begin                                                                                           //
                            south_route           =  SOUTH;                                                             //
                        end                                                                                             //
                    else if(in_south[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] < LOC_Y)                                          //
                        begin                                                                                           //
                            south_route           =  NORTH;                                                             //
                        end                                                                                             //
                    else                                                                                                //  Y match
                        begin                                                                                           //
                            if(in_south[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] > LOC_X)                         //
                                begin                                                                                   //
                                    south_route   = EAST;                                                               //
                                end                                                                                     //
                             else if (in_south[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] < LOC_X)                  //
                                begin                                                                                   //
                                    south_route   = WEST;                                                               //
                                end                                                                                     //
                            else if((in_south[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] == LOC_Y) && (in_south[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] == LOC_X ))                
                                begin                                                                                   //
                                    south_route   = LOCAL;                                                              // X match
                                end
                            else    south_route   = 3'b111;                                                             //
                        end                                                                                             //
                

              if(in_east ==32'b0)
                              begin
                                  east_route           =3'b111;
                              end
                        else if(in_east[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] > LOC_Y)                                      // route computing of input from east
                        begin                                                                                          //
                            east_route           =  SOUTH;                                                             //
                        end                                                                                            //
                    else if(in_east[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] < LOC_Y)                                          //
                        begin                                                                                          //
                            east_route           =  NORTH;                                                             //
                        end                                                                                            //
                    else                                                                                               //  Y match
                        begin                                                                                          //
                            if(in_east[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] > LOC_X)                         //
                                begin                                                                                  //
                                    east_route   = EAST;                                                               //
                                end                                                                                    //
                             else if (in_east[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] < LOC_X)                  //
                                begin                                                                                  //
                                    east_route   = WEST;                                                               //
                                end                                                                                    //
                            else if((in_east[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] == LOC_Y) && (in_east[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] == LOC_X ))                
                               begin                                                                                   //
                                    east_route   = LOCAL;                                                              // X match
                                end
                            else    east_route   = 3'b111;                                                             //
                        end                                                                                            //


              if(in_west ==32'b0)
                              begin
                                  west_route           =3'b111;
                              end
                        else if(in_west[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] > LOC_Y)                                      // route computing of input from weat
                        begin                                                                                          //
                            west_route           =  SOUTH;                                                             //
                        end                                                                                            //
                    else if(in_west[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] < LOC_Y)                                          //
                        begin                                                                                          //
                            west_route           =  NORTH;                                                             //
                        end                                                                                            //
                    else                                                                                               //  Y match
                        begin                                                                                          //
                            if(in_west[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] > LOC_X)                         //
                                begin                                                                                  //
                                    west_route   = EAST;                                                               //
                                end                                                                                    //
                             else if (in_west[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] < LOC_X)                  //
                                begin                                                                                  //
                                    west_route   = WEST;                                                               //
                                end                                                                                    //
                            else if((in_west[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] == LOC_Y) && (in_west[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] == LOC_X ))               
                                   begin                                                                               //
                                        west_route   = LOCAL;                                                          // X match
                                    end
                                else    west_route   = 3'b111;                                                         //

                        end                                                                                            //


              if(in_local ==32'b0)
                              begin
                                  local_route           =3'b111;
                              end
                        else if(in_local[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] > LOC_Y)                                     // route computing of input from local
                        begin                                                                                          //
                            local_route           =  SOUTH;                                                            //
                        end                                                                                            //
                    else if(in_local[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] < LOC_Y)                                         //
                        begin                                                                                          //
                            local_route           =  NORTH;                                                            //
                        end                                                                                            //
                    else                                                                                               //  Y match
                        begin                                                                                          //
                            if(in_local[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] > LOC_X)                        //
                                begin                                                                                  //
                                    local_route   = EAST;                                                              //
                                end                                                                                    //
                             else if (in_local[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] < LOC_X)                 //
                                begin                                                                                  //
                                    local_route   = WEST;                                                              //
                                end                                                                                    //
                             else if((in_local[BUS_WIDTH-1:BUS_WIDTH-ADDR_SIZE] == LOC_Y) && (in_local[BUS_WIDTH-ADDR_SIZE-1:BUS_WIDTH-(2*ADDR_SIZE)] == LOC_X ))               
                                   begin                                                                               //
                                        local_route   = LOCAL;                                                         // X match
                                    end
                                else    local_route   = 3'b111;                                                        //

                        end                                                                                            //
               
                
         
            
 // _________________________ SWITCH ALLOCATION ______________________________________
            
            
            
  
           
               case (count)
                           0:begin
                                   case (north_route)
                                        NORTH:  begin
                                                    if(!north_taken && !bf_inp_north)
                                                        begin
                                                            north_out = in_north;
                                                            north_taken = 1'b1;
                                                            bf_op_north = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_north = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && !bf_inp_south)
                                                        begin
                                                            south_out = in_north;
                                                            south_taken = 1'b1;
                                                            bf_op_north = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_north = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && !bf_inp_west)
                                                         begin
                                                             west_out = in_north;
                                                             west_taken = 1'b1;
                                                             bf_op_north = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_north = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && !bf_inp_east)
                                                         begin
                                                             east_out = in_north;
                                                             east_taken = 1'b1;
                                                             bf_op_north = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_north = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && !bf_inp_local)
                                                           begin
                                                               local_out = in_north;
                                                               local_taken = 1'b1;
                                                               bf_op_north = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                               bf_op_north = 1'b1;
                                                           end
                                                end                                                                                                                                        
                                   endcase
                                    
                                   case (south_route)
                                        NORTH:  begin
                                                    if(!north_taken && !bf_inp_north)
                                                        begin
                                                            north_out = in_south;
                                                            north_taken = 1'b1;
                                                            bf_op_south = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_south = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && !bf_inp_south)
                                                        begin
                                                            south_out = in_south;
                                                            south_taken = 1'b1;
                                                            bf_op_south = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_south = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && !bf_inp_west)
                                                         begin
                                                             west_out = in_south;
                                                             west_taken = 1'b1;
                                                             bf_op_south = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_south = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && !bf_inp_east)
                                                         begin
                                                             east_out = in_south;
                                                             east_taken = 1'b1;
                                                             bf_op_south = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_south = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && !bf_inp_local)
                                                           begin
                                                               local_out = in_south;
                                                               local_taken = 1'b1;
                                                               bf_op_south = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                               bf_op_south = 1'b1;
                                                           end
                                                   end 
                                   endcase
                                    
                                   case (east_route)                   
                                    
                                        NORTH:  begin
                                                    if(!north_taken && !bf_inp_north)
                                                        begin
                                                            north_out = in_east;
                                                            north_taken = 1'b1;
                                                            bf_op_east = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_east = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && !bf_inp_south)
                                                        begin
                                                            south_out = in_east;
                                                            south_taken = 1'b1;
                                                            bf_op_east = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_east = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && !bf_inp_west)
                                                         begin
                                                             west_out = in_east;
                                                             west_taken = 1'b1;
                                                             bf_op_east = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_east = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && !bf_inp_east)
                                                         begin
                                                             east_out = in_east;
                                                             east_taken = 1'b1;
                                                             bf_op_east = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_east = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && !bf_inp_local)
                                                           begin
                                                               local_out = in_east;
                                                               local_taken = 1'b1;
                                                               bf_op_east = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                               bf_op_east = 1'b1;
                                                           end
                                                   end                                                                                                                                        
                                   endcase
                                    
                                   case (west_route)                   
                                    
                                        NORTH:  begin
                                                    if(!north_taken && !bf_inp_north)
                                                        begin
                                                            north_out = in_west;
                                                            north_taken = 1'b1;
                                                            bf_op_west = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_west = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && !bf_inp_south)
                                                        begin
                                                            south_out = in_west;
                                                            south_taken = 1'b1;
                                                            bf_op_west = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_west = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && !bf_inp_west)
                                                         begin
                                                             west_out = in_west;
                                                             west_taken = 1'b1;
                                                             bf_op_west = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_west = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && !bf_inp_east)
                                                         begin
                                                             east_out = in_west;
                                                             east_taken = 1'b1;
                                                             bf_op_west = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_west = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && !bf_inp_local)
                                                           begin
                                                               local_out = in_west;
                                                               local_taken = 1'b1;
                                                               bf_op_west = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                               bf_op_west = 1'b1;
                                                           end
                                                   end                                                                                                                                        
                                   endcase
 
                                   case (local_route)                   
                                    
                                        NORTH:  begin
                                                    if(!north_taken && !bf_inp_north)
                                                        begin
                                                            north_out = in_local;
                                                            north_taken = 1'b1;
                                                            bf_op_local = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_local = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && !bf_inp_south)
                                                        begin
                                                            south_out = in_local;
                                                            south_taken = 1'b1;
                                                            bf_op_local = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                            bf_op_local = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && !bf_inp_west)
                                                         begin
                                                             west_out = in_local;
                                                             west_taken = 1'b1;
                                                             bf_op_local = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_local = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && !bf_inp_east)
                                                         begin
                                                             east_out = in_local;
                                                             east_taken = 1'b1;
                                                             bf_op_local = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_local = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && !bf_inp_local)
                                                           begin
                                                               local_out = in_local;
                                                               local_taken = 1'b1;
                                                               bf_op_local = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                               bf_op_local = 1'b1;
                                                           end
                                                   end                                                                                                                                        
                                    endcase
                                    
                                                                       
                              end
                              
                              
                           1:begin
                                     
                                     case (south_route)
                                         NORTH:  begin
                                                     if(!north_taken && !bf_inp_north)
                                                         begin
                                                             north_out = in_south;
                                                             north_taken = 1'b1;
                                                             bf_op_south = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_south = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && !bf_inp_south)
                                                         begin
                                                             south_out = in_south;
                                                             south_taken = 1'b1;
                                                             bf_op_south = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_south = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && !bf_inp_west)
                                                          begin
                                                              west_out = in_south;
                                                              west_taken = 1'b1;
                                                              bf_op_south = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_south = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && !bf_inp_east)
                                                          begin
                                                              east_out = in_south;
                                                              east_taken = 1'b1;
                                                              bf_op_south = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_south = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && !bf_inp_local)
                                                            begin
                                                                local_out = in_south;
                                                                local_taken = 1'b1;
                                                                bf_op_south = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                bf_op_south = 1'b1;
                                                            end
                                                    end 
                                     endcase
                                     
                                     case (east_route)                   
                                     
                                         NORTH:  begin
                                                     if(!north_taken && !bf_inp_north)
                                                         begin
                                                             north_out = in_east;
                                                             north_taken = 1'b1;
                                                             bf_op_east = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_east = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && !bf_inp_south)
                                                         begin
                                                             south_out = in_east;
                                                             south_taken = 1'b1;
                                                             bf_op_east = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_east = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && !bf_inp_west)
                                                          begin
                                                              west_out = in_east;
                                                              west_taken = 1'b1;
                                                              bf_op_east = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_east = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && !bf_inp_east)
                                                          begin
                                                              east_out = in_east;
                                                              east_taken = 1'b1;
                                                              bf_op_east = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_east = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && !bf_inp_local)
                                                            begin
                                                                local_out = in_east;
                                                                local_taken = 1'b1;
                                                                bf_op_east = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                bf_op_east = 1'b1;
                                                            end
                                                    end                                                                                                                                        
                                     endcase
                                     
                                     case (west_route)                   
                                     
                                         NORTH:  begin
                                                     if(!north_taken && !bf_inp_north)
                                                         begin
                                                             north_out = in_west;
                                                             north_taken = 1'b1;
                                                             bf_op_west = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_west = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && !bf_inp_south)
                                                         begin
                                                             south_out = in_west;
                                                             south_taken = 1'b1;
                                                             bf_op_west = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_west = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && !bf_inp_west)
                                                          begin
                                                              west_out = in_west;
                                                              west_taken = 1'b1;
                                                              bf_op_west = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_west = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && !bf_inp_east)
                                                          begin
                                                              east_out = in_west;
                                                              east_taken = 1'b1;
                                                              bf_op_west = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_west = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && !bf_inp_local)
                                                            begin
                                                                local_out = in_west;
                                                                local_taken = 1'b1;
                                                                bf_op_west = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                bf_op_west = 1'b1;
                                                            end
                                                    end                                                                                                                                        
                                     endcase
        
                                     case (local_route)                   
                                     
                                         NORTH:  begin
                                                     if(!north_taken && !bf_inp_north)
                                                         begin
                                                             north_out = in_local;
                                                             north_taken = 1'b1;
                                                             bf_op_local = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_local = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && !bf_inp_south)
                                                         begin
                                                             south_out = in_local;
                                                             south_taken = 1'b1;
                                                             bf_op_local = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_local = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && !bf_inp_west)
                                                          begin
                                                              west_out = in_local;
                                                              west_taken = 1'b1;
                                                              bf_op_local = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_local = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && !bf_inp_east)
                                                          begin
                                                              east_out = in_local;
                                                              east_taken = 1'b1;
                                                              bf_op_local = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_local = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && !bf_inp_local)
                                                            begin
                                                                local_out = in_local;
                                                                local_taken = 1'b1;
                                                                bf_op_local = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                bf_op_local  = 1'b1;
                                                            end
                                                    end                                                                                                                                        
                                     endcase
                                     
                                    case (north_route)
                                         NORTH:  begin
                                                     if(!north_taken && !bf_inp_north)
                                                         begin
                                                             north_out = in_north;
                                                             north_taken = 1'b1;
                                                             bf_op_north = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_north = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && !bf_inp_south)
                                                         begin
                                                             south_out = in_north;
                                                             south_taken = 1'b1;
                                                             bf_op_north = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             bf_op_north = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && !bf_inp_west)
                                                          begin
                                                              west_out = in_north;
                                                              west_taken = 1'b1;
                                                              bf_op_north = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_north = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && !bf_inp_east)
                                                          begin
                                                              east_out = in_north;
                                                              east_taken = 1'b1;
                                                              bf_op_north = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              bf_op_north = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && !bf_inp_local)
                                                            begin
                                                                local_out = in_north;
                                                                local_taken = 1'b1;
                                                                bf_op_north = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                bf_op_north = 1'b1;
                                                            end
                                                    end                                                                                                                                        
                                     endcase
                                     
                                                                        
                               end

                            2:begin
                                                                               
                                         case (east_route)                   
                                         
                                             NORTH:  begin
                                                         if(!north_taken && !bf_inp_north)
                                                             begin
                                                                 north_out = in_east;
                                                                 north_taken = 1'b1;
                                                                 bf_op_east = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 bf_op_east = 1'b1;
                                                             end
                                                     end
                                             SOUTH:  begin
                                                         if(!south_taken && !bf_inp_south)
                                                             begin
                                                                 south_out = in_east;
                                                                 south_taken = 1'b1;
                                                                 bf_op_east = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 bf_op_east = 1'b1;
                                                             end
                                                     end
                                              WEST:  begin
                                                          if(!west_taken && !bf_inp_west)
                                                              begin
                                                                  west_out = in_east;
                                                                  west_taken = 1'b1;
                                                                  bf_op_east = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_east = 1'b1;
                                                              end
                                                      end
                                              EAST:  begin
                                                          if(!east_taken && !bf_inp_east)
                                                              begin
                                                                  east_out = in_east;
                                                                  east_taken = 1'b1;
                                                                  bf_op_east = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_east = 1'b1;
                                                              end
                                                      end
                                             LOCAL:  begin
                                                            if(!local_taken && !bf_inp_local)
                                                                begin
                                                                    local_out = in_east;
                                                                    local_taken = 1'b1;
                                                                    bf_op_east = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    bf_op_east = 1'b1;
                                                                end
                                                        end                                                                                                                                        
                                         endcase
                                         
                                         case (west_route)                   
                                         
                                             NORTH:  begin
                                                         if(!north_taken && !bf_inp_north)
                                                             begin
                                                                 north_out = in_west;
                                                                 north_taken = 1'b1;
                                                                 bf_op_west = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 bf_op_west = 1'b1;
                                                             end
                                                     end
                                             SOUTH:  begin
                                                         if(!south_taken && !bf_inp_south)
                                                             begin
                                                                 south_out = in_west;
                                                                 south_taken = 1'b1;
                                                                 bf_op_west = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 bf_op_west = 1'b1;
                                                             end
                                                     end
                                              WEST:  begin
                                                          if(!west_taken && !bf_inp_west)
                                                              begin
                                                                  west_out = in_west;
                                                                  west_taken = 1'b1;
                                                                  bf_op_west = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_west = 1'b1;
                                                              end
                                                      end
                                              EAST:  begin
                                                          if(!east_taken && !bf_inp_east)
                                                              begin
                                                                  east_out = in_west;
                                                                  east_taken = 1'b1;
                                                                  bf_op_west = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_west = 1'b1;
                                                              end
                                                      end
                                             LOCAL:  begin
                                                            if(!local_taken && !bf_inp_local)
                                                                begin
                                                                    local_out = in_west;
                                                                    local_taken = 1'b1;
                                                                    bf_op_west = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    bf_op_west = 1'b1;
                                                                end
                                                        end                                                                                                                                        
                                         endcase
            
                                         case (local_route)                   
                                         
                                             NORTH:  begin
                                                         if(!north_taken && !bf_inp_north)
                                                             begin
                                                                 north_out = in_local;
                                                                 north_taken = 1'b1;
                                                                 bf_op_local = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 bf_op_local = 1'b1;
                                                             end
                                                     end
                                             SOUTH:  begin
                                                         if(!south_taken && !bf_inp_south)
                                                             begin
                                                                 south_out = in_local;
                                                                 south_taken = 1'b1;
                                                                 bf_op_local = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 bf_op_local = 1'b1;
                                                             end
                                                     end
                                              WEST:  begin
                                                          if(!west_taken && !bf_inp_west)
                                                              begin
                                                                  west_out = in_local;
                                                                  west_taken = 1'b1;
                                                                  bf_op_local = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_local = 1'b1;
                                                              end
                                                      end
                                              EAST:  begin
                                                          if(!east_taken && !bf_inp_east)
                                                              begin
                                                                  east_out = in_local;
                                                                  east_taken = 1'b1;
                                                                  bf_op_local = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_local = 1'b1;
                                                              end
                                                      end
                                             LOCAL:  begin
                                                            if(!local_taken && !bf_inp_local)
                                                                begin
                                                                    local_out = in_local;
                                                                    local_taken = 1'b1;
                                                                    bf_op_local = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    bf_op_local = 1'b1;
                                                                end
                                                        end                                                                                                                                        
                                         endcase
                                         
                                        case (north_route)
                                             NORTH:  begin
                                                         if(!north_taken && !bf_inp_north)
                                                             begin
                                                                 north_out = in_north;
                                                                 north_taken = 1'b1;
                                                                 bf_op_north = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 bf_op_north = 1'b1;
                                                             end
                                                     end
                                             SOUTH:  begin
                                                         if(!south_taken && !bf_inp_south)
                                                             begin
                                                                 south_out = in_north;
                                                                 south_taken = 1'b1;
                                                                 bf_op_north = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 bf_op_north = 1'b1;
                                                             end
                                                     end
                                              WEST:  begin
                                                          if(!west_taken && !bf_inp_west)
                                                              begin
                                                                  west_out = in_north;
                                                                  west_taken = 1'b1;
                                                                  bf_op_north = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_north = 1'b1;
                                                              end
                                                      end
                                              EAST:  begin
                                                          if(!east_taken && !bf_inp_east)
                                                              begin
                                                                  east_out = in_north;
                                                                  east_taken = 1'b1;
                                                                  bf_op_north = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_north = 1'b1;
                                                              end
                                                      end
                                             LOCAL:  begin
                                                            if(!local_taken && !bf_inp_local)
                                                                begin
                                                                    local_out = in_north;
                                                                    local_taken = 1'b1;
                                                                    bf_op_north = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    bf_op_north = 1'b1;
                                                                end
                                                        end                                                                                                                                        
                                         endcase
                                         
                                          case (south_route)
                                                NORTH:  begin
                                                            if(!north_taken && !bf_inp_north)
                                                                begin
                                                                    north_out = in_south;
                                                                    north_taken = 1'b1;
                                                                    bf_op_south = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    bf_op_south = 1'b1;
                                                                end
                                                        end
                                                SOUTH:  begin
                                                            if(!south_taken && !bf_inp_south)
                                                                begin
                                                                    south_out = in_south;
                                                                    south_taken = 1'b1;
                                                                    bf_op_south = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    bf_op_south = 1'b1;
                                                                end
                                                        end
                                                 WEST:  begin
                                                             if(!west_taken && !bf_inp_west)
                                                                 begin
                                                                     west_out = in_south;
                                                                     west_taken = 1'b1;
                                                                     bf_op_south = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     bf_op_south =  1'b1;
                                                                 end
                                                         end
                                                 EAST:  begin
                                                             if(!east_taken && !bf_inp_east)
                                                                 begin
                                                                     east_out = in_south;
                                                                     east_taken = 1'b1;
                                                                     bf_op_south = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     bf_op_south = 1'b1;
                                                                 end
                                                         end
                                                LOCAL:  begin
                                                            if(!local_taken && !bf_inp_local)
                                                                begin
                                                                    local_out = in_south;
                                                                    local_taken = 1'b1;
                                                                    bf_op_south = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    bf_op_south = 1'b1;
                                                                end
                                                        end 
                                         endcase
                                                                                 
                                                                            
                                   end

                            3:begin
                                                                                      
                                          case (west_route)                   
                                          
                                              NORTH:  begin
                                                          if(!north_taken && !bf_inp_north)
                                                              begin
                                                                  north_out = in_west;
                                                                  north_taken = 1'b1;
                                                                  bf_op_west = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_west = 1'b1;
                                                              end
                                                      end
                                              SOUTH:  begin
                                                          if(!south_taken && !bf_inp_south)
                                                              begin
                                                                  south_out = in_west;
                                                                  south_taken = 1'b1;
                                                                  bf_op_west = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_west = 1'b1;
                                                              end
                                                      end
                                               WEST:  begin
                                                           if(!west_taken && !bf_inp_west)
                                                               begin
                                                                   west_out = in_west;
                                                                   west_taken = 1'b1;
                                                                   bf_op_west = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   bf_op_west = 1'b1;
                                                               end
                                                       end
                                               EAST:  begin
                                                           if(!east_taken && !bf_inp_east)
                                                               begin
                                                                   east_out = in_west;
                                                                   east_taken = 1'b1;
                                                                   bf_op_west = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   bf_op_west = 1'b1;
                                                               end
                                                       end
                                              LOCAL:  begin
                                                             if(!local_taken && !bf_inp_local)
                                                                 begin
                                                                     local_out = in_west;
                                                                     local_taken = 1'b1;
                                                                     bf_op_west = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     bf_op_west = 1'b1;
                                                                 end
                                                         end                                                                                                                                        
                                          endcase
         
                                          case (local_route)                   
                                          
                                              NORTH:  begin
                                                          if(!north_taken && !bf_inp_north)
                                                              begin
                                                                  north_out = in_local;
                                                                  north_taken = 1'b1;
                                                                  bf_op_local = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_local = 1'b1;
                                                              end
                                                      end
                                              SOUTH:  begin
                                                          if(!south_taken && !bf_inp_south)
                                                              begin
                                                                  south_out = in_local;
                                                                  south_taken = 1'b1;
                                                                  bf_op_local = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_local = 1'b1;
                                                              end
                                                      end
                                               WEST:  begin
                                                           if(!(west_taken ||  bf_inp_west))
                                                               begin
                                                                   west_out = in_local;
                                                                   west_taken = 1'b1;
                                                                   bf_op_local = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   bf_op_local = 1'b1;
                                                               end
                                                       end
                                               EAST:  begin
                                                           if(!east_taken && !bf_inp_east)
                                                               begin
                                                                   east_out = in_local;
                                                                   east_taken = 1'b1;
                                                                   bf_op_local = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   bf_op_local = 1'b1;
                                                               end
                                                       end
                                              LOCAL:  begin
                                                             if(!local_taken && !bf_inp_local)
                                                                 begin
                                                                     local_out = in_local;
                                                                     local_taken = 1'b1;
                                                                     bf_op_local = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     bf_op_local = 1'b1;
                                                                 end
                                                         end
                                          endcase
                                          
                                         case (north_route)
                                              NORTH:  begin
                                                          if(!north_taken && !bf_inp_north)
                                                              begin
                                                                  north_out = in_north;
                                                                  north_taken = 1'b1;
                                                                  bf_op_north = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_north = 1'b1;
                                                              end
                                                      end
                                              SOUTH:  begin
                                                          if(!south_taken && !bf_inp_south)
                                                              begin
                                                                  south_out = in_north;
                                                                  south_taken = 1'b1;
                                                                  bf_op_north = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_north = 1'b1;
                                                              end
                                                      end
                                               WEST:  begin
                                                           if(!west_taken && !bf_inp_west)
                                                               begin
                                                                   west_out = in_north;
                                                                   west_taken = 1'b1;
                                                                   bf_op_north = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   bf_op_north = 1'b1;
                                                               end
                                                       end
                                               EAST:  begin
                                                           if(!east_taken && !bf_inp_east)
                                                               begin
                                                                   east_out = in_north;
                                                                   east_taken = 1'b1;
                                                                   bf_op_north = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   bf_op_north = 1'b1;
                                                               end
                                                       end
                                              LOCAL:  begin
                                                             if(!local_taken && !bf_inp_local)
                                                                 begin
                                                                     local_out = in_north;
                                                                     local_taken = 1'b1;
                                                                     bf_op_north = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     bf_op_north = 1'b1;
                                                                 end
                                                         end
                                          endcase
                                          
                                           case (south_route)
                                                 NORTH:  begin
                                                             if(!north_taken && !bf_inp_north)
                                                                 begin
                                                                     north_out = in_south;
                                                                     north_taken = 1'b1;
                                                                     bf_op_south = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     bf_op_south = 1'b1;
                                                                 end
                                                         end
                                                 SOUTH:  begin
                                                             if(!south_taken && !bf_inp_south)
                                                                 begin
                                                                     south_out = in_south;
                                                                     south_taken = 1'b1;
                                                                     bf_op_south = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     bf_op_south = 1'b1;
                                                                 end
                                                         end
                                                  WEST:  begin
                                                              if(!west_taken && !bf_inp_west)
                                                                  begin
                                                                      west_out = in_south;
                                                                      west_taken = 1'b1;
                                                                      bf_op_south = 1'b0;
                                                                  end
                                                              else
                                                                  begin
                                                                      bf_op_south = 1'b1;
                                                                  end
                                                          end
                                                  EAST:  begin
                                                              if(!east_taken && !bf_inp_east)
                                                                  begin
                                                                      east_out = in_south;
                                                                      east_taken = 1'b1;
                                                                      bf_op_south = 1'b0;
                                                                  end
                                                              else
                                                                  begin
                                                                      bf_op_south = 1'b1;
                                                                  end
                                                          end
                                                 LOCAL:  begin
                                                               if(!local_taken && !bf_inp_local)
                                                                   begin
                                                                       local_out = in_south;
                                                                       local_taken = 1'b1;
                                                                       bf_op_south = 1'b0;
                                                                   end
                                                               else
                                                                   begin
                                                                       bf_op_south = 1'b1;
                                                                   end
                                                           end 
                                   endcase
                                           
                                   case (east_route)                   
                                                
                                                NORTH:  begin
                                                          if(!north_taken && !bf_inp_north)
                                                              begin
                                                                  north_out = in_east;
                                                                  north_taken = 1'b1;
                                                                  bf_op_east = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_east = 1'b1;
                                                              end
                                                      end
                                              SOUTH:  begin
                                                          if(!south_taken && !bf_inp_south)
                                                              begin
                                                                  south_out = in_east;
                                                                  south_taken = 1'b1;
                                                                  bf_op_east = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  bf_op_east = 1'b1;
                                                              end
                                                      end
                                               WEST:  begin
                                                           if(!west_taken && !bf_inp_west)
                                                               begin
                                                                   west_out = in_east;
                                                                   west_taken = 1'b1;
                                                                   bf_op_east = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   bf_op_east = 1'b1;
                                                               end
                                                       end
                                               EAST:  begin
                                                           if(!east_taken && !bf_inp_east)
                                                               begin
                                                                   east_out = in_east;
                                                                   east_taken = 1'b1;
                                                                   bf_op_east = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   bf_op_east = 1'b1;
                                                               end
                                                       end
                                              LOCAL:  begin
                                                             if(!local_taken && !bf_inp_local)
                                                                 begin
                                                                     local_out = in_east;
                                                                     local_taken = 1'b1;
                                                                     bf_op_east = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     bf_op_east = 1'b1;
                                                                 end
                                                         end                                                                                                                                        
                                          endcase
                                          end
                                          
                            4:begin
                                                                                                    
                       
                                                        case (local_route)                   
                                                        
                                                            NORTH:  begin
                                                                        if(!north_taken && !bf_inp_north)
                                                                            begin
                                                                                north_out = in_local;
                                                                                north_taken = 1'b1;
                                                                                bf_op_local = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                                bf_op_local = 1'b1;
                                                                            end
                                                                    end
                                                            SOUTH:  begin
                                                                        if(!south_taken && !bf_inp_south)
                                                                            begin
                                                                                south_out = in_local;
                                                                                south_taken = 1'b1;
                                                                                bf_op_local = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                                bf_op_local = 1'b1;
                                                                            end
                                                                    end
                                                             WEST:  begin
                                                                         if(!west_taken && !bf_inp_west)
                                                                             begin
                                                                                 west_out = in_local;
                                                                                 west_taken = 1'b1;
                                                                                 bf_op_local = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                 bf_op_local = 1'b1;
                                                                             end
                                                                     end
                                                             EAST:  begin
                                                                         if(!east_taken && !bf_inp_east)
                                                                             begin
                                                                                 east_out = in_local;
                                                                                 east_taken = 1'b1;
                                                                                 bf_op_local = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                 bf_op_local = 1'b1;
                                                                             end
                                                                     end
                                                            LOCAL:  begin
                                                                           if(!local_taken && !bf_inp_local)
                                                                               begin
                                                                                   local_out = in_local;
                                                                                   local_taken = 1'b1;
                                                                                   bf_op_local = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                   bf_op_local = 1'b1;
                                                                               end
                                                                       end
                                                        endcase
                                                        
                                                       case (north_route)
                                                            NORTH:  begin
                                                                        if(!north_taken && !bf_inp_north)
                                                                            begin
                                                                                north_out = in_north;
                                                                                north_taken = 1'b1;
                                                                                bf_op_north = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                                bf_op_north = 1'b1;
                                                                            end
                                                                    end
                                                            SOUTH:  begin
                                                                        if(!south_taken && !bf_inp_south)
                                                                            begin
                                                                                south_out = in_north;
                                                                                south_taken = 1'b1;
                                                                                bf_op_north = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                                bf_op_north = 1'b1;
                                                                            end
                                                                    end
                                                             WEST:  begin
                                                                         if(!west_taken && !bf_inp_west)
                                                                             begin
                                                                                 west_out = in_north;
                                                                                 west_taken = 1'b1;
                                                                                 bf_op_north = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                 bf_op_north = 1'b1;
                                                                             end
                                                                     end
                                                             EAST:  begin
                                                                         if(!east_taken && !bf_inp_east)
                                                                             begin
                                                                                 east_out = in_north;
                                                                                 east_taken = 1'b1;
                                                                                 bf_op_north = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                 bf_op_north = 1'b1;
                                                                             end
                                                                     end
                                                            LOCAL:  begin
                                                                           if(!local_taken && !bf_inp_local)
                                                                               begin
                                                                                   local_out = in_north;
                                                                                   local_taken = 1'b1;
                                                                                   bf_op_north = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                   bf_op_north = 1'b1;
                                                                               end
                                                                       end
                                                        endcase
                                                        
                                                         case (south_route)
                                                               NORTH:  begin
                                                                           if(!north_taken && !bf_inp_north)
                                                                               begin
                                                                                   north_out = in_south;
                                                                                   north_taken = 1'b1;
                                                                                   bf_op_south = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                   bf_op_south = 1'b1;
                                                                               end
                                                                       end
                                                               SOUTH:  begin
                                                                           if(!south_taken && !bf_inp_south)
                                                                               begin
                                                                                   south_out = in_south;
                                                                                   south_taken = 1'b1;
                                                                                   bf_op_south = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                   bf_op_south = 1'b1;
                                                                               end
                                                                       end
                                                                WEST:  begin
                                                                            if(!west_taken && !bf_inp_west)
                                                                                begin
                                                                                    west_out = in_south;
                                                                                    west_taken = 1'b1;
                                                                                    bf_op_south = 1'b0;
                                                                                end
                                                                            else
                                                                                begin
                                                                                    bf_op_south = 1'b1;
                                                                                end
                                                                        end
                                                                EAST:  begin
                                                                            if(!east_taken && !bf_inp_east)
                                                                                begin
                                                                                    east_out = in_south;
                                                                                    east_taken = 1'b1;
                                                                                    bf_op_south = 1'b0;
                                                                                end
                                                                            else
                                                                                begin
                                                                                    bf_op_south = 1'b1;
                                                                                end
                                                                        end
                                                               LOCAL:  begin
                                                                             if(!local_taken && !bf_inp_local)
                                                                                 begin
                                                                                     local_out = in_south;
                                                                                     local_taken = 1'b1;
                                                                                     bf_op_south = 1'b0;
                                                                                 end
                                                                             else
                                                                                 begin
                                                                                     bf_op_south = 1'b1;
                                                                                 end
                                                                         end 
                                                 endcase
                                                         
                                                 case (east_route)                   
                                                              
                                                              NORTH:  begin
                                                                        if(!north_taken && !bf_inp_north)
                                                                            begin
                                                                                north_out = in_east;
                                                                                north_taken = 1'b1;
                                                                                bf_op_east = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                                bf_op_east = 1'b1;
                                                                            end
                                                                    end
                                                            SOUTH:  begin
                                                                        if(!south_taken && !bf_inp_south)
                                                                            begin
                                                                                south_out = in_east;
                                                                                south_taken = 1'b1;
                                                                                bf_op_east = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                                bf_op_east = 1'b1;
                                                                            end
                                                                    end
                                                             WEST:  begin
                                                                         if(!west_taken && !bf_inp_west)
                                                                             begin
                                                                                 west_out = in_east;
                                                                                 west_taken = 1'b1;
                                                                                 bf_op_east = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                 bf_op_east = 1'b1;
                                                                             end
                                                                     end
                                                             EAST:  begin
                                                                         if(!east_taken && !bf_inp_east)
                                                                             begin
                                                                                 east_out = in_east;
                                                                                 east_taken = 1'b1;
                                                                                 bf_op_east = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                 bf_op_east = 1'b1;
                                                                             end
                                                                     end
                                                            LOCAL:  begin
                                                                           if(!local_taken && !bf_inp_local)
                                                                               begin
                                                                                   local_out = in_east;
                                                                                   local_taken = 1'b1;
                                                                                   bf_op_east = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                   bf_op_east = 1'b1;
                                                                               end
                                                                       end                                                                                                                                        
                                                        endcase
                                                        
                                                        case (west_route)                   
                                                        
                                                            NORTH:  begin
                                                                        if(!north_taken && !bf_inp_north)
                                                                            begin
                                                                                north_out = in_west;
                                                                                north_taken = 1'b1;
                                                                                bf_op_west = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                                bf_op_west = 1'b1;
                                                                            end
                                                                    end
                                                            SOUTH:  begin
                                                                        if(!south_taken && !bf_inp_south)
                                                                            begin
                                                                                south_out = in_west;
                                                                                south_taken = 1'b1;
                                                                                bf_op_west = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                                bf_op_west = 1'b1;
                                                                            end
                                                                    end
                                                             WEST:  begin
                                                                         if(!west_taken && !bf_inp_west)
                                                                             begin
                                                                                 west_out = in_west;
                                                                                 west_taken = 1'b1;
                                                                                 bf_op_west = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                 bf_op_west = 1'b1;
                                                                             end
                                                                     end
                                                             EAST:  begin
                                                                         if(!east_taken && !bf_inp_east)
                                                                             begin
                                                                                 east_out = in_west;
                                                                                 east_taken = 1'b1;
                                                                                 bf_op_west = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                 bf_op_west = 1'b1;
                                                                             end
                                                                     end
                                                            LOCAL:  begin
                                                                           if(!local_taken && !bf_inp_local)
                                                                               begin
                                                                                   local_out = in_west;
                                                                                   local_taken = 1'b1;
                                                                                   bf_op_west = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                   bf_op_west = 1'b1;
                                                                               end
                                                                       end                                                                                                                                        
                                                        endcase
                                                                                   
                      end


               endcase 
               
               if(north_taken==0)
                    north_out =32'b0;
               if(south_taken==0)
                    south_out =32'b0;
               if(east_taken==0)
                    east_out =32'b0;                    
               if(west_taken==0)
                    west_out =32'b0;
               if(local_taken==0)
                    local_out =32'b0;                                                                    
           
           
           end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
                                                                                 
endmodule
