module fsm(
	input logic clk, hold, hit, holdAI, hitAI, cardsUpdated,
	input logic [4:0] p1_high, p1_low, p2_high, p2_low, d_high, d_low,
	output logic [1:0] userSelect,
	output logic [3:0] currentState
);

	/* States */
	typedef enum {
		SELECT_P1, 		//0
		SELECT_P2,		//1
		INIT,			//2
		TURN_P1,		//3
		DRAW_P1,		//4
		TURN_P2,		//5
		DRAW_P2,		//6
		TURN_D,			//7
		DRAW_D,			//8
		WIN_P1,			//9
		WIN_P2,			//10
		WIN_D			//11
	} statetype;
	statetype state = SELECT_P1, nextState = SELECT_P1;
	assign currentState = state;

	/* Internal Signals */
	
	// Determines if the game is two player
	logic twoPlayer = 1'b0;

	// Keep track of how many cards are initially drawn by each player
	logic [1:0] p1_drawn = 0, p2_drawn = 0, d_drawn = 0;
	
	// Determine the highest valid hand, otherwise is 63
	logic [4:0] p1_best, p2_best, d_best;
	assign p1_best = (p1_high <= 21) ? p1_high : ( (p1_low <= 21 && p1_low != 0) ? p1_low : 6'b111111 );
	assign p2_best = (p2_high <= 21) ? p2_high : ( (p2_low <= 21 && p2_low != 0) ? p2_low : 6'b111111 );
	assign d_best = (d_high <= 21) ? d_high : ( (d_low <= 21 && d_low != 0) ? d_low : 6'b111111 );
	
	// Determine if a player is bust
	logic p1_bust, p2_bust, d_bust;
	assign p1_bust = p1_best === 6'b111111;
	assign p2_bust = p2_best === 6'b111111;
	assign d_bust = d_best === 6'b111111;
	
	/* Set next state and update addresses on positive edge of the clock */
	always_ff @(posedge clk) begin
		
		// Update twoPlayer and drawn vars
		if(state == SELECT_P1 && nextState == INIT) begin
			twoPlayer <= 0;
			p1_drawn <= 0;
			p2_drawn <= 0;
			d_drawn <= 0;
		end
		else if(state == SELECT_P2 && nextState == INIT) begin
			twoPlayer <= 1;
		end
		else if(state == DRAW_P1) begin
			if(state != nextState && p1_drawn != 3) begin
				p1_drawn <= p1_drawn + 1;
			end

			userSelect <= 1;
		end
		else if(state == DRAW_P2) begin
			if(state != nextState && p2_drawn != 3) begin
				p2_drawn <= p2_drawn + 1;
			end

			userSelect <= 2;
		end
		else if(state == DRAW_D) begin
			if(state != nextState && d_drawn != 3) begin
				d_drawn <= d_drawn + 1;
			end

			userSelect <= 3;
		end
		else begin
			userSelect <= 0;
		end
		
		state <= nextState;
	end

	/* Next state logic */
	always_comb begin
		case (state)
			SELECT_P1: begin
            if (hold == 1'b1) begin
					nextState <= SELECT_P2;
				end
				else if (hit == 1'b1) begin
					nextState <= INIT;
				end
				else begin
					nextState <= SELECT_P1;
				end
			end
			SELECT_P2: begin
            if (hold == 1'b1) begin
					nextState <= SELECT_P1;
				end
				else if (hit == 1'b1) begin
					nextState <= INIT;
				end
				else begin
					nextState <= SELECT_P2;
				end
			end
			INIT: begin
				if (p1_drawn < 2) begin
					nextState <= DRAW_P1;
				end
				else if (p2_drawn < 2) begin
					nextState <= DRAW_P2;
				end
				else if (d_drawn < 2) begin
					nextState <= DRAW_D;
				end
				else begin
					nextState <= TURN_P1;
				end
			end
			TURN_P1: begin
				if (p1_best >= 21 || hold == 1'b1) begin
					nextState <= TURN_P2;
				end
				else if (hit == 1'b1) begin
					nextState <= DRAW_P1;
				end
				else begin
					nextState <= TURN_P1;
				end
			end
			DRAW_P1: begin
				if(cardsUpdated) begin
					if (p1_drawn < 2) begin
						nextState <= INIT;
					end
					else begin
						nextState <= TURN_P1;
					end
				end
				else begin
					nextState <= DRAW_P1;
				end
			end
			TURN_P2: begin
				if (p2_best >= 21 || (twoPlayer && hold == 1'b1) || (!twoPlayer && holdAI == 1'b1)) begin
					nextState <= TURN_D;
				end
				else if ((twoPlayer && hit == 1'b1) || (!twoPlayer && hitAI == 1'b1)) begin
					nextState <= DRAW_P2;
				end
				else begin
					nextState <= TURN_P2;
				end
			end
			DRAW_P2: begin
				if(cardsUpdated) begin
					if (p2_drawn < 2) begin
						nextState <= INIT;
					end
					else begin
						nextState <= TURN_P2;
					end
				end
				else begin
					nextState <= DRAW_P2;
				end
			end
			TURN_D: begin
				if (d_best <= 16) begin
					nextState <= DRAW_D;
				end
				else if(!p1_bust && p1_best >= p2_best && p1_best > d_best) begin
					nextState <= WIN_P1;
				end
				else if(!p2_bust && p2_best > p1_best && p2_best > d_best) begin
					nextState <= WIN_P2;
				end
				else begin
					nextState <= WIN_D;
				end
			end
			DRAW_D: begin
				if(cardsUpdated) begin
					if (d_drawn < 2) begin
						nextState <= INIT;
					end
					else begin
						nextState <= TURN_D;
					end
				end
				else begin
					nextState <= DRAW_D;
				end
			end
			WIN_P1, WIN_P2, WIN_D: begin
				if (hold == 1'b1 || hit == 1'b1) begin
					nextState <= SELECT_P1;
				end
				else begin
					nextState <= state;
				end
			end
			default begin
				nextState <= SELECT_P1;
			end
		endcase
	end
endmodule