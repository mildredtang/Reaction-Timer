`timescale 1ns / 1ps

module reactionTimer_TOP(
    input wire clk, 
    input wire resetRaw, // raw input button of reset, need to be debounced
    input wire triggerPreRaw, // raw trigger button from IDLE to PREPARATION state, need to be debounced
    input wire reactionButtonRaw, // raw input button of user reaction button, need to be debounced
    output reg [7:0] ssdCathode = 8'hFF,
    output reg [7:0] ssdAnode = 8'hFF,
    output reg [15:0] led = 16'd0);

    // instantiate debouncer to obtain stable signals
    wire reset, triggerPre, triggerTest, reactionButton; // debounced buttons

    debouncer reset_debouncer(
        .clk(clk),
        .buttonIn(resetRaw),
        .buttonOut(reset) // debounced reset signal
    );
    
    debouncer triggerPre_debouncer(
        .clk(clk),
        .buttonIn(triggerPreRaw),
        .buttonOut(triggerPre) // debounced triggerPre signal
    );
    
    debouncer reactionButton_debouncer(
        .clk(clk),
        .buttonIn(reactionButtonRaw),
        .buttonOut(reactionButton) // debounced reactionButton
    );
              

    // construct a FSM for the four states: IDLE, PREPARATION, TEST, RESULT

    parameter IDLE = 2'b00,
                PREPARATION = 2'b01,
                TEST = 2'b10,
                RESULT = 2'b11;

    reg [1:0] state = IDLE;
    wire [7:0] resultCathode, resultAnode;
    wire [7:0] prepareCathode, prepareAnode;

    wire [3:0] rt_d0; //reaction time of the user. record the number from the rightmost to leftmost respectively by d0 to d3
    wire [3:0] rt_d1;
    wire [3:0] rt_d2;
    wire [3:0] rt_d3;
    wire startTesting;
    time_Accumulator reactionTimer(
        .clk(clk),
        .reset(resetRaw),
        .startWorking(startTesting),
        .reactionButton(reactionButton),
        .rt_d0(rt_d0),
        .rt_d1(rt_d1),
        .rt_d2(rt_d2),
        .rt_d3(rt_d3));
    
    wire testFail;
    test stateTest(
        .clk(clk),
        .reset(reset),
        .reactionButton(reactionButton),
        .startWorking(state == TEST),
        .startTesting(startTesting),
        .testFail(testFail));

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            ssdCathode <= 8'hFF;
            ssdAnode <= 8'hFF;
        end else begin
            case (state)
                IDLE : begin
                    if (triggerPre) begin
                         state <= PREPARATION;
                    end
                    // No SSD Output.
                    ssdCathode <= 8'hFF;
                    ssdAnode <= 8'hFF;
                    led <= 16'd0;
                end
                PREPARATION : begin
                    if (triggerTest) begin
                        state <= TEST;
                    end
                    // Output the PREPARE data.
                    ssdCathode <= prepareCathode;
                    ssdAnode <= prepareAnode;
                    led <= 16'd0;
                end
                TEST : begin 
                    if (reactionButton) begin
                        state <= RESULT;
                    end
                    // No SSD Output.
                    ssdCathode <= 8'hFF;
                    ssdAnode <= 8'hFF;
                    led <= {16{startTesting}};
                end
                RESULT : begin
                    // Output the Result data.
                    ssdCathode <= resultCathode;
                    ssdAnode <= resultAnode;
                    led <= 16'd0;
                end
                 default : begin
                     state <= IDLE;
                 end
            endcase
        end
    end
    
    result finalResult(
        .rt_d0(rt_d0),
        .rt_d1(rt_d1),
        .rt_d2(rt_d2),
        .rt_d3(rt_d3),
        .testFail(testFail),
        .clk(clk),
        .reset(reset),
        .ssdCathode(resultCathode),
        .ssdAnode(resultAnode)
    );
    
    countingDown COUNT_DOWN(
        .clk(clk),
        .reset(reset),
        .startWorking(state == PREPARATION),
        .ssdCathode(prepareCathode),
        .ssdAnode(prepareAnode),
        .triggerTest(triggerTest)
    );
    
    //assign ssdCathode = (state == PREPARATION) ? prepareCathode : resultCathode;
    //assign ssdAnode = (state == PREPARATION) ? prepareAnode : resultAnode;
    
endmodule

