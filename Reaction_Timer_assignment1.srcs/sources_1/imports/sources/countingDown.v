`timescale 1ns / 1ps

// Description : Display counter down on seven segment display in PREPARATION state.

module countingDown(
	input wire clk,
	input wire reset,
	input wire startWorking,
    output wire [7:0] ssdCathode,
    output reg [7:0] ssdAnode,
	output reg triggerTest = 1'b0
	);

    reg [3:0] countingDown = 4'd3;
    wire clk_1Hz, clk_1Hz_risingEdge; // used for counting down from 3 to 1 in PREPARATION state

    parameter IDLE = 0;
    parameter COUNTING = 1;
    
    reg countingState = IDLE;

    always @(posedge clk) begin
        if (reset == 1) begin
            countingDown <= 4'd3;
            triggerTest <= 1'b0;
            countingState <= IDLE;
        end else begin
            if (countingState == IDLE)  begin
                // Always let trigger test down.
                if (triggerTest) begin
                    triggerTest <= 1'b0;
                end
                // When you want to countdown.
                if (startWorking) begin
                    // Reset the counting down.
                    countingDown <= 4'd3;
                    // Jump to counting state.
                    countingState <= COUNTING;
                end
            end else begin
                // Only allows the last digit display
                ssdAnode <= 8'b1111_1110;
                // Count down the number
                if (countingDown == 4'd0) begin
                    // Move back to IDLE.
                    countingState <= IDLE;
                    // Enable trigger test.
                    triggerTest <= 1'b1;
                end else if (clk_1Hz_risingEdge) begin
                    countingDown <= countingDown - 1;
                end
            end
        end
    end

    clockDivider #(
        .THRESHOLD(50_000_000)
    )CLOCK_1HZ(
        .clk(clk),
        .reset(1'b0),
        .enable(countingState != IDLE),
        .dividedClk(clk_1Hz)
    );
        
    edgeDetector CLOCK_1HZ_EDGE(
        .clk(clk),
        .signalIn(clk_1Hz),
        .signalOut(),
        .risingEdge(clk_1Hz_risingEdge),
        .fallingEdge()
    );

    sevenSegmentDecoder BCD_TO_SSD(
       .bcd(countingDown),
       .ssd(ssdCathode)
    );

endmodule