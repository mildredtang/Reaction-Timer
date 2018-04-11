`timescale 1ns / 1ps

module result(
    input wire [3:0] rt_d0,
    input wire [3:0] rt_d1,
    input wire [3:0] rt_d2,
    input wire [3:0] rt_d3,
	input wire clk,
	input wire testFail,
	input wire reset,
    output wire [7:0] ssdCathode,
    output reg [7:0] ssdAnode = 8'hFF
	);
	
	reg [3:0] display;
	reg [2:0] activeDisplay;
    wire clk_1kHz, clk_1kHz_risingEdge;

	always @(posedge clk) begin
        if (reset) begin
            ssdAnode <= 8'hFF;
        end else begin
            if (testFail == 1'b0) begin
                case(activeDisplay)
                    3'd0 : begin
                        display <= rt_d0; //rightmost ssd
                        ssdAnode <= 8'b1111_1110;
                    end
                    3'd1 : begin
                        display <= rt_d1;
                        ssdAnode <= 8'b1111_1101;
                    end
                    3'd2 : begin
                        display <= rt_d2;
                        ssdAnode <= 8'b1111_1011;
                    end
                    3'd3 : begin
                        display <= rt_d3;
                        ssdAnode <= 8'b1111_0111;
                    end
                    3'd4 : begin //only the decimal point is lightening up
                        display <= 4'd10;
                        ssdAnode <= 8'b1111_0111;
                    end
                    default : begin //nothing lightening up
                        display <= 4'd15;
                        ssdAnode <= 8'b1111_1111;
                    end
                endcase
            end else begin
                // Have data to be output
                case (activeDisplay)
                    3'd0 : begin
                        display <= 4'd11; // 'F'
                        ssdAnode <= 8'b1111_0111;
                    end
                    3'd1 : begin
                        display <= 4'd12; // 'A'
                        ssdAnode <= 8'b1111_1011;
                    end
                    3'd2 : begin
                        display <= 4'd13; // 'I'
                        ssdAnode <= 8'b1111_1101;
                    end
                    3'd3 : begin
                        display <= 4'd14; // 'L'
                        ssdAnode <= 8'b1111_1110;
                    end
                    default : begin //nothing lightening up
                        display <= 4'd15;
                        ssdAnode <= 8'b1111_1111;
                    end
                endcase
            end
        end
	end
    
    clockDivider #(
        .THRESHOLD(50_000)
    ) CLOCK_1KHZ (
        .clk(clk),
        .reset(reset),
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
    
    always @(posedge clk) begin
        if (clk_1kHz_risingEdge) begin
            activeDisplay <= activeDisplay + 1;
        end
    end

    sevenSegmentDecoder BCD_TO_SSD(
       .bcd(display),
       .ssd(ssdCathode)
    );

endmodule