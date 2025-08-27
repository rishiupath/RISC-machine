module ALU(Ain,Bin,ALUop,out,flag_out); 
    input [15:0] Ain, Bin; 
    input [1:0] ALUop; 
    output reg [15:0] out; 
    output reg [2:0] flag_out; 

    //to check for overflow, save signs of Ain and Bin 
    assign signA = Ain[15];
    assign signB = Bin[15];
    reg signC;

    always @(*)begin 


        //case statement performs one of the four operations based on the ALUop signal
        case(ALUop)
        //Add and Sub with overflow detection uses concepts from Section 10.3 Dally, page 221 and slideset 10 page 19 
            2'b00: out = Ain + Bin;
            2'b01: out = Ain + (~Bin + 1);
            2'b10: out = Ain & Bin;
            2'b11: out = ~Bin;
            default: out = 16'bx;
        endcase 

        //Set flag_out[0] to 1, if all out bits 0 (zero flag). Check out contains a '1' by OR of its bits
        if(|out == 1'b0)
            flag_out[0] = 1'b1;
        else 
            flag_out[0] = 1'b0;

        //Set flag_out[1] to 1, if out is negative (negative flag)
        if(out[15] == 1'b1)
            flag_out[1] = 1'b1;
        else
            flag_out[1] = 1'b0;
    
        //Set flag_out[2] as overflow flag for ADD/SUB, NOT and AND do not require checking 
        //if operation is addition or subtraction

        signC = out[15];

        if (ALUop[1] == 1'b0)begin     
            
            //if input and outputs signs are different, there was an overflow 
            
            //if operation is addition 
            if((signA == signB) && (signA != signC) && (ALUop[0] == 1'b0))
                flag_out[2] = 1'b1;
            //if operation is subtraction 
            else if((signA != signB) && (signA != signC) && (ALUop[0] == 1'b1))
                flag_out[2] = 1'b1;
            else 
                flag_out[2] = 1'b0;
        end
        else 
            //no need to check for overflow 
            flag_out[2] = 1'b0;

            
    end


endmodule