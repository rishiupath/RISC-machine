//Starting states
`define RST 5'b00000
`define decoder 5'b00001

//MOV Rn, #<im8>
`define mov_int 5'b00010

//ADD Rd, Rn, Rm{,<sh_op>}
`define getA 5'b00011
`define getB 5'b00100 
`define computation 5'b00101 
`define computation_BO 5'b00111
`define write_Rd 5'b01000

//new lab7 states 
`define IF1 5'b01001
`define IF2 5'b01010
`define UpdatePC 5'b01011
`define MREAD 2'b00
`define MNONE 2'b01
`define MWRITE 2'b10

`define LDR1 5'b00110
`define LDR2 5'b01100
`define LDR3 5'b01101
`define LDR4 5'b01110

`define STR1 5'b10001
`define STR2 5'b01111

`define HALT 5'b10000



module state_machine (reset, opcode, op, clk, nsel, write, vsel, loada, loadb, asel, bsel, loadc, loads, load_ir, reset_pc, load_pc, addr_sel, load_addr, mem_cmd);
    input reset;
    input [2:0] opcode;
    input [1:0] op;
    input clk;
    output reg reset_pc;
    output reg [1:0] nsel;
    output reg write;
    output reg [1:0] vsel;
    output reg loada, loadb, asel, bsel, loadc, loads, load_ir, load_pc;
    output reg addr_sel;
    output reg load_addr;
    output reg [1:0] mem_cmd;

    reg [4:0] pstate;


    always @(posedge clk)begin

        //reset back to RST state if reset pressed on rising edge of clk 
        if (reset) begin  
            pstate = `RST;
            reset_pc = 1'b1;
            load_pc = 1'b1;
            write = 1'b0;
        end
        else begin
            //Otherwise check for which state and assign next state             
            case(pstate)
                `RST: pstate = `IF1;
                `IF1: pstate = `IF2;
                `IF2: pstate = `UpdatePC;
                `UpdatePC: pstate = `decoder; 
                `decoder: begin 
                        //check which opcode is inputed, if not valid, goes back to RST state 
                        if(opcode == 3'b110)begin 

                            //check op 
                            if(op == 2'b10)
                                pstate = `mov_int;                  
                            else if (op == 2'b00)
                                pstate = `getB;
                            else //go to RST state if input is invalid 
                                pstate = `RST;
                        end
                        else if (opcode == 3'b101) begin

                            //check op
                            if (op == 2'b00)
                                pstate = `getA;
                            else if(op == 2'b01)
                                pstate = `getA;
                            else if(op == 2'b10)
                                pstate = `getA;

                            else if (op == 2'b11)
                                pstate = `getB;

                            else // go back to RST if input is not valid
                                pstate = `RST;
                        end
                        //Load op
                        else if(opcode == 3'b011 && op == 2'b00)
                            pstate = `getA;
                        
                        //STR op
                        else if(opcode == 3'b100 && op == 2'b00)
                            pstate = `getA;
                        
                        else if(opcode == 3'b111)
                            pstate = `HALT;
                            
                        else
                            pstate = `RST;
                    end
                `mov_int: pstate = `IF1;
                `getA: begin

                    //check which next state to transition too 
                    if(opcode == 3'b011 || opcode == 3'b100)
                        pstate = `LDR1;
                    else if(opcode == 3'b101)
                        pstate = `getB;
                    else 
                        pstate = `RST;
                end 
                `getB: begin 

                    //check which next state to transition too 
                    if(opcode == 3'b110)
                        pstate = `computation_BO;
                    else if (opcode == 3'b101)
                        if(op == 2'b00 || op == 2'b10 || op == 2'b01)
                            pstate = `computation;
                        else if(op == 2'b11)
                            pstate = `computation_BO;
                        else 
                            pstate = `RST;
                    //invalid input 
                    else 
                        pstate = `RST;

                end
                `computation: pstate = `write_Rd;
                `computation_BO: begin 
                    if(opcode == 3'b110)
                        pstate = `write_Rd;
                    else if (opcode == 3'b100)
                        pstate = `STR2;
                    else
                        pstate = `RST;
                    end
                `write_Rd: pstate = `IF1;
                `LDR1: pstate = `LDR2;
                `LDR2: begin 
                    if(opcode == 3'b011)
                        pstate = `LDR3;
                    else if(opcode == 3'b100)
                        pstate = `STR1;
                    else
                        pstate = `RST;
                    end
                `LDR3: pstate = `LDR4;
                `LDR4: pstate = `IF1;
                `STR1: pstate = `computation_BO;
                `STR2: pstate = `IF1;
                `HALT: begin 
                    if(reset)
                        pstate = `RST;
                    else 
                        pstate = `HALT;
                    end
                default: pstate = 4'bx;
            endcase 

            //assign outputs in a seperate case statement 
            case(pstate)
                `RST: begin 
                    reset_pc = 1'b1;
                    load_pc = 1'b1;
                    write = 1'b0;
                    load_ir = 1'b0;
                    end 
                `IF1: begin 
                    write = 1'b0;
                    load_pc = 1'b0;
                    addr_sel = 1'b1;
                    mem_cmd = `MREAD;
                    reset_pc = 1'b0;
                    end
                `IF2: begin 
                    addr_sel = 1'b1;
                    load_ir = 1'b1;
                    mem_cmd = `MREAD;
                    end
                `UpdatePC: begin 
                    load_pc = 1'b1;
                    load_ir = 1'b0;
                end
                `decoder: begin 
                    load_ir = 1'b0;
                    load_pc = 1'b0;
                    end 
                `mov_int: begin
                    vsel = 2'b11;
                    write = 1'b1;
                    nsel = 2'b11;
                    end
                `getA: begin 
                    write = 1'b0;
                    loada = 1'b1;
                    nsel = 2'b11;
                    end
                `getB: begin
                    loadb = 1'b1;
                    loada = 1'b0;
                    nsel = 2'b00;
                    end
                `computation: begin
                    asel = 1'b0;
                    bsel = 1'b0;
                    loadc = 1'b1;
                    loads = 1'b1;
                    loadb = 1'b0;
                    end
                `computation_BO: begin
                    asel = 1'b1;
                    bsel = 1'b0;
                    loadc = 1'b1;
                    loads = 1'b1;
                    loadb = 1'b0;
                    end
                `write_Rd: begin 
                    nsel = 2'b01;
                    loadc = 1'b0;
                    loads = 1'b0;
                    write = 1'b1;
                    vsel = 2'b00;
                    end
                `LDR1: begin 
                    loada = 1'b0;
                    bsel = 1'b1;
                    asel = 1'b0;
                    loadc = 1'b1;
                    loads = 1'b1;
                    end
                `LDR2: begin 
                    load_addr = 1'b1;
                    loadc = 1'b0;
                    loads = 1'b0;
                    end 
                `LDR3: begin 
                    addr_sel = 1'b0;
                    mem_cmd = `MREAD;
                    end 
                `LDR4: begin 
                    vsel = 2'b10;
                    nsel = 2'b01;
                    write = 1'b1;
                    end 
                `STR1: begin 
                    loadb = 1'b1;
                    loada = 1'b0;
                    nsel = 2'b01;
                    end
                `STR2: begin
                    mem_cmd = `MWRITE;
                    addr_sel = 1'b0;
                    end
                default: begin
                        write = 1'bx;
                        vsel = 2'bx;
                        nsel = 2'bx;
                    end
            endcase

        end
    end
endmodule 