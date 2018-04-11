`timescale 1ns / 1ps

module edgeDetector(
    input wire clk,
    input wire signalIn,
    output wire signalOut,
    output reg risingEdge,
    output reg fallingEdge
    );
    
    reg [1:0] pipeline;
    
    always @(posedge clk) begin
        pipeline[0] <= signalIn;
        pipeline[1] <= pipeline[0];
    end
    
    always @(*) begin
        if (pipeline[0] == 1 && pipeline[1] == 0) begin
            risingEdge <= 1; //try to change to 1'b1 // try to change to risingEdge = 1
        end else if (pipeline[0] == 0 && pipeline[1] == 1) begin
            fallingEdge <= 1;
        end else begin
            risingEdge <= 0;
            fallingEdge <= 0;
        end
    end
    
    assign signalOut = pipeline[1];
    
            
    
endmodule
