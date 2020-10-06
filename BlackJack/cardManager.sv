module cardManager(
    input logic clk, reset,
    input logic [1:0] userSelect,
    input logic [3:0] card,
    output logic cardsUpdated,
    output logic [4:0] p1_high, p1_low, p2_high, p2_low, d_high, d_low
);
    
    // Track previous userSelect
    logic [1:0] prevUserSelect = 0;

    // Create hands memory
    logic [3:0][9:0] hands  = 0;
    assign p1_high = hands[0][9:5];
    assign p1_low = hands[0][4:0];
    assign p2_high = hands[1][9:5];
    assign p2_low = hands[1][4:0];
    assign d_high = hands[2][9:5];
    assign d_low = hands[2][4:0];
	 
	 // Determine current low
	 logic [4:0] high, low;
	 assign high = userSelect == 1 ? p1_high : (userSelect == 2 ? p2_high : d_high);
	 assign low = userSelect == 1 ? p1_low : (userSelect == 2 ? p2_low : d_low);
	 
    // Write on enable write and read data
    always_ff @(posedge clk) begin		  
		  // Handle based off user select
        if(reset == 1) begin
				$display("(%0d) Resetting manager", $time);
				hands = 0;
		  end
		  else if(userSelect == 0) begin
			
            // Set cardsUpdated flag
            cardsUpdated <= 0;
        end
        else if(userSelect > 0 && card > 0 && cardsUpdated != 1) begin
            if (low !== 0 && card !== 1) begin
                // If Ace has been drawn previously

					 if(high <= 21) begin
						hands[userSelect-1][9:5] <= hands[userSelect-1][9:5] + card;
					 end
					 if(low <= 21) begin
						hands[userSelect-1][4:0] <= hands[userSelect-1][4:0] + card;
					 end
            end
				else if(card == 1) begin
                // If Ace is drawn

                if(high <= 21) begin
						hands[userSelect-1][9:5] <= hands[userSelect-1][9:5] + 11;
					 end
					 if(low == 0) begin
						hands[userSelect-1][4:0] <= hands[userSelect-1][9:5] + 1;
					 end
					 else if(low <= 21) begin
						hands[userSelect-1][4:0] <= hands[userSelect-1][4:0] + 1;
					 end
            end
            else begin
                // If no Ace has been drawn

                if(high <= 21) begin
						hands[userSelect-1][9:5] <= hands[userSelect-1][9:5] + card;
					 end
            end

            // Set cardsUpdated flag
            cardsUpdated <= 1;
        end
		  else begin
			//$display("(%0d) userSelect(%d) card(%d)", $time, userSelect, card);
		  end

        // Update prevUserSelect
        prevUserSelect <= userSelect;
    end
endmodule