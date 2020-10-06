module blackjack(
	input logic clk, hold, hit, resetButton,
	output LEDR[17:0],
	output LEDG[8:0],
    output LCD_ON, LCD_BLON, LCD_RW, LCD_EN, LCD_RS,
    inout [7:0] LCD_DATA
);

    // Internal signals
    logic oclk, reset, syncHold, syncHit, syncResetButton, holdAI, hitAI;
    logic [1:0] userSelect;
	logic [3:0] card, currentState;
    logic [4:0] p1_high, p1_low, p2_high, p2_low, d_high, d_low;
    logic [29:0] numbers;

    // Assignments
	 assign LCD_BLON = 0;
    assign reset = currentState == 0;
    assign numbers[29:25] = d_low;
    assign numbers[24:20] = d_high;
    assign numbers[19:15] = p2_low;
    assign numbers[14:10] = p2_high;
    assign numbers[9:5] = p1_low;
    assign numbers[4:0] = p1_high;
	 
	 assign LEDR[17] = currentState[3];
	 assign LEDR[16] = currentState[2];
	 assign LEDR[15] = currentState[1];
	 assign LEDR[14] = currentState[0];
	 
	 assign LEDR[5] = card[3];
	 assign LEDR[4] = card[2];
	 assign LEDR[3] = card[1];
	 assign LEDR[2] = card[0];
	 assign LEDR[1] = holdAI;
	 assign LEDR[0] = hitAI;
	 
	 assign LEDG[8] = reset;
	 assign LEDG[7] = userSelect[1];
	 assign LEDG[6] = userSelect[0];
	 
	 //assign LEDG[4] = p1_high[4];
	 assign LEDG[3] = card[3];
	 assign LEDG[2] = card[2];
	 assign LEDG[1] = card[1];
	 assign LEDG[0] = card[0];

	 //clockdiv div(.iclk(clk), .oclk(oclk));
	 assign oclk = clk;
	 
    // Connect device(s) to test
    asyncButton xhit(.clk(oclk), .in(resetButton), .out(syncResetButton));
    syncButton xsynchhit(.clk(oclk), .in(hit), .out(syncHit));
    syncButton xhold(.clk(oclk), .in(hold), .out(syncHold));

	fsm xfsm(.clk(oclk), .hold(syncHold), .hit(syncHit), .holdAI(holdAI), .hitAI(hitAI), .cardsUpdated(cardsUpdated), .p1_high(p1_high), .p1_low(p1_low), .p2_high(p2_high), .p2_low(p2_low), .d_high(d_high), .d_low(d_low), .userSelect(userSelect), .currentState(currentState));
	playerAI ai(.clk(oclk), .p_high(p2_high), .p_low(p2_low), .d_high(d_high), .hold(holdAI), .hit(hitAI));
	cardPuller puller(.clk(oclk), .reset(reset), .userSelect(userSelect), .card(card));
	cardManager manager(.clk(oclk), .reset(reset), .userSelect(userSelect), .card(card), .cardsUpdated(cardsUpdated), .p1_high(p1_high), .p1_low(p1_low), .p2_high(p2_high), .p2_low(p2_low), .d_high(d_high), .d_low(d_low));
	lcd_top  xDisp(.CLOCK_50(clk), .reset(syncResetButton), .numbers(numbers), .LCD_ON(LCD_ON), .LCD_RW(LCD_RW), .LCD_EN(LCD_EN), .LCD_RS(LCD_RS), .LCD_DATA(LCD_DATA), .currentState(currentState));

endmodule