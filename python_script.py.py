import math

# Open the file in write mode
file_path = "C:/Users/FutureSystems-4/imc_router/imc_router.srcs/sources_1/new/noc_nxn.v"
file = open(file_path, "w")

# Write to the file
file.write("`timescale 1ns / 1ps\n")
file.write("////////////////////////////////////////////////////////////\n")
file.write("module noc_nxn #(parameter BUS_WIDTH = 32)")

file.write("\n(\n")
noc_size=int(input("enter the size of network : "))

addr_width = math.ceil(math.log2(noc_size))

for i in range (noc_size):
    for j in range (noc_size):
        file.write("\tinput [BUS_WIDTH-1:0] router_in")
        file.write(str(i)+str(j)+",\n")

        
for i in range (noc_size):
    for j in range (noc_size):
        file.write("\tinput buffer_in")
        file.write(str(i)+str(j)+",\n")


for i in range (noc_size):
    for j in range (noc_size):
        file.write("\toutput buffer_out")
        file.write(str(i)+str(j)+",\n")
file.write("\tinput clk1,\n")
file.write("\tinput clk2,\n")
file.write("\tinput rst,\n")
               

for i in range (noc_size):
    for j in range (noc_size):
        file.write("\toutput [BUS_WIDTH-1:0] router_out")
        file.write(str(i)+str(j))
        if(i==(noc_size-1) and j==(noc_size-1)):
            file.write("\n")
        else:
            file.write(",\n")
file.write(");\n\n")


for i in range (noc_size +1):
    for j in range (noc_size):
        file.write("\twire [BUS_WIDTH-1:0] int1_")
        file.write("NS"+str(j)+str(i)+";\n")
        file.write("\twire [BUS_WIDTH-1:0] int2_")
        file.write("NS"+str(j)+str(i)+";\n")
        file.write("\twire bf1_")
        file.write("NS"+str(j)+str(i)+";\n")
        file.write("\twire bf2_")
        file.write("NS"+str(j)+str(i)+";\n")

for j in range (noc_size +1):
    for i in range (noc_size):
        file.write("\twire [BUS_WIDTH-1:0] int1_")
        file.write("WE"+str(j)+str(i)+";\n")
        file.write("\twire [BUS_WIDTH-1:0] int2_")
        file.write("WE"+str(j)+str(i)+";\n")
        file.write("\twire bf1_")
        file.write("WE"+str(j)+str(i)+";\n")
        file.write("\twire bf2_")
        file.write("WE"+str(j)+str(i)+";\n")


file.write("\n")

for i in range (noc_size):
    for j in range (noc_size):
        if(((j%2==0)and(i%2==1))or((j%2==1)and(i%2==0))):
            k=1
            l=2
        else:
            k=2
            l=1
        file.write("router #(.LOC_Y("+str(addr_width)+"'d"+str(i)+"),.LOC_X("+str(addr_width)+"'d"+str(j)+"),.NOC_SIZE("+str(noc_size)+")) inst"+str(i)+str(j)+"\n")
        file.write("\t(.north_in (int"+str(k)+"_NS"+str(j)+str(i)+"),\n")
        file.write("\t.south_in (int"+str(k)+"_NS"+str(j)+str(i+1)+"),\n")
        file.write("\t.east_in (int"+str(k)+"_WE"+str(i)+str(j+1)+"),\n")
        file.write("\t.west_in (int"+str(k)+"_WE"+str(i)+str(j)+"),\n")
        file.write("\t.local_in (router_in"+str(i)+str(j)+"),\n")
        file.write("\t.bf_inp_north (bf"+str(k)+"_NS"+str(j)+str(i)+"),\n")
        file.write("\t.bf_inp_south (bf"+str(k)+"_NS"+str(j)+str(i+1)+"),\n")
        file.write("\t.bf_inp_east (bf"+str(k)+"_WE"+str(i)+str(j+1)+"),\n")
        file.write("\t.bf_inp_west (bf"+str(k)+"_WE"+str(i)+str(j)+"),\n")
        file.write("\t.bf_inp_local (buffer_in"+str(i)+str(j)+"),\n")
        file.write("\t.bf_op_north (bf"+str(l)+"_NS"+str(j)+str(i)+"),\n")
        file.write("\t.bf_op_south (bf"+str(l)+"_NS"+str(j)+str(i+1)+"),\n")
        file.write("\t.bf_op_east (bf"+str(l)+"_WE"+str(i)+str(j+1)+"),\n")
        file.write("\t.bf_op_west (bf"+str(l)+"_WE"+str(i)+str(j)+"),\n")
        file.write("\t.bf_op_local (buffer_out"+str(i)+str(j)+"),\n")
        file.write("\t.north_out (int"+str(l)+"_NS"+str(j)+str(i)+"),\n")
        file.write("\t.south_out (int"+str(l)+"_NS"+str(j)+str(i+1)+"),\n")
        file.write("\t.east_out (int"+str(l)+"_WE"+str(i)+str(j+1)+"),\n")
        file.write("\t.west_out (int"+str(l)+"_WE"+str(i)+str(j)+"),\n")
        file.write("\t.local_out (router_out"+str(i)+str(j)+"),\n")
        file.write("\t.clk1 (clk1),\n")
        file.write("\t.clk2 (clk2),\n")
        file.write("\t.rst (rst));\n\n")
        



