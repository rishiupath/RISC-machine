module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, flag_out_f, datapath_out, mdata, PC, sximm8, sximm5);
    input clk, write;
    input reg [2:0]readnum;
    input [1:0] vsel;
    input loada, loadb, loads, loadc, asel, bsel;
    input [1:0] shift;
    input [1:0] ALUop;
    input [2:0] writenum;
    output reg [2:0] flag_out_f;
    output [15:0] datapath_out;

    input [15:0] mdata;
    input [8:0] PC;
    input [15:0] sximm8;
    input [15:0] sximm5;
    
    //connection between vsel mux and regfile 
    reg [15:0]data_in;

    //connection between regfile and loada or loadb
    wire [15:0] data_out;

    //conneciton between loada and asel
    wire [15:0] wire1;

    //conneciton between loadb and shifter 
    wire [15:0] wire2;

    //connection between shifter and bsel
    wire [15:0] sout;

    //connection between asel and ALU 
    wire [15:0] Ain;

    //connection between bsel and ALU 
    wire [15:0] Bin;

    //connection between ALU and loadc 
    wire [15:0] out;

    //connection between ALU and loads 
    wire [2:0] flag_out;

    //temporary wire for s register
    wire [2:0] next_flag_out;


    //vsel mux 
    always @(*)begin
        case(vsel)
            2'b00: data_in = datapath_out;
            2'b01: data_in = {7'b0,PC}; //PC
            2'b11: data_in = sximm8;
            2'b10: data_in = mdata; //mdata
            default: data_in = 16'bx;
        endcase
    end

    //Instantiate regfile
    regfile REGFILE(data_in,writenum,write,readnum,clk,data_out);


    //instantiate 2 load regs, A and B 

    regLE regA (data_out, loada, clk, wire1);

    regLE regB (data_out, loadb, clk, wire2);

    

    //instantiate shifter 

    shifter SHIFT(wire2, shift, sout);

    //two binary select muxes, asel and bsel 

    assign Ain = asel ? 16'b0 : wire1;
    assign Bin = bsel ? sximm5 : sout;

    
    //instantiate ALU
    
    ALU alu(Ain, Bin, ALUop, out, flag_out);

    //loads load register 
    
    assign next_flag_out =  loads ? flag_out : flag_out_f;

    always_ff @(posedge clk) begin 
        flag_out_f = next_flag_out;

    end

    //loadc load register    
    regLE regC (out, loadc, clk, datapath_out);

endmodule 