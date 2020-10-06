module lcd_top(
  input CLOCK_50,    //    50 MHz clock
  input  reset,      //    Pushbutton[3:0]
  input [29:0] numbers, //the numbers given by the system,
  input [3:0] currentState,
  output LCD_ON,    // LCD Power ON/OFF
  output LCD_BLON,    // LCD Back Light ON/OFF
  output LCD_RW,    // LCD Read/Write Select, 0 = Write, 1 = Read
  output LCD_EN,    // LCD Enable
  output LCD_RS,    // LCD Command/Data Select, 0 = Command, 1 = Data
  inout [7:0] LCD_DATA    // LCD Data bus 8 bits
);

//    All inout port turn to tri-state
//assign    GPIO_0        =    36'hzzzzzzzzz;
//assign    GPIO_1        =    36'hzzzzzzzzz;

logic [6:0] myclock;
logic RST;
assign RST = reset;

// reset delay gives some time for peripherals to initialize
logic DLY_RST;
Reset_Delay r0(    .iCLK(CLOCK_50),.oRESET(DLY_RST) );

// Send numbersitches to red leds 
//assign LEDR = numbers;

// turn LCD ON
assign    LCD_ON        =    1'b1;
assign    LCD_BLON    =    1'b1;

logic[4:0] p1max_ones;
logic[4:0] p1max_tens;
logic[4:0] p1min_ones;
logic[4:0] p1min_tens;
logic[4:0] p2max_ones;
logic[4:0] p2max_tens;
logic[4:0] p2min_ones;
logic[4:0] p2min_tens;
logic[4:0] dmax_ones;
logic[4:0] dmax_tens;
logic[4:0] dmin_ones;
logic[4:0] dmin_tens;

assign p1max_ones = numbers[4:0] % 10; // do this for the max and min of each of the values to send in
assign p1max_tens = numbers[4:0] / 10;
assign p1min_ones = numbers[9:5] % 10; // do this for the max and min of each of the values to send in
assign p1min_tens = numbers[9:5] / 10;

assign p2max_ones = numbers[14:10] % 10; // do this for the max and min of each of the values to send in
assign p2max_tens = numbers[14:10] / 10;
assign p2min_ones = numbers[19:15] % 10; // do this for the max and min of each of the values to send in
assign p2min_tens = numbers[19:15] / 10;

assign dmax_ones = numbers[24:20] % 10; // do this for the max and min of each of the values to send in
assign dmax_tens = numbers[24:20] / 10;
assign dmin_ones = numbers[29:25] % 10; // do this for the max and min of each of the values to send in
assign dmin_tens = numbers[29:25] / 10;



LCD_Display u1(
// Host Side
   .iCLK_50MHZ(CLOCK_50),
   .iRST_N(DLY_RST),
   .dmax_ones(dmax_ones),
   .dmax_tens(dmax_tens),
	.p1max_ones(p1max_ones),
	.p1max_tens(p1max_tens),
	.p1min_ones(p1min_ones),
	.p1min_tens(p1min_tens),
	.p2max_ones(p2max_ones),
	.p2max_tens(p2max_tens),
	.p2min_ones(p2min_ones),
	.p2min_tens(p2min_tens),
  .currentState(currentState),
// LCD Side
   .DATA_BUS(LCD_DATA),
   .LCD_RW(LCD_RW),
   .LCD_E(LCD_EN),
   .LCD_RS(LCD_RS)
);




endmodule