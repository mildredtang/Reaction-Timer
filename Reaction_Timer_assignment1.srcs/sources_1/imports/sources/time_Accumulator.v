`timescale 1ns / 1ps

module time_Accumulator(
	input wire clk,
	input wire reset,
	input wire startWorking,
	input wire reactionButton,
	output reg [3:0] rt_d0 = 4'd0, //reaction time of the user. record the number from the rightmost to leftmost respectively by d0 to d3
	output reg [3:0] rt_d1 = 4'd0,
    output reg [3:0] rt_d2 = 4'd0,
    output reg [3:0] rt_d3 = 4'd0);
	
	wire clk_1kHz, clk_1kHz_risingEdge;
	wire testFail; //= 1'b0;
	
	parameter IDLE = 1'b0;
	parameter COUNTING = 1'b1;
	reg state = IDLE;

	always @(posedge clk_1kHz) begin
		if (reset) begin
	        rt_d0 <= 4'd0;
	        rt_d1 <= 4'd0;
	        rt_d2 <= 4'd0;
	        rt_d3 <= 4'd0;
	    end else begin
	        if (startWorking) begin
                 if (rt_d0 == 4'd9) begin //the rightmost bit is 9 and going to increment the left bit
                     rt_d0 <= 4'd0;
                     if (rt_d1 == 4'd9) begin
                         rt_d1 <= 4'd0;
                         if (rt_d2 == 4'd9) begin
                             rt_d2 <= 4'd0;
                             if (rt_d3 == 4'd9) begin
                                 rt_d3 <= 4'd9; // limit the maximum reaction time to 9.999s
                                 rt_d2 <= 4'd9;
                                 rt_d1 <= 4'd9;
                                 rt_d0 <= 4'd9;
                             end else begin
                                 rt_d3 <= rt_d3 + 1;
                             end
                         end else begin
                             rt_d2 <= rt_d2 + 1;
                         end
                     end else begin 
                         rt_d1 <= rt_d1 + 1;
                     end
                 end else begin
                     rt_d0 <= rt_d0 + 1;
                 end
            end
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