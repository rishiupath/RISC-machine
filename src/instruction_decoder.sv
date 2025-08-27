module instruction_decoder(instruction, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    input [15:0] instruction;
    input [1:0] nsel; 
    output [2:0] opcode;
    output [1:0] op;
    output [1:0] ALUop;
    output [15:0] sximm5, sximm8; // goes to data path
    output [1:0] shift;
    output reg [2:0] readnum, writenum;

    wire [2:0] Rm;
    wire [2:0] Rd;
    wire [2:0] Rn;

    //Rn
    assign Rn = instruction[10:8];

    //Rd
    assign Rd = instruction[7:5];

    //Rm
    assign Rm = instruction[2:0];


    //ALUop encoding to select operation
    assign ALUop = instruction[12:11];

    //sign extended lower 5 bits of instruction
    assign sximm5 = instruction[4] ? {11'b11111111111,instruction[4:0]} : {11'b00000000000, instruction[4:0]};

    //sign extended lower 8 bits of instruction 
    assign sximm8 = instruction[7] ? {8'b11111111,instruction[7:0]} : {8'b00000000, instruction[7:0]};

    //shift encoding to select operation 
    assign shift = instruction[4:3];

    //opcode 
    assign opcode = instruction[15:13];
    
    //op
    assign op = instruction[12:11];

    always @(*)begin 

        case(nsel)
            2'b00: begin 
                    readnum = Rm;
                    writenum = Rm;
                end
            2'b01: begin
                    readnum = Rd;
                    writenum = Rd;
            end
            2'b11: begin 
                    readnum = Rn;
                    writenum = Rn;
                end
            default: begin
                    readnum = 3'bx;
                    writenum = 3'bx;
            end
        endcase 
    end
endmodule 