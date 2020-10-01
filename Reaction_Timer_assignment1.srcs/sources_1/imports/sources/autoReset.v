`timescale 1ns / 1ps

module autoReset #(
    parameter integer THRESHOLD = 4'd10
)(
	input wire clk,
	input wire reset,
	input wire startWorking,
	input wire stopWorking,
	output reg timeOut //= 1'b0
	);

	reg [31:0] counter = 32'b0;
	wire clk_1Hz, clk_1Hz_risingEdge;

	always @(posedge clk) begin
		if (reset) begin
			counter <= 16'b0;
			timeOut <= 1'b0;
		end else begin
			if (startWorking & clk_1Hz_risingEdge) begin
				counter <= counter + 1;
				if (counter == THRESHOLD) begin
					counter <= 16'b0;
					timeOut <= 1'b1;
				end
	
	        end else if (stopWorking == 1) begin
                    counter <= 16'b0;
                    timeOut <= 1'b0;
            end
		end 
	end

    clockDivider #(
            .THRESHOLD(50_000_000)
        )CLOCK_1Hz_generator(
            .clk(clk),
            .reset(reset),
            .enable(1'b1),
            .dividedClk(clk_1Hz)
        );
        
    edgeDetector Clock_1Hz_EDGE(
        .clk(clk),
        .signalIn(clk_1Hz),
        .signalOut(),
        .risingEdge(clk_1Hz_risingEdge),
        .fallingEdge()
    );


endmodule