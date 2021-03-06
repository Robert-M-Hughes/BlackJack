module TestBench_cardSystem();
	
	// Create clock signals
	logic clk = 1'b0;
	always #50 clk <= ~clk;
	
	// Input signals
	logic reset = 0;
	logic [1:0] userSelect = 0;
	logic [1:0] randomUser;
	
	// Internal signals
	logic [3:0] card;
	
	// Output signals
	logic cardsUpdated;
	logic [5:0] p1_high, p1_low, p2_high, p2_low, d_high, d_low;
	
	// Track pulled cards and expected card values
	logic [3:0] pulledCards [9:0] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	logic [4:0] expectedP1High = 0, expectedP1Low = 0, expectedP2High = 0, expectedP2Low = 0, expectedDHigh = 0, expectedDLow = 0;
	
	task TestPull();
		randomUser= $urandom_range(1, 3);
		//$display("DEBUG(%0t): randomUser=%d", $time, randomUser);
		
		// Set user
		@(negedge clk) begin
			userSelect <= randomUser;
		end
		// Wait up to 52 cycles to see if a card is pulled
		for(int i = 0; i < 52; i++) begin
			@(posedge clk) begin
			
				if(i == 51 && card == 0) begin
					$display("FAIL(%0t): Unable to pull card", $time);
				end
				else if(card > 0) begin
					// Check if card was pulled more times than should be possible
					if((card < 10 && pulledCards[card-1] === 4) || (card == 10 && pulledCards[card-1] === 16)) begin
						$display("FAIL(%0t): Pulled single card too many times", $time);
					end
					
					// Updated pulledCard
					pulledCards[card-1] <= pulledCards[card-1] + 1;
					
					// Update expected value
					if(userSelect == 1) begin
						if(card > 1 && expectedP1Low == 0) begin
							if(expectedP1High <= 21) begin
								expectedP1High = expectedP1High + card;
							end
						end
						else begin
							if(card != 1) begin
								if(expectedP1High <=21) begin
									expectedP1High = expectedP1High + card;
								end
								if(expectedP1Low <=21) begin
									expectedP1Low = expectedP1Low + card;
								end
							end
							else begin
								if(expectedP1High <=21) begin
									expectedP1High = expectedP1High + 11;
								end
								if(expectedP1Low <=21) begin
									expectedP1Low = expectedP1Low + 1;
								end
							end
						end
					end
					else if(userSelect == 2) begin
						if(card > 1 && expectedP2Low == 0) begin
							if(expectedP2High <= 21) begin
								expectedP2High = expectedP2High + card;
							end
						end
						else begin
							if(card != 1) begin
								if(expectedP2High <=21) begin
									expectedP2High = expectedP2High + card;
								end
								if(expectedP2Low <=21) begin
									expectedP2Low = expectedP2Low + card;
								end
							end
							else begin
								if(expectedP2High <=21) begin
									expectedP2High = expectedP2High + 11;
								end
								if(expectedP2Low <=21) begin
									expectedP2Low = expectedP2Low + 1;
								end
							end
						end
					end
					else if(userSelect == 3) begin
						if(card > 1 && expectedDLow == 0) begin
							if(expectedDHigh <= 21) begin
								expectedDHigh = expectedDHigh + card;
							end
						end
						else begin
							if(card != 1) begin
								if(expectedDHigh <=21) begin
									expectedDHigh = expectedDHigh + card;
								end
								if(expectedDLow <=21) begin
									expectedDLow = expectedDLow + card;
								end
							end
							else begin
								if(expectedDHigh <=21) begin
									expectedDHigh = expectedDHigh + 11;
								end
								if(expectedDLow <=21) begin
									expectedDLow = expectedDLow + 1;
								end
							end
						end
					end
					break;
				end
			end
		end
		
		// Check if hands are updated
		@(posedge clk) begin
			if(p1_high != expectedP1High || p1_low != expectedP1Low || p2_high != expectedP2High || p2_low != expectedP2Low || d_high != expectedDHigh || d_low != expectedDLow) begin
				$display("FAIL(%0t): Did not see expected hands P1(%d/%d) P2(%d/%d) D(%d/%d) | Expected P1(%d/%d) P2(%d/%d) D(%d/%d)", $time, p1_high, p1_low, p2_high, p2_low, d_high, d_low, expectedP1High, expectedP1Low, expectedP2High, expectedP2Low, expectedDHigh, expectedDLow);
			end
		end
		
		
		// Reset userSelect and wait for positive edge so card resets
		userSelect <= 0;
		@(posedge clk);
	endtask
	
	// Connect device(s) to test
	cardPuller puller(.clk(clk), .reset(reset), .userSelect(userSelect), .card(card));
	cardManager manager(clk, reset, userSelect, card, cardsUpdated, p1_high, p1_low, p2_high, p2_low, d_high, d_low);
	
	initial begin
		
		// Write to each
		for(int i = 0; i < 52; i++) begin
			TestPull();
		end
		$display("All tests completed!");
	end
	
endmodule