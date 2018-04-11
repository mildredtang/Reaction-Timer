`timescale 1ns / 1ps

module test(
    input wire clk,
	input wire reset,
	input wire startWorking,
	input wire reactionButton,
	output reg startTesting = 1'b0,
	output reg testFail = 1'b0 // 1 indicates failure and 0 indicates success
	);

    parameter IDLE = 0;
    parameter BUSY = 1;
    reg state = IDLE;

	wire clk_1kHz, clk_1kHz_risingEdge; // the required accuracy of time is in ms, hence 1kHz clock is used
	reg [31:0] timeCounter = 32'b0; // indicates time flow, used for comparison with random number

    wire [31:0] randomNumber;

    LCG randomNumberGenerator(
        .clk(clk),
        .reset(reset),
        .state(state),
        .randomNumber(randomNumber));
        
    reg [31:0] tweakRandomNumber = 32'd0;

    always @(posedge clk) begin
        if (reset) begin
            timeCounter <= 32'd0;
            startTesting <= 1'b0;
            testFail <= 1'b0;
            
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (startWorking) begin
                        state <= BUSY;
                        // Reset the time counter.
                        timeCounter <= 32'd0;
                        testFail <= 1'b0;
                        // Check the random number.
                        if (randomNumber > 32'd5000) begin
                            tweakRandomNumber <= randomNumber & 32'd5000;
                        end else if (randomNumber < 32'd1000) begin
                            tweakRandomNumber <= randomNumber | 32'd1000;
                        end else begin
                            tweakRandomNumber <= randomNumber;
                        end
                    end 
                    startTesting <= 1'b0;
                end
                BUSY: begin
                   if (clk_1kHz_risingEdge) begin
                       if (timeCounter < tweakRandomNumber) begin
                           // Increase the counter.
                           timeCounter <= timeCounter + 1;
                           startTesting <= 1'b0;
                           // If reaction button is pressed.
                           if (reactionButton) begin
                               // Failed.
                               testFail <= 1'b1;
                               // Back to IDLE.
                               state <= IDLE;
                           end
                       end else begin
                           // When reaction button is pressed.
                           if (reactionButton) begin
                                state <= IDLE;
                                // Reach the random number limitation.
                                startTesting <= 1'b0;
                           end else begin
                                // Wait for button pressed.
                                startTesting <= 1'b1;
                                testFail <= 1'b0;
                           end
                       end
                   end 
                end
            endcase
        end
	end

	clockDivider #(
        .THRESHOLD(50_000)
    ) CLOCK_1KHZ (
        .clk(clk),
        .reset(1'b0),
        .enable(1'b1),
        .dividedClk(clk_1kHz)
    );

    edgeDetector CLOCK_1KHZ_EDGE (   
        .clk(clk),
        .signalIn(clk_1kHz),
        .signalOut(),
        .risingEdge(clk_1kHz_risingEdge),  
        .fallingEdge()
    );

endmodule