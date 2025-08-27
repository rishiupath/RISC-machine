module shifter_tb;
    reg [15:0] in; 
    reg [1:0] shift;
    wire [15:0] sout;
    reg err;

    //Instantitate shifter mo
    shifter DUT(in, shift, sout);
    

    task shifter_checker;

        input [15:0] expected_sout;
        begin

    
        //Check if output is as expected           
        if(shifter_tb.DUT.sout != expected_sout)begin

                $display("Error: sout is: %b, expected: %b", shifter_tb.DUT.sout, expected_sout);

                // set err to 1  tp signify that there was an error
                err = 1'b1;
            end
        end
    endtask 

    initial begin
        
        err = 1'b0;

        //First 4 tests use example values from the lab 5 manual 
        
        //test 1: no shift 
        in = 16'b1111000011001111;
	    shift = 2'b00;
        #5;

        $display("test 1: ");
        //Expecting output to be same as input 
        shifter_checker(16'b1111000011001111);
        #5;

        //test 2: shift left 
        in = 16'b1111000011001111;
	    shift = 2'b01;
        #5;
        
        $display("test 2: ");
        //Expecting output to be shifted left by 1 bit  
        shifter_checker(16'b1110000110011110);
        #5 

        //test 3: shift right 
        in = 16'b1111000011001111;
	    shift = 2'b10;
        #5 

        $display("test 3: ");
        //expecting output to shift right by one bit
        shifter_checker(16'b0111100001100111);

        #5;

        //test 4: shifted right 1-bit, MSB is copy of B[15]
        in = 16'b1111000011001111;
	    shift = 2'b11;
        #5

        $display("test 4: ");
        //expecting output to shift right by one bit with MSB the previous MSB 
        shifter_checker(16'b1111100001100111);

        #5;
         
        if(~err) 
            $display("PASSED");	//display "PASSED" of "FAILED" if all states and outputs were correct or incorrect
	    else 
            $display("FAILED");
    end

endmodule