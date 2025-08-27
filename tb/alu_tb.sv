module ALU_tb;
    reg [15:0] Ain, Bin; 
    reg [1:0] ALUop; 
    wire [2:0] Z;
    wire [15:0] out;
    reg err;
    
    //Instantiate ALU 
    ALU DUT(Ain, Bin, ALUop, out, z);



    task alu_checker;

        input [15:0] expected_out;

        //Check if output is as expected           
        if(ALU_tb.DUT.out != expected_out)begin

                $display("Error: out is: %b, expected: %b", ALU_tb.DUT.out, expected_out);

                // set err to 1 to signify that there was an error
                err = 1'b1;
            end

    endtask 



    
    initial begin

        //initialize err to 0
        err = 1'b0;

        //test1: A + B
        Ain = 16'b0000000000000001;
        Bin = 16'b0000000000000001;
        ALUop = 2'b00;

        #5;
        
        $display("test 1: ");
        //Expected to be addition of A and B
        alu_checker(16'b0000000000000010);
    
        #5;

        //test2: A+B. Testing for edge case 
        Ain = 16'b1111111111111111;
        Bin = 16'b0000000000000001;
        ALUop = 2'b00;

        #5;

        $display("test 2: ");
        //Expected to be 16'b0000000000000000;
        alu_checker(16'b0000000000000000);
        
        #5;

        // test 3: subtraction
        Ain = 16'b1111111111111111;
        Bin = 16'b0000000000000001;
        ALUop = 2'b01;

        #5;
        
        $display("test 3: ");
        // expecting out to be 16'b1111111111111110
        alu_checker(16'b1111111111111110);

        #5;

        //test 4: anding 
        Ain = 16'b0010000000000001;
        Bin = 16'b0010000000000001;
        ALUop = 2'b10;

        #5;

        $display("test 4: ");
        //Expecting A & B
        alu_checker(16'b0010000000000001);
        #5;

        //test 5: not of B  
        Ain = 16'b0000000000000001;
        Bin = 16'b0000000011011111;
        ALUop = 2'b11;

        #5;

        $display("test 5: ");
        // expecting out to be 16'b1111111100100000
        alu_checker(16'b1111111100100000);
        
        #5;

        //test 6: testing for Z = 1, (out all 0)
        Ain = 16'b0000000011011111;
        Bin = 16'b0000000011011111;
        ALUop = 2'b01;

        #5;
        
        $display("test 6: ");
        // expecting out to be 16'b0000000000000000 and Z to be 1
        alu_checker(16'b0000000000000000);
        
        #5;
		  
		  //test 7: testing for overflow 
        Ain = 16'b0111111111111111;
        Bin = 16'b0000_0000_0000_0001;
        ALUop = 2'b00;

        #5;
		  
		  $display("test 7: ");
        // expecting out to be 16'b0000000000000000 and Z to be 1
        alu_checker(16'b1000_0000_0000_0000);
        
        #5;



        //Display Failed if any case failed 
        if(~err) 
            $display("PASSED");	//display "PASSED" of "FAILED" if all states and outputs were correct or incorrect
        else 
            $display("FAILED");
        
    end

endmodule 