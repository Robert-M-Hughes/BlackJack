module simpleDualPortMemory(
    input logic clk, enW,
    input logic [3:0] addrW, addrR,
    input logic [12:0] dataW,
    output logic [12:0] dataR
);
    
    // Create memory
    logic [12:0] memory [3:0];

    // Write on enable write and read data
    always_ff @(posedge clk) begin
        if(enW) begin
            memory[addrW] <= dataW;
        end

        dataR <= memory[addrR];
    end
endmodule