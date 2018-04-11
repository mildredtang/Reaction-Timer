`timescale 1ns / 1ps

module LCG(
	input wire clk,
	input wire reset,
	input wire [1:0] state,
	output wire [31:0] randomNumber
	);

	parameter integer multiplier = 32'h41C64E6D; //using ANSI C source for linear congruential generator
    parameter integer increment = 32'h3039;

    reg [31:0] seed = 32'b0;
    
    always @(posedge clk) begin
    	if (state == 2'b00) begin // state == IDLE
	        if (reset) begin
	            seed <= 32'b0;
	        end else begin
	            seed <= multiplier * seed + increment; // mod function is not needed in this case as is had been already done in Verilog
	        end
	    end
    end

    assign randomNumber = {19'd0, seed[31:19]}; //only the right-most 13 bits are needed to represent number in range of 1-5000ms

endmodule