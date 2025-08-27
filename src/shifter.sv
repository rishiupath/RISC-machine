module shifter(in,shift,sout); 
    input [15:0] in; 
    input [1:0] shift; 
    output reg [15:0] sout; 
    reg temp; //temp reg for MSB copying 



    always@(*)begin 

        // case statement performs each shift operation based on the shift signal encoding
        case(shift)
            2'b00: sout = in;
            2'b01: sout = in << 1'b1;
            2'b10: sout =  in >> 1'b1;
            2'b11: sout = {in[15], in[15:1]};
            default: sout = 16'bx;
        endcase

    end
endmodule