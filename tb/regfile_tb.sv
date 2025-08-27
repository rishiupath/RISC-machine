module regfile_tb;
    reg [15:0] data_in;
    reg [2:0] writenum;
    reg write, clk;
    reg [2:0] readnum;
    wire [15:0] data_out;
    reg err;

    //Instantiate regfile 
    regfile DUT(data_in,writenum,write,readnum,clk,data_out);

    // task that will print an error if data_out is not the expected value
    task reg_checker;

        input [15:0] expected_out;

        begin

    
        //Check if output is as expected           
        if(regfile_tb.DUT.data_out != expected_out)begin

                $display("Error: data out is: %b, expected: %b", regfile_tb.DUT.data_out, expected_out);

                // set err to 1  tp signify that there was an error
                err = 1'b1;
            end
        end
    endtask 

    initial begin 

    //clk = 1'b0; #5;

    forever begin 
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    end

    initial begin 

        // initialize error to 0
        err = 1'b0;

        //test1: writing data_in (16'b0000000000000011) into R0 and reading from R0
        writenum = 3'b000;
        write = 1'b1;
        data_in = 16'b0000000000000011;
        readnum = 3'b000;

        #5;
        //Expecting data written into R0 (16'b000000000000011);
        reg_checker(16'b0000000000000011);
       
        

        #5;

        //test2: writing data_in (16'b0000000000001111) into R7 and reading from R0.
        writenum = 3'b111;
        write = 1'b0;
        data_in = 16'b0000000000001111;
        readnum = 3'b000;

        #5;
        //Expecting data stored in R0, since reading from R0
        reg_checker(16'b0000000000000011);

        #5;

        //test3: writing data_in (16'b0000000000000111) into R7 and reading from R7 
        writenum = 3'b111;
        write = 1'b1;
        data_in = 16'b0000000000000111;
        readnum = 3'b111;

        #5;
        //Expecting data written into R7
        reg_checker(16'b0000000000000111);

        #5;

        //test4: not writing data_in (16'b0000000000111111) into R0 and reading from R7.
        writenum = 3'b000;
        write = 1'b0;
        data_in = 16'b0000000000111111;
        readnum = 3'b111;

        #5;
        // expecting previous value from R0 since write is 0 in this test.
        reg_checker(16'b0000000000000111);


        #5;
        /*The following tests for data written and read from R1-R6*/
        
        //test5: writing data_in (16'b1000000000000011) into R1 and reading from R1
        writenum = 3'b001;
        write = 1'b1;
        data_in = 16'b1000000000000011;
        readnum = 3'b001;

        #5;
        //Expecting data written into R1 (16'b100000000000011);
        reg_checker(16'b1000000000000011);

        #5;

        //test6: writing data_in (16'b1100000000000011) into R2 and reading from R2
        writenum = 3'b010;
        write = 1'b1;
        data_in = 16'b1100000000000011;
        readnum = 3'b010;
        
        #5;
        //Expecting data written into R2 (16'b110000000000011);
        reg_checker(16'b1100000000000011);

        #5;

        //test7: writing data_in (16'b1110000000000011) into R3 and reading from R3
        writenum = 3'b011;
        write = 1'b1;
        data_in = 16'b1110000000000011;
        readnum = 3'b011;

        #5;
        //Expecting data written into R3 (16'b111000000000011);
        reg_checker(16'b1110000000000011);

        #5;

        //test8: writing data_in (16'b1111000000000011) into R4 and reading from R4
        writenum = 3'b100;
        write = 1'b1;
        data_in = 16'b1111000000000011;
        readnum = 3'b100;

        #5;
        //Expecting data written into R4 (16'b111100000000011);
        reg_checker(16'b1111000000000011);

        #5;

        //test9: writing data_in (16'b1100000000011111) into R5 and reading from R5
        writenum = 3'b101;
        write = 1'b1;
        data_in = 16'b1100000000011111;
        readnum = 3'b101;

        #5;
        //Expecting data written into R5 (16'b110000000011111);
        reg_checker(16'b1100000000011111);

        #5;

        //test10: writing data_in (16'b0100000000000011) into R6 and reading from R6
        writenum = 3'b110;
        write = 1'b1;
        data_in = 16'b0100000000000011;
        readnum = 3'b110;

        #5;
        //Expecting data written into R6 (16'b010000000000011);
        reg_checker(16'b0100000000000011);
        
        #5;
        
        if(~err) 
            $display("PASSED");	//display "PASSED" of "FAILED" if all states and outputs were correct or incorrect
	    else 
            $display("FAILED");
    end

endmodule 