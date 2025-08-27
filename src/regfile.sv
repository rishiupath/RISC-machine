module regfile(data_in,writenum,write,readnum,clk,data_out);
	input [15:0] data_in;
	input [2:0] writenum, readnum;
	input write, clk;
	output reg [15:0] data_out;
    wire [7:0] n1;      // one hot select to choose register to write to
    wire [7:0] n2;      // readnum 8 bit one hot select
    wire [7:0] n3;      // anded value of one hot select with write
    //Register ouputs
    wire [15:0] R0;
    wire [15:0] R1;
    wire [15:0] R2;
    wire [15:0] R3;
    wire [15:0] R4;
    wire [15:0] R5;
    wire [15:0] R6;
    wire [15:0] R7;

    //Instantitate the decoder module for c
    decoder decoderW(writenum, n1);
    
    //set all n1 bits(load) to 0 if write is 0 
    assign n3 = write ? n1 : 8'b00000000;

    //instantiate registers 
    regLE reg0(data_in, n3[0], clk, R0); 
    
    regLE reg1(data_in, n3[1], clk, R1);

    regLE reg2(data_in, n3[2], clk, R2);

    regLE reg3(data_in, n3[3], clk, R3);

    regLE reg4(data_in, n3[4], clk, R4);

    regLE reg5(data_in, n3[5], clk, R5);

    regLE reg6(data_in, n3[6], clk, R6);

    regLE reg7(data_in, n3[7], clk, R7);

    //Instantitate decoder for reading stage 
    decoder decoderR(readnum, n2);

    //Case statements to select which register to read from 
    always @(n2, R0, R1, R2, R3, R4, R5, R6, R7)begin 

        case(n2)
            
            8'b00000001: data_out = R0;
            8'b00000010: data_out = R1;
            8'b00000100: data_out = R2;
            8'b00001000: data_out = R3;
            8'b00010000: data_out = R4;
            8'b00100000: data_out = R5;
            8'b01000000: data_out = R6;
            8'b10000000: data_out = R7;
            default: data_out = 16'bx;
        endcase 

        end
endmodule

//3:8 decoder module, includes code from Slideset 6, page 86 
module decoder(in, out);
    input [2:0]in;
    output [7:0] out;

    wire [7:0] out = 1 << in;

endmodule

//register module: can either store new data or maintain previous value depending on load.
module regLE (in, load, clk, out);
    input [15:0]in;
    input load, clk;
    output reg [15:0] out;
    wire [15:0] next_out;

    //sets next output to either be a new input or the previous value
    assign next_out =  load ? in : out;

    // updates the value on rising edge of clock
    always_ff @(posedge clk) begin 
        out = next_out;
    end
endmodule
