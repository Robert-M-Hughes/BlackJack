module TestBench_syncButton();
	
	// Create clock signal
	logic clk = 1'b0;
	always #50 clk <= ~clk;
	
	/* Inputs */
	logic in;
	int pushDelay, inLength;

   /* Outputs */
   logic out;
	
	task TestCase();
		pushDelay = $urandom_range(2, 5);
		inLength = $urandom_range(1, 20);
		
		repeat(pushDelay) @(posedge clk);
		
		for(int i=0; i <= inLength; i++)  begin
			@(negedge clk);
				in <= 1'b0;
					
			@(posedge clk);
				/*tc: assert(out == (i < 2))
						//$display("PASS: in(%b) => out(%b)", in, out);
					else
						//$display("FAIL: in(%b) => out(%b) | Expected out(%b)", in, out, (i < 2));*/
		end
		
		@(negedge clk);
				in <= 1'b1;
	endtask
	
	// Connect device to test
	syncButton device(.clk(clk), .in(in), .out(out));
	
	initial begin	
		TestCase();
		TestCase();
		TestCase();
		TestCase();
		TestCase();
		TestCase();
		TestCase();
		TestCase();
		  
		$display("Done");
	end
	
endmodule