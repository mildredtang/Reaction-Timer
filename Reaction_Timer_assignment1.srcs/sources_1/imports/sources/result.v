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
 //   wire clk_5Hz, clk_5Hz_risingEdge;

//    reg triggerBR; //= 1'b0; // decide if the most recent reaction time is the fastest record
//    reg [3:0] br_d0 = 4'd9; //best record of reaction time. record the number from the rightmost to leftmost respectively by d0 to d3
//    reg [3:0] br_d1 = 4'd9;
//    reg [3:0] br_d2 = 4'd9;
//    reg [3:0] br_d3 = 4'd9;

	always @(posedge clk) begin
        if (reset) begin
            ssdAnode <= 8'hFF;
        end else begin
            if (testFail) begin
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
            end else begin
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
            end
        end
	end

//    always @(*) begin
//        if (reset) begin
//            br_d0 <= br_d0;
//            br_d1 <= br_d1;
//            br_d2 <= br_d2;
//            br_d3 <= br_d3;
//            triggerBR <= 1'b0;
//        end else begin
//            if (~testFail) begin
//                if (br_d3 > rt_d3) begin
//                    br_d0 <= rt_d0;
//                    br_d1 <= rt_d1;
//                    br_d2 <= rt_d2;
//                    br_d3 <= rt_d3;
//                    triggerBR <= 1'b0;
//                end else if (rt_d3 == br_d3) begin
//                    if (br_d2 > rt_d2) begin
//                        br_d0 <= rt_d0;
//                        br_d1 <= rt_d1;
//                        br_d2 <= rt_d2;
//                        br_d3 <= rt_d3;
//                        triggerBR <= 1'b0;
//                    end else if (rt_d2 == br_d2) begin
//                        if (br_d1 > rt_d1) begin
//                            br_d0 <= rt_d0;
//                            br_d1 <= rt_d1;
//                            br_d2 <= rt_d2;
//                            br_d3 <= rt_d3;
//                            triggerBR <= 1'b0;
//                        end else if (rt_d1 == br_d1) begin
//                            if (br_d0 > rt_d0) begin
//                                br_d0 <= rt_d0;
//                                br_d1 <= rt_d1;
//                                br_d2 <= rt_d2;
//                                br_d3 <= rt_d3;
//                                triggerBR <= 1'b0;
//                            end
//                        end
//                    end
//                end else begin
//                    triggerBR <= 1'b1;
//                end
//            end
//        end
//    end
    
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

//    clockDivider #(
//        .THRESHOLD(10_000_000) // 5Hz
//    ) CLOCK_5HZ (
//        .clk(clk),
//        .reset(reset),
//        .enable(1'b1),
//        .dividedClk(clk_5Hz)
//    );

//    edgeDetector CLOCK_5HZ_EDGE (   
//        .clk(clk),
//        .signalIn(clk_5Hz),
//        .signalOut(),
//        .risingEdge(clk_5Hz_risingEdge),  
//        .fallingEdge()
//    );
    
    always @(posedge clk) begin
//        if (triggerBR == 1) begin
//            if (clk_5Hz_risingEdge) begin // flash the best record if it is the best record
//                activeDisplay <= activeDisplay + 1;
//            end
//        end else begin
        if (clk_1kHz_risingEdge) begin // display the reaction time if it is not the best record
            activeDisplay <= activeDisplay + 1;
        end
    end
//    end

    sevenSegmentDecoder BCD_TO_SSD(
       .bcd(display),
       .ssd(ssdCathode)
    );

endmodule
