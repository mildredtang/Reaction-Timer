`timescale 1ns / 1ps

module clockDivider #(
    parameter integer THRESHOLD = 50_000
)(
    input wire clk,
    input wire reset,
    input wire enable,
    output reg dividedClk
    );
    
    reg [31:0] counter = 32'd0; // 1Hz
    
    always @(posedge clk) begin
        if (reset == 1 || counter >= THRESHOLD -1) begin
            counter = 0;
        end else if (enable == 1) begin
            counter = counter + 1;
        end
    end
    
    always @(posedge clk) begin
        if (reset == 1) begin
            dividedClk = 0;
        end else if (counter >= THRESHOLD - 1) begin
            dividedClk = ~dividedClk;
        end
    end
    
    
endmodule
