`timescale 1ns / 1ps
////////////////////////////////////////////////////////////
module noc_nxn_tb2();
		 parameter BUS_WIDTH = 32;

	 integer k;
	 integer L;
	reg [BUS_WIDTH-1:0] router_in00;
	reg [BUS_WIDTH-1:0] router_in01;
	reg [BUS_WIDTH-1:0] router_in02;
	reg [BUS_WIDTH-1:0] router_in03;
	reg [BUS_WIDTH-1:0] router_in10;
	reg [BUS_WIDTH-1:0] router_in11;
	reg [BUS_WIDTH-1:0] router_in12;
	reg [BUS_WIDTH-1:0] router_in13;
	reg [BUS_WIDTH-1:0] router_in20;
	reg [BUS_WIDTH-1:0] router_in21;
	reg [BUS_WIDTH-1:0] router_in22;
	reg [BUS_WIDTH-1:0] router_in23;
	reg [BUS_WIDTH-1:0] router_in30;
	reg [BUS_WIDTH-1:0] router_in31;
	reg [BUS_WIDTH-1:0] router_in32;
	reg [BUS_WIDTH-1:0] router_in33;
	reg buffer_in00;
	reg buffer_in01;
	reg buffer_in02;
	reg buffer_in03;
	reg buffer_in10;
	reg buffer_in11;
	reg buffer_in12;
	reg buffer_in13;
	reg buffer_in20;
	reg buffer_in21;
	reg buffer_in22;
	reg buffer_in23;
	reg buffer_in30;
	reg buffer_in31;
	reg buffer_in32;
	reg buffer_in33;
	wire buffer_out00;
	wire buffer_out01;
	wire buffer_out02;
	wire buffer_out03;
	wire buffer_out10;
	wire buffer_out11;
	wire buffer_out12;
	wire buffer_out13;
	wire buffer_out20;
	wire buffer_out21;
	wire buffer_out22;
	wire buffer_out23;
	wire buffer_out30;
	wire buffer_out31;
	wire buffer_out32;
	wire buffer_out33;
	reg clk1;
	reg clk2;
	reg rst;
	wire [BUS_WIDTH-1:0] router_out00;
	wire [BUS_WIDTH-1:0] router_out01;
	wire [BUS_WIDTH-1:0] router_out02;
	wire [BUS_WIDTH-1:0] router_out03;
	wire [BUS_WIDTH-1:0] router_out10;
	wire [BUS_WIDTH-1:0] router_out11;
	wire [BUS_WIDTH-1:0] router_out12;
	wire [BUS_WIDTH-1:0] router_out13;
	wire [BUS_WIDTH-1:0] router_out20;
	wire [BUS_WIDTH-1:0] router_out21;
	wire [BUS_WIDTH-1:0] router_out22;
	wire [BUS_WIDTH-1:0] router_out23;
	wire [BUS_WIDTH-1:0] router_out30;
	wire [BUS_WIDTH-1:0] router_out31;
	wire [BUS_WIDTH-1:0] router_out32;
	wire [BUS_WIDTH-1:0] router_out33;


noc_nxn uut(
	.router_in00(router_in00),
	.router_in01(router_in01),
	.router_in02(router_in02),
	.router_in03(router_in03),
	.router_in10(router_in10),
	.router_in11(router_in11),
	.router_in12(router_in12),
	.router_in13(router_in13),
	.router_in20(router_in20),
	.router_in21(router_in21),
	.router_in22(router_in22),
	.router_in23(router_in23),
	.router_in30(router_in30),
	.router_in31(router_in31),
	.router_in32(router_in32),
	.router_in33(router_in33),
	.buffer_in00(buffer_in00),
	.buffer_in01(buffer_in01),
	.buffer_in02(buffer_in02),
	.buffer_in03(buffer_in03),
	.buffer_in10(buffer_in10),
	.buffer_in11(buffer_in11),
	.buffer_in12(buffer_in12),
	.buffer_in13(buffer_in13),
	.buffer_in20(buffer_in20),
	.buffer_in21(buffer_in21),
	.buffer_in22(buffer_in22),
	.buffer_in23(buffer_in23),
	.buffer_in30(buffer_in30),
	.buffer_in31(buffer_in31),
	.buffer_in32(buffer_in32),
	.buffer_in33(buffer_in33),
	.buffer_out00(buffer_out00),
	.buffer_out01(buffer_out01),
	.buffer_out02(buffer_out02),
	.buffer_out03(buffer_out03),
	.buffer_out10(buffer_out10),
	.buffer_out11(buffer_out11),
	.buffer_out12(buffer_out12),
	.buffer_out13(buffer_out13),
	.buffer_out20(buffer_out20),
	.buffer_out21(buffer_out21),
	.buffer_out22(buffer_out22),
	.buffer_out23(buffer_out23),
	.buffer_out30(buffer_out30),
	.buffer_out31(buffer_out31),
	.buffer_out32(buffer_out32),
	.buffer_out33(buffer_out33),
	.clk1(clk1),
	.clk2(clk2),
	.rst(rst),
	.router_out00(router_out00),
	.router_out01(router_out01),
	.router_out02(router_out02),
	.router_out03(router_out03),
	.router_out10(router_out10),
	.router_out11(router_out11),
	.router_out12(router_out12),
	.router_out13(router_out13),
	.router_out20(router_out20),
	.router_out21(router_out21),
	.router_out22(router_out22),
	.router_out23(router_out23),
	.router_out30(router_out30),
	.router_out31(router_out31),
	.router_out32(router_out32),
	.router_out33(router_out33)
);

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
		rst = 1'b1;
		buffer_in00 = 1'b0;
		buffer_in01 = 1'b0;
		buffer_in02 = 1'b0;
		buffer_in03 = 1'b0;
		buffer_in10 = 1'b0;
		buffer_in11 = 1'b0;
		buffer_in12 = 1'b0;
		buffer_in13 = 1'b0;
		buffer_in20 = 1'b0;
		buffer_in21 = 1'b0;
		buffer_in22 = 1'b0;
		buffer_in23 = 1'b0;
		buffer_in30 = 1'b0;
		buffer_in31 = 1'b0;
		buffer_in32 = 1'b0;
		buffer_in33 = 1'b0;
		#10;
				if(!buffer_out00)
					router_in00= 32'h0;
				if(!buffer_out01)
					router_in01= 32'h0;
				if(!buffer_out02)
					router_in02= 32'h0;
				if(!buffer_out03)
					router_in03= 32'h0;
				if(!buffer_out10)
					router_in10= 32'h0;
				if(!buffer_out11)
					router_in11= 32'h0;
				if(!buffer_out12)
					router_in12= 32'h0;
				if(!buffer_out13)
					router_in13= 32'h0;
				if(!buffer_out20)
					router_in20= 32'h0;
				if(!buffer_out21)
					router_in21= 32'h0;
				if(!buffer_out22)
					router_in22= 32'h0;
				if(!buffer_out23)
					router_in23= 32'h0;
				if(!buffer_out30)
					router_in30= 32'h0;
				if(!buffer_out31)
					router_in31= 32'h0;
				if(!buffer_out32)
					router_in32= 32'h0;
				if(!buffer_out33)
					router_in33= 32'h0;
				#10;
		rst = 1'b0;
		#18;
		rst = 1'b1;
		#10;
		rst = 1'b0;
		#10;
			k = 0;
			L = 0;
			repeat(18)
			begin
				if(!buffer_out00)
				begin
					k = k + 1;
					router_in00=$random;
				end
				if(!buffer_out01)
				begin
					k = k + 1;
					router_in01=$random;
				end
				if(!buffer_out02)
				begin
					k = k + 1;
					router_in02=$random;
				end
				if(!buffer_out03)
				begin
					k = k + 1;
					router_in03=$random;
				end
				if(!buffer_out10)
				begin
					k = k + 1;
					router_in10=$random;
				end
				if(!buffer_out11)
				begin
					k = k + 1;
					router_in11=$random;
				end
				if(!buffer_out12)
				begin
					k = k + 1;
					router_in12=$random;
				end
				if(!buffer_out13)
				begin
					k = k + 1;
					router_in13=$random;
				end
				if(!buffer_out20)
				begin
					k = k + 1;
					router_in20=$random;
				end
				if(!buffer_out21)
				begin
					k = k + 1;
					router_in21=$random;
				end
				if(!buffer_out22)
				begin
					k = k + 1;
					router_in22=$random;
				end
				if(!buffer_out23)
				begin
					k = k + 1;
					router_in23=$random;
				end
				if(!buffer_out30)
				begin
					k = k + 1;
					router_in30=$random;
				end
				if(!buffer_out31)
				begin
					k = k + 1;
					router_in31=$random;
				end
				if(!buffer_out32)
				begin
					k = k + 1;
					router_in32=$random;
				end
				if(!buffer_out33)
				begin
					k = k + 1;
					router_in33=$random;
				end
				#20;
			end
			#5;
			forever
			begin
				if(!buffer_out00)
				router_in00 = 32'b0;
				if(!buffer_out01)
				router_in01 = 32'b0;
				if(!buffer_out02)
				router_in02 = 32'b0;
				if(!buffer_out03)
				router_in03 = 32'b0;
				if(!buffer_out10)
				router_in10 = 32'b0;
				if(!buffer_out11)
				router_in11 = 32'b0;
				if(!buffer_out12)
				router_in12 = 32'b0;
				if(!buffer_out13)
				router_in13 = 32'b0;
				if(!buffer_out20)
				router_in20 = 32'b0;
				if(!buffer_out21)
				router_in21 = 32'b0;
				if(!buffer_out22)
				router_in22 = 32'b0;
				if(!buffer_out23)
				router_in23 = 32'b0;
				if(!buffer_out30)
				router_in30 = 32'b0;
				if(!buffer_out31)
				router_in31 = 32'b0;
				if(!buffer_out32)
				router_in32 = 32'b0;
				if(!buffer_out33)
				router_in33 = 32'b0;
				#20;
			end
		end
always @ (posedge clk2)
    begin
			if(!(router_out00===32'b0))
					L = L + 1;
				if(!(router_out01===32'b0))
					L = L + 1;
				if(!(router_out02===32'b0))
					L = L + 1;
				if(!(router_out03===32'b0))
					L = L + 1;
				if(!(router_out10===32'b0))
					L = L + 1;
				if(!(router_out11===32'b0))
					L = L + 1;
				if(!(router_out12===32'b0))
					L = L + 1;
				if(!(router_out13===32'b0))
					L = L + 1;
				if(!(router_out20===32'b0))
					L = L + 1;
				if(!(router_out21===32'b0))
					L = L + 1;
				if(!(router_out22===32'b0))
					L = L + 1;
				if(!(router_out23===32'b0))
					L = L + 1;
				if(!(router_out30===32'b0))
					L = L + 1;
				if(!(router_out31===32'b0))
					L = L + 1;
				if(!(router_out32===32'b0))
					L = L + 1;
				if(!(router_out33===32'b0))
					L = L + 1;
		end
 initial
            begin
                #1000;
                $finish;
            end
            endmodule