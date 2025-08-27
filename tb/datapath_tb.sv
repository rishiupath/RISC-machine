module datapath_tb;
    reg clk, write;
    reg [2:0]readnum;
    reg [1:0] vsel;
    reg loada, loadb, loads, loadc, asel, bsel;
    reg [1:0] shift;
    reg [1:0] ALUop;
    reg [2:0] writenum;
    wire [2:0] flag_out_f;
    wire [15:0] datapath_out;

    reg [15:0] mdata;
    reg [7:0] PC;
    reg [15:0] sximm8;
    reg [15:0] sximm5;
    
    reg err;

    //instantiate datapath 
    datapath dut_datapath ( .clk (clk), 

                // register operand fetch stage
                .readnum     (readnum),
                .vsel        (vsel),
                .loada       (loada),
                .loadb       (loadb),

                // computation stage (sometimes called "execute")
                .shift       (shift),
                .asel        (asel),
                .bsel        (bsel),
                .ALUop       (ALUop),
                .loadc       (loadc),
                .loads       (loads),

                // set when "writing back" to register file
                .writenum    (writenum),
                .write       (write),  
                //new inputs 
                .mdata (mdata),
                .sximm8 (sximm8),
                .PC(PC),
                .sximm5 (sximm5),

                // outputs
                .flag_out_f (flag_out_f),
                .datapath_out(datapath_out)
             );


    task datapath_checker;

        input [15:0] expected_dataout;
        input [2:0] expected_fout;
        begin

            if(datapath_out != expected_dataout)begin

                $display("Error: datapath out is: %b, expected: %b", datapath_out, expected_dataout);

                // set err to 1  tp signify that there was an error
                err = 1'b1;
            end

             if(flag_out_f != expected_fout)begin

                $display("Error: datapath out is: %b, expected: %b", flag_out_f, expected_fout);

                // set err to 1  tp signify that there was an error
                err = 1'b1;
            end



        end

    endtask 

    initial begin
        // initialize err to 0
        err = 1'b0;

        clk = 1'b0;

        //test 1

        //MOV R0, #7
        sximm8 = 16'b0000000000000111;
        vsel = 2'b11;
        writenum = 3'b000;
        write = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;

        //MOV R1, #2
        sximm8 = 16'b0000000000000010;
        vsel = 2'b11;
        writenum = 3'b001;
        write = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;

        write = 1'b0;

        //ADD R2, R1, R0, LSL#1

        //Move R1 into register A
        readnum = 3'b001;
        loada = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;

        loada = 1'b0;

        //Move R0 into register B 
        readnum = 3'b000;
        loadb = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;

        loadb = 1'b0;

        //Shift R0 left by 1, and Add to R1 

        shift = 2'b01;
        asel = 1'b0;
        bsel = 1'b0;
        ALUop = 2'b00;
        loadc = 1'b1;
        loads = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;
        
        loadc = 1'b0;
        loads = 1'b0;
        
        $display("test1: ");
        // expecting 16 in binary (b0000000000010000)
        datapath_checker(16'b0000000000010000, 3'b0);

        //Store value into R2
        vsel = 2'b11;
        write = 1'b1;
        writenum = 3'b010;
        clk = 1'b1;
        #5;
        clk = 1'b0;
        

        //test 2

        //MOV R3, #14
        sximm8 = 16'b0000000000001110;
        vsel = 2'b11;
        writenum = 3'b011;
        write = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;

        write = 1'b0;

        //Move R3 into register B
        readnum = 3'b011;
        loadb = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;

        loadb = 1'b0;

        //shift B right by 2. And then not B 
        shift = 2'b10;
        asel = 1'b1;
        bsel = 1'b0;
        ALUop = 2'b11;
        loadc = 1'b1;
        loads = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;

        $display("test2: ");
        //expecting not of 7
        datapath_checker(16'b1111111111111000, 3'b010);

        //test 3, testing choosing vsel as mdata 

        //MOV R0, mdata 
        mdata = 16'b000000000000000;
        vsel = 2'b10;
        writenum = 3'b000;
        write = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;


        //ADD R2, R1, R0, LSL#1

        //Move R1 into register A
        readnum = 3'b001;
        loada = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;

        loada = 1'b0;

        //Move R0 into register B 
        readnum = 3'b000;
        loadb = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;

        loadb = 1'b0;

        //Shift R0 left by 1, and Add to R1 

        shift = 2'b01;
        asel = 1'b0;
        bsel = 1'b0;
        ALUop = 2'b00;
        loadc = 1'b1;
        loads = 1'b1;
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;
        
        loadc = 1'b0;
        loads = 1'b0;
        
        $display("test3: ");
        // expecting 2 in binary (b0000000000000010)
        datapath_checker(16'b0000000000000010, 3'b0);

        //Store value into R2
        vsel = 2'b11;
        write = 1'b1;
        writenum = 3'b010;
        clk = 1'b1;
        #5;
        clk = 1'b0;


        if(~err) 
            $display("PASSED");	//display "PASSED" of "FAILED" if all states and outputs were correct or incorrect
	    else 
            $display("FAILED");

    end

endmodule 