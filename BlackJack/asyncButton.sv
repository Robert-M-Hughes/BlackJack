module asyncButton(
	input logic clk, in,
	output logic out
);

	logic internalSig1, internalSig2;

	always_ff @(posedge clk or negedge in) begin
		if(!in) begin
			internalSig1 <= 1'b0;
			internalSig2 <= 1'b0;
		end
		else begin
			internalSig1 <= 1'b1;
		end
			
		internalSig2 <= internalSig1;
		out <= internalSig2;
	end
endmodule