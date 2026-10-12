module ALU_TEST();
	reg signed [7:0] a,b;
	wire signed  [7:0] out;
	reg[1:0] operand;
	wire z,n,c,v;
	
	ALU DUT(a,b,operand,out,z,n,c,v);

	task stimulus (input [7:0]a_in,b_in,input [1:0] operand_in);
		begin
			a = a_in;
			b = b_in;
			operand = operand_in;
			#10;
		end
	endtask
		
	initial
		begin
/*			stimulus(8'd30,8'd10,2'b00);
			#10;
			stimulus(8'd20,8'd10,2'b01);
			#10;
			stimulus(8'b10011001, 8'b10101010,2'b10);
			#10;
			stimulus(8'b10011001, 8'b10101010,2'b11);
			#10;
			stimulus(8'd255,8'd255,2'b00);	
			#100
			$finish;	*/
		
		/*       for(integer i = 0;i < 256; i=i+1)
		       begin
			       stimulus($urandom,$urandom,$urandom);
			       
			end*/
		       stimulus( 0, 0, 2'b00 );
        stimulus( 0, 0, 2'b01 );
        stimulus( 0, 0, 2'b10 );
        stimulus( 0, 0, 2'b11 );

        //Q1
        stimulus( 5, 5, 2'b00 );

        stimulus( 5, 5, 2'b01 );

        stimulus( 5, 5, 2'b10 );

        stimulus( 5, 5, 2'b11 );


        //Q2
        stimulus( -5, 5, 2'b00 );

        stimulus( -5, 5, 2'b01 );

        stimulus( -5, 5, 2'b10 );

        stimulus( -5, 5, 2'b11 );


        //Q3
        stimulus( -5, -5, 2'b00 );

        stimulus( -5, -5, 2'b01 );

        stimulus( -5, -5, 2'b10 );

        stimulus( -5, -5, 2'b11 );


        //Q4
        stimulus( 5, -5, 2'b00 );

        stimulus( 5, -5, 2'b01 );

        stimulus( 5, -5, 2'b10 );

        stimulus( 5, -5, 2'b11 );


        stimulus( 255, 255, 2'b00 );

        stimulus( 255, -255, 2'b01 );

        stimulus( 255, -255, 2'b10 );

        stimulus( 255, -255, 2'b11 );

		end
		initial
			$monitor("the value of a is %d, the value of b is %d, the operand is %d, the output is %d,the zero signal is %d,negative signal is %d,\n the value of carry is %d ,the value of overflow is %d\n",a,b,operand,out,z,n,c,v);
		initial
		begin
			$dumpfile("dump.vcd");
			$dumpvars(0, ALU_TEST);	
		end
		endmodule	

	
