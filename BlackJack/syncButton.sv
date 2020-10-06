module syncButton(
	input logic clk, in,
	output logic out
);

	logic internalSig1, internalSig2, syncSig;

	always_ff @(posedge clk) begin
		internalSig1 <= in;
		internalSig2 <= internalSig1;
		syncSig <= internalSig2;
	end
	
	// Triggers on rising edge
	assign out = syncSig & !internalSig2;
endmodule