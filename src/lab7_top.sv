`define MREAD 2'b00
`define MNONE 2'b01
`define MWRITE 2'b10

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output reg [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    
    /*
    assign HEX0 = 7'b1111111;
    assign HEX1 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
    */

    wire[8:0] mem_addr;
    reg write;
    reg[15:0] read_data;
    wire [15:0] dout;
    reg msel; 

    reg msel_0;
    reg msel_1;

    wire [1:0]mem_cmd;

    wire [15:0] datapath_out;

    //unused for lab 7  
    wire N, V, Z;

    //switch tri-sate inverter enable 
    reg switch_enable;

    //led load reg enable 
    reg led_load;
    reg [7:0]next_led;

    //instantiate ram module 
    RAM #(16,8) MEM(.clk(~KEY[0]), .read_address(mem_addr[7:0]), .write_address(mem_addr[7:0]), .write(write), .din(datapath_out), .dout(dout) );

    //instantiate cpu module 
    cpu CPU(.clk(KEY[0]),.reset(~KEY[1]),.in(read_data),.out(datapath_out),.N(N),.V(V),.Z(Z), .mdata(read_data), .mem_cmd(mem_cmd), .mem_addr(mem_addr));

    //logic to set write and tri-state inverter enable 
    always @(*)begin 

      //tri-state inverter for RAM block 
      if(mem_addr[8] == 1'b0) 
        msel = 1'b1;
      else
        msel = 1'b0;

      if(mem_cmd == `MREAD)
        msel_0 = 1'b1;
      else 
        msel_0 = 1'b0;

      if((mem_cmd == `MWRITE))
        msel_1 = 1'b1;
      else
        msel_1 = 1'b0;
        
      //write 
      write = msel_1 & msel ? 1'b1 : 1'b0;

      //switch tri state inverter logic 
      if(mem_cmd == `MREAD && mem_addr == 9'h140)
        switch_enable = 1'b1;
      else
        switch_enable = 1'b0;

      if(mem_addr[8] == 1'b0)
        read_data = msel & msel_0 ? dout : {16{1'bz}};
      else 
        read_data = switch_enable ? {8'h00,SW[7:0]} : {16{1'bz}};

      if(mem_cmd == `MWRITE && mem_addr == 9'h100)
        led_load = 1'b1;
      else 
        led_load = 1'b0;
    end

  //led load register 
  assign next_led = led_load ? datapath_out[7:0] : LEDR[7:0];

  always @(posedge ~KEY[0])begin
    LEDR[7:0] = next_led; 
  end
    
  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;
   
  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(datapath_out[3:0],   HEX0);
  sseg H1(datapath_out[7:4],   HEX1);
  sseg H2(datapath_out[11:8],  HEX2);
  sseg H3(datapath_out[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = 1'b0;
endmodule 

//7-segment module 
module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;
  always @(*)begin 

    //This code segment is from our lab5_top code
      case(in)
			4'b0000: segs = 7'b1000000; //0
			4'b0001: segs = 7'b1111001; //1
			4'b0010: segs = 7'b0100100; //2
			4'b0011: segs = 7'b0110000; //3
			4'b0100: segs = 7'b0011001; //4
			4'b0101: segs = 7'b0010010; //5
			4'b0110: segs = 7'b0000010; //6
			4'b0111: segs = 7'b1111000; //7
			4'b1000: segs = 7'b0000000; //8
			4'b1001: segs = 7'b0011000; //9
			4'b1010: segs = 7'b0001000; //A
			4'b1011: segs = 7'b0000011; //B
			4'b1100: segs = 7'b1000111; //C
			4'b1101: segs = 7'b0100001; //D
			4'b1110: segs = 7'b0000110; //E
			4'b1111: segs = 7'b0001110; //F
			default: segs = 7'bxxxxxxx; 

      endcase
  end

endmodule