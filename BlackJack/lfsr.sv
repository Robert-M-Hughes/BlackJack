module lfsr (
    input logic clk,
    output logic [5:0] out
);
	
	// Internal registers
	/*logic [6:0] registers = 6'b1;
	assign out = registers[5:0];
	
	// Determine next value
	logic linear_feedback;
   assign linear_feedback =  ! (registers[5] ^ registers[3]);
	
	always_ff @(posedge clk) begin
		registers <= {registers[5], registers[4], registers[3], registers[2],registers[1], registers[0], linear_feedback};
	end*/

	// Internal registers
	logic [5:0] registers = 6'b1;
	assign out = registers;
	
	always_ff @(posedge clk) begin
		registers <= registers + 1;
	end
endmodule