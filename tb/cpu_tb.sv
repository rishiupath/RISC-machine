module cpu_tb;
    reg clk, reset, s, load;
    reg [15:0] in; 
    wire [15:0] out;
    wire N, V, Z, w;
    reg err;


    cpu DUT(.clk(clk), .reset(reset), .s(s), .load(load), .in(in), .out(out), .N(N), .V(V), .Z(Z), .w(w));


    task cpu_checker;

        input [15:0] expected_cpuout;
        input expected_N;
        input expected_V;
        input expected_Z;

        begin
            //check cpu out 
            if(out != expected_cpuout)begin

                $display("Error: cpu out is: %b, expected: %b", out, expected_cpuout);

                // set err to 1  to signify that there was an error
                err = 1'b1;
            end

            //check N flag 
            if (N != expected_N)begin 
                
                $display("Error: N flag is: %b, expected: %b", N, expected_N);

            end
            
            //check V flag 
            if (V != expected_V)begin 
                
                // set err to 1  to signify that there was an error
                $display("Error: V flag is: %b, expected: %b", V, expected_V);
                
                err = 1'b1;
            end 

            //check Z flag 
            if (Z != expected_Z)begin 
                
                // set err to 1  to signify that there was an error
                $display("Error: Z flag is: %b, expected: %b", Z, expected_Z);

                err = 1'b1;
            end        
        end
    endtask 

    initial begin 

        forever begin 
            clk = 1'b0;
            #5;
            clk = 1'b1;
            #5;
        end

    end


    initial begin

        err = 1'b0;
        
        //test 1: MOV R1, #5: move number into register (5 into R1), also checks if reset works 
        in = 16'b1101_0001_0000_0101;
        load = 1'b1;

        reset = 1'b1;
        #10;
        reset = 1'b0;

        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #30;

        $display("test1: ");
        // expecting 5
        cpu_checker(16'b0000_0000_0000_0101, 1'b0, 1'b0, 1'b0);
        //check R1 out 
        if(DUT.DP.REGFILE.R1 != 16'b0000_0000_0000_0101 )
            err = 1'b1;

        //test 2: MOV R2, #3: move number into register (3 into R2) 
        in = 16'b1101_0010_0000_0011;

        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #30;

        $display("test2: ");
        // expecting 3
        cpu_checker(16'b0000_0000_0000_0011, 1'b0, 1'b0, 1'b0);
        //check R2 out 
        if(DUT.DP.REGFILE.R2 != 16'b0000_0000_0000_0011 )begin 
            err = 1'b1;
            $display("regfile error");
        end

        //test 3: MOV R1, #9: move number into register (9 into R1), but load is never set to 1, so old value is expected   
        in = 16'b1101_0010_0000_0011;
        load = 1'b0;

        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #30;

        $display("test3: ");
        // expecting 5
        cpu_checker(16'b0000_0000_0000_0101, 1'b0, 1'b0, 1'b0);
        //check R1 out 
        if(DUT.DP.REGFILE.R1 != 16'b0000_0000_0000_0101 )begin 
            err = 1'b1;
            $display("regfile error");
        end


        //turn load back on 
        load = 1'b1;

        //test 4: ADD R3, R1, R2 (5+3) 
        in = 16'b1010_0001_0110_0010;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test4: ");
        // expecting 8
        cpu_checker(16'b0000_0000_0000_1000, 1'b0, 1'b0, 1'b0);
        //check R3 out 
        if(DUT.DP.REGFILE.R3 != 16'b0000_0000_0000_1000)begin 
            err = 1'b1;
            $display("regfile error");
        end
        
        //test 5: MOV Rd, Rm: MOV R4, R3, LSL #1 (MOV R4, #16) testing for moving register to register with shift 
        in = 16'b1100_0000_1000_1011;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test5: ");
        // expecting 16
        cpu_checker(16'b0000_0000_0001_0000, 1'b0, 1'b0, 1'b0);
        //check R4 out 
        if(DUT.DP.REGFILE.R4 != 16'b0000_0000_0001_0000)begin 
            err = 1'b1;
            $display("regfile error");
        end

        //test 6: AND Rd,Rn,Rm{,<sh_op>}: AND R5, R1, R2 (AND R5, #5, #3)
        in = 16'b1011_0001_1010_0010;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test6: ");
        // expecting 1
        cpu_checker(16'b0000_0000_0000_0001, 1'b0, 1'b0, 1'b0);
        //check R5 out 
        if(DUT.DP.REGFILE.R5 != 16'b0000_0000_0000_0001)begin 
            err = 1'b1;
            $display("regfile error");
        end

        // test 7: MVN Rd,Rm{,<sh_op>}: MVN R6, R1 (R6 = ~5)
        in = 16'b1011_1000_1100_0001;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test7: ");
        // expecting 1111_1111_1111_1010
        cpu_checker(16'b1111_1111_1111_1010, 1'b1, 1'b0, 1'b0);
        //check R6 out 
        if(DUT.DP.REGFILE.R6 != 16'b1111_1111_1111_1010)begin 
            err = 1'b1;
            $display("regfile error");
        end

        //test 8: CMP Rn,Rm{,<sh_op>}: CMP R4, R1 (CMP 16, 5), expecting all flags 0 
        in = 16'b1010_1100_0000_0001;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test8: ");
        // expecting 0000_0000_0000_1011
        cpu_checker(16'b0000_0000_0000_1011, 1'b0, 1'b0, 1'b0);

        //test 9: ADD Rd,Rn,Rm{,<sh_op>}: ADD R7, R3, R1, LSL#1  (R7= 8 + 5*2 ), testing ADD with shift left 
        in = 16'b1010_0011_1110_1001;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test9: ");
        // expecting 18
        cpu_checker(16'b0000_0000_0001_0010, 1'b0, 1'b0, 1'b0);
        //check R7 out 
        if(DUT.DP.REGFILE.R7 != 16'b0000_0000_0001_0010)begin
            err = 1'b1;
            $display("regfile error");
        end

        //test 10: ADD Rd,Rn,Rm{,<sh_op>}: ADD R6, R2, R7, LSR#1  (R6= 3 + 18/2 ), testing ADD with shift right  
        in = 16'b1010_0010_1101_0111;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test10: ");
        // expecting 11
        cpu_checker(16'b0000_0000_0000_1100, 1'b0, 1'b0, 1'b0);
        //check R6 out 
        if(DUT.DP.REGFILE.R6 != 16'b0000_0000_0000_1100)begin
            err = 1'b1;
            $display("regfile error");
        end

        //test 11: MOV Rd, Rm: MOV R3, R5 (r3 = 1)testing for moving register to register 
        in = 16'b1100_0000_0110_0101;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test11: ");
        // expecting 1
        cpu_checker(16'b0000_0000_0000_0001, 1'b0, 1'b0, 1'b0);
        //check R3 out 
        if(DUT.DP.REGFILE.R3 != 16'b0000_0000_0000_0001)begin
            err = 1'b1;
            $display("regfile error");
        end

        //test 12: MOV Rd, Rm: MOV R5, R5 (r5 = 1/2)testing for moving register to itself, with a shift right 
        in = 16'b1100_0000_1011_0101;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test12: ");
        // expecting 0
        cpu_checker(16'b0000_0000_0000_0000, 1'b0, 1'b0, 1'b1);
        //check R5 out 
        if(DUT.DP.REGFILE.R5 != 16'b0000_0000_0000_0000)begin
            err = 1'b1;
            $display("regfile error");
        end

        //test 13: CMP Rn,Rm{,<sh_op>}: CMP R6, R6 (CMP 11, 11), expecting zero flag to be 1
        in = 16'b1010_1110_0000_0110;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test13: ");
        // expecting 0000_0000_0000_0000
        cpu_checker(16'b0000_0000_0000_0000, 1'b0, 1'b0, 1'b1);

         //test 14: CMP Rn,Rm{,<sh_op>}: CMP R7, R4 (CMP 18, 16), expecting zero flag to be 0
        in = 16'b1010_1111_0000_0100;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test14: ");
        // expecting 0000_0000_0000_0010
        cpu_checker(16'b0000_0000_0000_0010, 1'b0, 1'b0, 1'b0);



        //test 15: AND Rd,Rn,Rm{,<sh_op>}: AND R0, R1, R3, LSL#1 (r0 = 5 & 1*2)
        in = 16'b1011_0001_0000_1011;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test15: ");
        // expecting 0 
        cpu_checker(16'b0000_0000_0000_0000, 1'b0, 1'b0, 1'b1);
        //check R5 out 
        if(DUT.DP.REGFILE.R0 != 16'b0000_0000_0000_0000)begin
            err = 1'b1;
            $display("regfile error");
        end

        //test 16: AND Rd,Rn,Rm{,<sh_op>}: AND R0, R4, R7 (r0 = 16 & 18)
        in = 16'b1011_0100_0000_0111;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test16: ");
        // expecting 16
        cpu_checker(16'b0000_0000_0001_0000, 1'b0, 1'b0, 1'b0);
        //check R5 out 
        if(DUT.DP.REGFILE.R0 != 16'b0000_0000_0001_0000)begin
            err = 1'b1;
            $display("regfile error");
        end

        
        //test 17: MVN Rd,Rm{,<sh_op>}: MVN R1,R7, LSR#1, testing MVN with shift 
        in = 16'b1011_1000_0011_0111;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test17: ");
        // expecting 16
        cpu_checker(16'b1111_1111_1111_0110, 1'b1, 1'b0, 1'b0);
        //check R1 out 
        if(DUT.DP.REGFILE.R1 != 16'b1111_1111_1111_0110)begin
            err = 1'b1;
            $display("regfile error");
        end


        
        //test 18: MVN Rd,Rm{,<sh_op>}: MVN R1, R1, mvn from register to same register 
        in = 16'b1011_1000_0010_0001;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test18: ");
        // expecting 16
        cpu_checker(16'b0000_0000_0000_1001, 1'b0, 1'b0, 1'b0);
        //check R5 out 
        if(DUT.DP.REGFILE.R1 != 16'b0000_0000_0000_1001)begin
            err = 1'b1;
            $display("regfile error");
        end

        //test 19: MOV -3 into R2
        in = 16'b1101_0010_1111_1101;
        s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        s = 1'b0;
        #100;

        $display("test19: ");
        // expecting 16
        cpu_checker(16'b1111_1111_1111_1101, 1'b1, 1'b0, 1'b0);
        //check R5 out 
        if(DUT.DP.REGFILE.R2 != 16'b1111_1111_1111_1101)begin
            err = 1'b1;
            $display("regfile error");
        end
        


        //Display Failed if any case failed 
        if(~err) 
            $display("PASSED");	//display "PASSED" of "FAILED" if all states and outputs were correct or incorrect
        else 
            $display("FAILED");
        
        $stop;

        


        
    end
    

endmodule 