file.write("endmodule")

file.close()


# testbench

file_path2 = "C:/Users/FutureSystems-4/imc_router/imc_router.srcs/sim_1/new/noc_nxn_tb.v"
testbench = open(file_path2, "w")

testbench.write("`timescale 1ns / 1ps\n")
testbench.write("////////////////////////////////////////////////////////////\n")
testbench.write("module noc_nxn_tb();\n\t\t parameter BUS_WIDTH = 32;")

testbench.write("\n")

for i in range (noc_size):
    for j in range (noc_size):
        testbench.write("\treg [BUS_WIDTH-1:0] router_in")
        testbench.write(str(i)+str(j)+";\n")

        
for i in range (noc_size):
    for j in range (noc_size):
        testbench.write("\treg buffer_in")
        testbench.write(str(i)+str(j)+";\n")


for i in range (noc_size):
    for j in range (noc_size):
        testbench.write("\twire buffer_out")
        testbench.write(str(i)+str(j)+";\n")
testbench.write("\treg clk1;\n")
testbench.write("\treg clk2;\n")
testbench.write("\treg rst;\n")                  

for i in range (noc_size):
    for j in range (noc_size):
        testbench.write("\twire [BUS_WIDTH-1:0] router_out")
        testbench.write(str(i)+str(j)+";\n")

testbench.write("\n\n")       
testbench.write("noc_nxn uut(\n")

for i in range (noc_size):
    for j in range (noc_size):
        testbench.write("\t.router_in")
        testbench.write(str(i)+str(j)+"(")
        testbench.write("router_in")
        testbench.write(str(i)+str(j)+"),\n")        
for i in range (noc_size):
    for j in range (noc_size):
        testbench.write("\t.buffer_in")
        testbench.write(str(i)+str(j)+"(")
        testbench.write("buffer_in")
        testbench.write(str(i)+str(j)+"),\n")        
for i in range (noc_size):
    for j in range (noc_size):
        testbench.write("\t.buffer_out")
        testbench.write(str(i)+str(j)+"(")
        testbench.write("buffer_out")
        testbench.write(str(i)+str(j)+"),\n")
testbench.write("\t.clk1(clk1),\n")
testbench.write("\t.clk2(clk2),\n")
testbench.write("\t.rst(rst),\n")
for i in range (noc_size):
    for j in range (noc_size):
        testbench.write("\t.router_out")
        testbench.write(str(i)+str(j)+"(")
        testbench.write("router_out")
        testbench.write(str(i)+str(j)+")")
        if(i==(noc_size-1) and j==(noc_size-1)):
            testbench.write("\n")
        else:
            testbench.write(",\n")
testbench.write(");\n\n")
testbench.write("""        initial 
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
""")

testbench.write("\tinitial\n")
testbench.write("\tbegin\n\t")

testbench.write("\trst = 1'b1;\n\t")
for i in range (noc_size):
    for j in range (noc_size):
        testbench.write("\tbuffer_in")
        testbench.write(str(i)+str(j)+" = 1'b0;\n\t")
        
testbench.write("\t#10;\n\t")
for i in range (noc_size):
    for j in range(noc_size):
        testbench.write("\t\t\tif(!buffer_out"+str(i)+str(j)+")\n\t")
        testbench.write("\t\t\t\trouter_in"+str(i)+str(j)+"= 32'h0;\n\t")
testbench.write("\t\t\t#10;\n\t")

testbench.write("\trst = 1'b0;\n\t")
testbench.write("\t#28;\n\t")
testbench.write("\t\tforever\n\t")
testbench.write("\t\tbegin\n\t")

for i in range (noc_size):
    for j in range(noc_size):
        testbench.write("\t\t\tif(!buffer_out"+str(i)+str(j)+")\n\t")
        testbench.write("\t\t\t\trouter_in"+str(i)+str(j)+"=$random;\n\t")
testbench.write("\t\t\t#20;\n\t")
        



testbench.write("\t\tend\n\t")
testbench.write("\tend\n")
testbench.write(""" initial
            begin
                #1000;
                $finish;
            end
            """)

testbench.write("endmodule")
    

testbench.close()

file_path3 = "C:/Users/FutureSystems-4/imc_router/imc_router.srcs/sim_1/new/noc_nxn_tb2.v"
testbench1 = open(file_path3, "w")

testbench1.write("`timescale 1ns / 1ps\n")
testbench1.write("////////////////////////////////////////////////////////////\n")
testbench1.write("module noc_nxn_tb2();\n\t\t parameter BUS_WIDTH = 32;")

testbench1.write("\n")
testbench1.write("\n\t integer k;")
testbench1.write("\n\t integer L;\n")
for i in range (noc_size):
    for j in range (noc_size):
        testbench1.write("\treg [BUS_WIDTH-1:0] router_in")
        testbench1.write(str(i)+str(j)+";\n")

        
