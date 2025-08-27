module cpu(clk,reset,in,out,N,V,Z, mdata, mem_cmd, mem_addr);
    input clk, reset;
    input [15:0] mdata;
    input [15:0] in; output [15:0] out;
    output N, V, Z;
    output [1:0] mem_cmd;
    output [8:0] mem_addr;

    //wire from instruction register to instruction decoder 
    wire [15:0] regToDec;

    //nsel wire from fsm to decoder 
    wire [1:0] nsel;

    //opcode wire from decoder to fsm 
    wire [2:0] opcode;

    //op wire from decoder to fsm 
    wire [1:0] op;

    //ALUop wire from decoder to datapath
    wire [1:0] ALUop;

    //sximm5 wire from decoder to datapath
    wire [15:0] sximm5;

    //sximm8 wire from decoder to datapath 
    wire [15:0] sximm8;

    //readnum wire from decoder to datapath
    wire [2:0] readnum;

    //writenum wire from decoder to datapath
    wire [2:0] writenum;

    //shift wire from decoder to datapath
    wire [1:0] shift;

    //write wire from FSM to datapath
    wire write;

    //flag out wire from datapath to CPU output
    wire [2:0] flag_out_f;

    //wire from FSM to datapath
    wire [1:0] vsel;

    //wires from FSM to datapath 
    wire loada;
    wire loadb;
    wire asel;
    wire bsel;
    wire loadc;
    wire loads;

    //wire from state machine to pc 
    wire reset_pc;

    //wire from pc to addr_sel mux 
    wire [8:0] PC;

    //wire from state machine to addr_sel 
    wire addr_sel;

    //wire from statemachine to intruction reg 
    wire load_ir;

    wire load_pc;

    wire load_addr;

    wire [8:0]next_data_addr;
    
    reg [8:0] data_addr_out;

    //instruction register 
    regLE instructionReg(.in(in), .load(load_ir) , .clk(clk), .out(regToDec));

    //instantiate instruction decoder 
    instruction_decoder DUT_insDecoder(.instruction(regToDec), .nsel(nsel), .opcode(opcode), .op(op), .ALUop(ALUop), .sximm5(sximm5), .sximm8(sximm8), .shift(shift), .readnum(readnum), .writenum(writenum));

    //instantiate datapath
    datapath DP(.clk(clk), .readnum(readnum), .vsel(vsel), .loada(loada), .loadb(loadb), .shift(shift), .asel(asel), .bsel(bsel), .ALUop(ALUop), .loadc(loadc), .loads(loads), .writenum(writenum), .write(write), .flag_out_f(flag_out_f), .datapath_out(out), .mdata(mdata), .PC(PC), .sximm8(sximm8), .sximm5(sximm5));

    //instantiate state machine
    state_machine DUT_fsm(.reset(reset), .opcode(opcode), .op(op), .clk(clk), .nsel(nsel), .write(write), .vsel(vsel), .loada(loada), .loadb(loadb), .asel(asel), .bsel(bsel), .loadc(loadc), .loads(loads), .load_ir(load_ir), .reset_pc(reset_pc), .load_pc(load_pc), .addr_sel(addr_sel), .load_addr(load_addr), .mem_cmd(mem_cmd));

    //program counter 
    Counter dut_pc(.clk(clk), .rst(reset_pc), .count(PC), .load_pc(load_pc));

    //addr_sel mux
    assign mem_addr = addr_sel ? PC : data_addr_out; 


    // assign output flags from datapath
    assign Z = flag_out_f[0];
    assign N = flag_out_f[1];
    assign V = flag_out_f[2];


    assign next_data_addr = out[8:0];
    always @(posedge clk)begin
        
        if(load_addr)
            data_addr_out = next_data_addr;
        else 
            data_addr_out = data_addr_out;

    end
    

endmodule

//from slideset 11 
module Counter(clk, rst, count, load_pc);
    input rst, clk, load_pc; // reset and clock
    output reg [8:0] count;

    wire [8:0]next_pc_1;
    wire [8:0]next_pc_2;
    assign next_pc_1 = rst ? 9'b0 : count + 1;

    assign next_pc_2 = load_pc ? next_pc_1 : count;

    always@(posedge clk)begin 
        count = next_pc_2;
    end 
endmodule
