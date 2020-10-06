module TestBench_fsm();
	
	// Create clock signals
	logic clk = 1'b0;
	always #50 clk <= ~clk;
	
	// Input signals
	logic hold, hit, cardsUpdated = 1;
	logic [4:0] p1_high, p1_low, p2_high, p2_low, d_high, d_low;
	
	// Internal signals
	logic holdAI, hitAI;
	
	// Output signals
	logic [1:0] userSelect;
	logic [3:0] currentState;
	
	// Random signals
	logic twoPlayers;
	logic [2:0] nextButtons;
	logic [3:0] nextCard;
	
	// Determine best player hand
	logic [4:0] p1_best, p2_best, d_best;
	assign p1_best = (p1_high <= 21) ? p1_high : ( (p1_low <= 21 && p1_low != 0) ? p1_low : 6'b111111 );
	assign p2_best = (p2_high <= 21) ? p2_high : ( (p2_low <= 21 && p2_low != 0) ? p2_low : 6'b111111 );
	assign d_best = (d_high <= 21) ? d_high : ( (d_low <= 21 && d_low != 0) ? d_low : 6'b111111 );
	// Determine if a player is bust
	logic p1_bust, p2_bust, d_bust;
	assign p1_bust = p1_best === 6'b111111;
	assign p2_bust = p2_best === 6'b111111;
	assign d_bust = d_best === 6'b111111;
		
	task PressButtons(logic pressHold, logic pressHit);
		@(negedge clk) begin
				$display("DEBUG(%0d): Pressing buttons hold(%b) hit(%b)", $time, pressHold, pressHit);
				hold <= pressHold;
				hit <= pressHit;
			end
			
			@(negedge clk) begin
				hold <= 0;
				hit <= 0;
			end
	endtask
		
	task TestOnePlayerGame();
		p1_high = $urandom_range(2, 20);
		p1_low = 0;
		p2_high = $urandom_range(2, 20);
		p2_low = 0;
		d_high = $urandom_range(2, 20);
		d_low = 0;
		
		$display("(%0d) Starting one player game", $time);
		
		// Check if correct init state
		if(currentState != 0) begin 
			$display("FAIL(%0d): Invalid state. Not in SELECT_P1(0) state instead in currentState(%d)", $time, currentState);
		end
		
		// Press hit to start
		PressButtons(0, 1);
		
		// Wait for long 14 cycle init to complete
		for (int i = 0 ; i < 15; i ++) begin
			@(negedge clk);
		end
		
		// Check P1 state
		if(currentState != 3) begin 
			$display("FAIL(%0d): Invalid state. Not in TURN_P1(3) state instead in currentState(%d)", $time, currentState);
		end
		
		// Keep pressing buttons as player 1 while it isn't TURN_P2
		while(currentState <= 4) begin
			nextButtons = $urandom_range(0, 3);
			PressButtons(nextButtons[0], nextButtons[1]);
			
			if(nextButtons[0]) begin
				$display("(%0d) P1 Holding", $time);
			end
			else if(nextButtons[1]) begin
				if(currentState != 4) begin
					$display("FAIL(%0d): Invalid state. Not in DRAW_P1(4) state instead in currentState(%d)", $time, currentState);
				end
				else begin 
					nextCard = $urandom_range(1, 10);
					$display("(%0d) P1 hit getting card(%d)", $time, nextCard);
					
					if(p1_low != 0) begin
						p1_high = p1_high + nextCard;
						p1_low = p1_low + nextCard;
					end
					else if(nextCard == 1) begin
						p1_high = p1_high + 11;
						p1_low = p1_low + 1;
					end
					else begin
						p1_high = p1_high + nextCard;
					end
					
					$display("(%0d) P1 hand max(%d) min(%d)", $time, p1_high, p1_low);
				end
			end
			
		end
		
		// Keep pressing buttons as player 1 while it isn't TURN_D and it is a two player game
		while(currentState <= 6) begin
			@(negedge clk) begin
				if(currentState == 6) begin
					$display("(%0d) P2 hit getting card(%d)", $time, nextCard);
					
					if(p2_low != 0) begin
						p2_high = p2_high + nextCard;
						p2_low = p2_low + nextCard;
					end
					else if(nextCard == 1) begin
						p2_high = p2_high + 11;
						p2_low = p2_low + 1;
					end
					else begin
						p2_high = p2_high + nextCard;
					end
					
					$display("(%0d) P2 hand max(%d) min(%d)", $time, p2_high, p2_low);
				end
			end
		end
		$display("(%0d) P2 turn over", $time);


		while(currentState < 9) begin
			@(negedge clk) begin
				if(currentState == 8) begin
					nextCard = $urandom_range(1, 10);
					$display("(%0d) D hit getting card(%d)", $time, nextCard);
					
					if(d_low != 0) begin
						d_high = d_high + nextCard;
						d_low = d_low + nextCard;
					end
					else if(nextCard == 1) begin
						d_high = d_high + 11;
						d_low = d_low + 1;
					end
					else begin
						d_high = d_high + nextCard;
					end
					
					$display("(%0d) D hand max(%d) min(%d)", $time, d_high, d_low);
				end
			end
		end
		$display("(%0d) D turn over currentState(%d)", $time, currentState);


		// Check if correct win state occured
		if(!p1_bust && p1_best >= p2_best && p1_best > d_best) begin
			if(currentState == 9) begin
				$display("(%0d) P1 won!", $time);
			end
			else begin
				$display("FAIL(%0d): Invalid state. Not in WIN_P1(9) state instead in currentState(%d)", $time, currentState);
			end
		end
		else if(!p2_bust && p2_best > p1_best && p2_best > d_best) begin
			if(currentState == 10) begin
				$display("(%0d) P2 won!", $time);
			end
			else begin
				$display("FAIL(%0d): Invalid state. Not in WIN_P2(10) state instead in currentState(%d)", $time, currentState);
			end
		end
		else begin
			if(currentState == 11) begin
				$display("(%0d) D won!", $time);
			end
			else begin
				$display("FAIL(%0d): Invalid state. Not in WIN_D(11) state instead in currentState(%d)", $time, currentState);
			end
		end
		
		// Go to home to reset test
		PressButtons(1, 1);
	endtask

	task TestTwoPlayerGame();
		p1_high = $urandom_range(2, 20);
		p1_low = 0;
		p2_high = $urandom_range(2, 20);
		p2_low = 0;
		d_high = $urandom_range(2, 20);
		d_low = 0;
		
		$display("(%0d) Starting two player game", $time);
		
		// Check if correct init state
		if(currentState != 0) begin 
			$display("FAIL(%0d): Invalid state. Not in SELECT_P1(0) state instead in currentState(%d)", $time, currentState);
		end

		// Select two player mode
		PressButtons(1, 0);
		
		// Check if select two player game
		if(currentState != 1) begin 
			$display("FAIL(%0d): Invalid state. Not in SELECT_P2(1) state instead in currentState(%d)", $time, currentState);
		end
		
		// Press hit to start
		PressButtons(0, 1);
		
		// Wait for long 14 cycle init to complete
		for (int i = 0 ; i < 15; i ++) begin
			@(negedge clk);
		end
		
		// Check P1 state
		if(currentState != 3) begin 
			$display("FAIL(%0d): Invalid state. Not in TURN_P1(3) state instead in currentState(%d)", $time, currentState);
		end
		
		// Keep pressing buttons as player 1 while it isn't TURN_P2
		while(currentState <= 4) begin
			nextButtons = $urandom_range(0, 3);
			PressButtons(nextButtons[0], nextButtons[1]);
			
			if(nextButtons[0]) begin
				$display("(%0d) P1 Holding", $time);
			end
			else if(nextButtons[1]) begin
				if(currentState != 4) begin
					$display("FAIL(%0d): Invalid state. Not in DRAW_P1(4) state instead in currentState(%d)", $time, currentState);
				end
				else begin 
					nextCard = $urandom_range(1, 10);
					$display("(%0d) P1 hit getting card(%d)", $time, nextCard);
					
					if(p1_low != 0) begin
						p1_high = p1_high + nextCard;
						p1_low = p1_low + nextCard;
					end
					else if(nextCard == 1) begin
						p1_high = p1_high + 11;
						p1_low = p1_low + 1;
					end
					else begin
						p1_high = p1_high + nextCard;
					end
					
					$display("(%0d) P1 hand max(%d) min(%d)", $time, p1_high, p1_low);
				end
			end
			
		end
		
		// Keep pressing buttons as player 2 while it isn't TURN_D and it is a two player game
		while(currentState <= 6) begin
			nextButtons = $urandom_range(0, 3);
			PressButtons(nextButtons[0], nextButtons[1]);
			
			if(nextButtons[0]) begin
				$display("(%0d) P2 Holding", $time);
			end
			else if(nextButtons[1]) begin
				if(currentState != 6) begin
					$display("FAIL(%0d): Invalid state. Not in DRAW_P2(6) state instead in currentState(%d)", $time, currentState);
				end
				else begin 
					nextCard = $urandom_range(1, 10);
					$display("(%0d) P2 hit getting card(%d)", $time, nextCard);
					
					if(p2_low != 0) begin
						p2_high = p2_high + nextCard;
						p2_low = p2_low + nextCard;
					end
					else if(nextCard == 1) begin
						p2_high = p2_high + 11;
						p2_low = p2_low + 1;
					end
					else if(p2_low != 0) begin
						p2_high = p2_high + nextCard;
						p2_low = p2_low + nextCard;
					end
					else begin
						p2_high = p2_high + nextCard;
					end
					
					$display("(%0d) P2 hand max(%d) min(%d)", $time, p2_high, p2_low);
				end
			end
		end

		while(currentState < 9) begin
			@(negedge clk) begin
				if(currentState == 8) begin
					nextCard = $urandom_range(1, 10);
					$display("(%0d) D hit getting card(%d)", $time, nextCard);
					
					if(d_low != 0) begin
						d_high = d_high + nextCard;
						d_low = d_low + nextCard;
					end
					else if(nextCard == 1) begin
						d_high = d_high + 11;
						d_low = d_low + 1;
					end
					else begin
						d_high = d_high + nextCard;
					end
					
					$display("(%0d) D hand max(%d) min(%d)", $time, d_high, d_low);
				end
			end
		end
		$display("(%0d) D turn over currentState(%d)", $time, currentState);

		// Check if correct win state occured
		if(!p1_bust && p1_best >= p2_best && p1_best > d_best) begin
			if(currentState == 9) begin
				$display("(%0d) P1 won!", $time);
			end
			else begin
				$display("FAIL(%0d): Invalid state. Not in WIN_P1(9) state instead in currentState(%d)", $time, currentState);
			end
		end
		else if(!p2_bust && p2_best > p1_best && p2_best > d_best) begin
			if(currentState == 10) begin
				$display("(%0d) P2 won!", $time);
			end
			else begin
				$display("FAIL(%0d): Invalid state. Not in WIN_P2(10) state instead in currentState(%d)", $time, currentState);
			end
		end
		else begin
			if(currentState == 11) begin
				$display("(%0d) D won!", $time);
			end
			else begin
				$display("FAIL(%0d): Invalid state. Not in WIN_D(11) state instead in currentState(%d)", $time, currentState);
			end
		end
		
		// Go to home to reset test
		PressButtons(1, 1);
	endtask
	
	// Connect device(s) to test
	fsm fsm(.clk(clk), .hold(hold), .hit(hit), .cardsUpdated(cardsUpdated), .holdAI(holdAI), .hitAI(hitAI), .p1_high(p1_high), .p1_low(p1_low), .p2_high(p2_high), .p2_low(p2_low), .d_high(d_high), .d_low(d_low), .userSelect(userSelect), .currentState(currentState));
	playerAI ai(.clk(clk), .p_high(p2_high), .p_low(p2_low), .d_high(d_high), .hold(holdAI), .hit(hitAI));
	
	initial begin
		
		TestTwoPlayerGame();
		TestTwoPlayerGame();
		TestOnePlayerGame();
		TestTwoPlayerGame();
		TestOnePlayerGame();
		TestOnePlayerGame();
		$display("All tests completed!");
	end
	
endmodule