for i in range (noc_size):
    for j in range (noc_size):
        testbench1.write("\treg buffer_in")
        testbench1.write(str(i)+str(j)+";\n")


for i in range (noc_size):
    for j in range (noc_size):
        testbench1.write("\twire buffer_out")
        testbench1.write(str(i)+str(j)+";\n")
testbench1.write("\treg clk1;\n")
testbench1.write("\treg clk2;\n")
testbench1.write("\treg rst;\n")                  

for i in range (noc_size):
    for j in range (noc_size):
        testbench1.write("\twire [BUS_WIDTH-1:0] router_out")
        testbench1.write(str(i)+str(j)+";\n")

testbench1.write("\n\n")       
testbench1.write("noc_nxn uut(\n")

for i in range (noc_size):
    for j in range (noc_size):
        testbench1.write("\t.router_in")
        testbench1.write(str(i)+str(j)+"(")
        testbench1.write("router_in")
        testbench1.write(str(i)+str(j)+"),\n")        
for i in range (noc_size):
    for j in range (noc_size):
        testbench1.write("\t.buffer_in")
        testbench1.write(str(i)+str(j)+"(")
        testbench1.write("buffer_in")
        testbench1.write(str(i)+str(j)+"),\n")        
for i in range (noc_size):
    for j in range (noc_size):
        testbench1.write("\t.buffer_out")
        testbench1.write(str(i)+str(j)+"(")
        testbench1.write("buffer_out")
        testbench1.write(str(i)+str(j)+"),\n")
testbench1.write("\t.clk1(clk1),\n")
testbench1.write("\t.clk2(clk2),\n")
testbench1.write("\t.rst(rst),\n")
for i in range (noc_size):
    for j in range (noc_size):
        testbench1.write("\t.router_out")
        testbench1.write(str(i)+str(j)+"(")
        testbench1.write("router_out")
        testbench1.write(str(i)+str(j)+")")
        if(i==(noc_size-1) and j==(noc_size-1)):
            testbench1.write("\n")
        else:
            testbench1.write(",\n")
testbench1.write(");\n\n")
testbench1.write("""        initial 
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
""")

testbench1.write("\tinitial\n")
testbench1.write("\tbegin\n\t")

testbench1.write("\trst = 1'b1;\n\t")
for i in range (noc_size):
    for j in range (noc_size):
        testbench1.write("\tbuffer_in")
        testbench1.write(str(i)+str(j)+" = 1'b0;\n\t")
        
testbench1.write("\t#10;\n\t")
for i in range (noc_size):
    for j in range(noc_size):
        testbench1.write("\t\t\tif(!buffer_out"+str(i)+str(j)+")\n\t")
        testbench1.write("\t\t\t\trouter_in"+str(i)+str(j)+"= 32'h0;\n\t")
testbench1.write("\t\t\t#10;\n\t")
cycle = int(input("enter the number of simulation cycle : "))
testbench1.write("\trst = 1'b0;\n\t")
testbench1.write("\t#18;\n\t")
testbench1.write("\trst = 1'b1;\n\t")
testbench1.write("\t#10;\n\t")
testbench1.write("\trst = 1'b0;\n\t")
testbench1.write("\t#10;\n\t")
testbench1.write("\t\tk = 0;\n\t")
testbench1.write("\t\tL = 0;\n\t")
testbench1.write("\t\trepeat("+str(cycle)+")\n\t")
testbench1.write("\t\tbegin\n\t")

for i in range (noc_size):
    for j in range(noc_size):
        testbench1.write("\t\t\tif(!buffer_out"+str(i)+str(j)+")\n\t")
        testbench1.write("\t\t\tbegin\n\t")
        testbench1.write("\t\t\t\tk = k + 1;\n\t")
        testbench1.write("\t\t\t\trouter_in"+str(i)+str(j)+"=$random;\n\t")
        testbench1.write("\t\t\tend\n\t")
testbench1.write("\t\t\t#20;\n\t")
       
testbench1.write("\t\tend\n\t")
testbench1.write("\t\t#5;\n\t")
testbench1.write("\t\tforever\n\t")
testbench1.write("\t\tbegin\n\t")

for i in range (noc_size):
    for j in range(noc_size):
        testbench1.write("\t\t\tif(!buffer_out"+str(i)+str(j)+")\n\t")
        testbench1.write("\t\t\trouter_in"+str(i)+str(j)+" = 32'b0;\n\t")
testbench1.write("\t\t\t#20;\n\t")

testbench1.write("\t\tend\n\t")
testbench1.write("\tend\n")

testbench1.write("""always @ (posedge clk2)
    begin
""")
for i in range (noc_size):
    for j in range(noc_size):
        testbench1.write("\t\t\tif(!(router_out"+str(i)+str(j)+"===32'b0))\n\t")
        testbench1.write("\t\t\t\tL = L + 1;\n\t")
testbench1.write("\tend\n")

        
testbench1.write(""" initial
            begin
                #1000;
                $finish;
            end
            """)

testbench1.write("endmodule")
    

testbench1.close()


print("File has been written successfully.")
