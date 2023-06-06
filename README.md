# 5-Port Router For Network-On-Chip

This markdown file provides an overview of a 5-Port router  design implemented in Verilog for NoC (Network-On–Chip) or NoP (Network-On–Packet). The router is responsible for handling communication between processing elements in the network.

## Router Architecture
The 5-Port router consists of the following main components:
1. **Input Ports:** There are 5 input ports of width 32 to receive flits from 5 directions, neighbouring and local (*North_in, South_in, East_in, West_in, Local_in*) processing elements. Each input has a 32 bit buffer to store the input. Also there a five acknowledgement input from adjacent router (*bf_inp_north, bf_inp_south, bf_inp_west, bf_inp_east, bf_inp_local*) give information about whether it can sent flit to next router or not.
2. **Output Port:** Just like the input, there are 5 32 wide output to sent flits to its location (*North_out, South_out, East_out, West_out, Local_out*) and also 5 acknowledgement output too(*bf_out_north, bf_out_south, bf_out_west, bf_out_east, bf_out_local*) 
3. **Routing Logic:** The routing logic will determine the output port to which an incoming flit should be assigned. This router follows the YX routing algorithm. When a flit enters a router, it checks the Y index or the destination column first, if it matches then the X index.
