module cardPuller(
    input logic clk, reset,
    input logic [1:0] userSelect,
    output logic [3:0] card
);

   // Track when card is pulled
   logic pulled = 0;

   // Stores random numbers
   logic [5:0] randomNumber;

   // Determine random card's suit, type, and value based off random value
   logic [1:0] cardSuit;
   logic [3:0] cardType, cardValue;
   assign cardSuit = randomNumber[5:4];
   assign cardType = randomNumber[3:0];
   assign cardValue = cardType >= 9 ? 10 : cardType + 1;

   // Create card memory
   logic [3:0][12:0] pulledCards  = 0;

   // Devices
   lfsr randGen(.clk(clk), .out(randomNumber));

   // Write on enable write and read data
	always_ff @(posedge clk) begin	
		
		// Handle card pull when userSelect is set
		if(userSelect == 0) begin
			// Disabled
         card <= 0;
         pulled <= 0;
      end
      else if(userSelect > 0 && !pulled && cardType <= 12) begin
			// If card need to be pulled 

			if(!pulledCards[cardSuit][cardType]) begin
				// If can has not been pulled
            
				// Updated card, pulledCards, and pulled
            card <= cardValue;
            pulledCards[cardSuit][cardType] <= 1;
            pulled <= 1;
         end
		end
		
		// Reset deck if reset signal goes high
		if(reset == 1) begin
			$display("(%0d) Resetting puller", $time);
			pulledCards <= 0;
		end
    end
endmodule