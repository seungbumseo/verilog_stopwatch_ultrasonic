`timescale 1ns / 1ps

module ultra_sonic_fsm(
    input clk,
    input reset,
    input trig,             // 15us trigger
    input echo,             // echo pin
    input [19:0] echo_cnt,

    output tick_15us,       // trig pin
    output echo_cnt_en,     // for echo cnt
    output echo_cnt_reset,  // for echo cnt reset
    output [13:0] echo_cnt_out
);

parameter IDLE = 2'd0, WAIT = 2'd1, CHECK = 2'd2;

wire trig_edge_fall;        // trigger falling edge

reg [1:0] state, next_state;
reg trig_pl0, trig_pl1;     // for edge detect
reg [13:0] echo_cnt_reg, echo_cnt_next;
reg echo_cnt_reset_reg, echo_cnt_reset_next;

// output state combinational logic
assign trig_edge_fall = (trig_pl1 & ~trig_pl0);     // trigger falling edge
assign tick_15us = trig;    // wire trigger
assign echo_cnt_en = (state==CHECK) ? 1'b1: 1'b0;
assign echo_cnt_reset = echo_cnt_reset_reg;
assign echo_cnt_out = echo_cnt_reg;


// state register
always @(posedge clk, posedge reset) begin
    if(reset) begin
        state <= IDLE;
        trig_pl0 <= 1'b0; trig_pl1 <= 1'b0;
        echo_cnt_reg <= 0;
        echo_cnt_reset_reg <= 1'b0;
    end else begin
        state <= next_state;
        trig_pl0 <= trig; trig_pl1 <= trig_pl0;
        echo_cnt_reg <= echo_cnt_next;
        echo_cnt_reset_reg <= echo_cnt_reset_next;
    end
end


// next state combinational logic
always @(*) begin
    next_state = state;
    echo_cnt_next = echo_cnt_reg;
    echo_cnt_reset_next = echo_cnt_reset_reg;
    case(state)
        IDLE: begin
            if(trig_edge_fall) begin    // trigger falling edge
                next_state = WAIT;
                echo_cnt_reset_next = 1'b1;     // echo counter reset
            end else begin
                next_state = IDLE;
            end
        end
        WAIT: begin
            if(echo) begin      // echo = 1
                next_state = CHECK;
                echo_cnt_reset_next = 1'b0;
            end else begin
                next_state = WAIT;
            end
        end
        CHECK: begin
            if(~echo) begin     // echo = 0
                next_state = IDLE;
                echo_cnt_next = echo_cnt;
            end
            else begin
                next_state = CHECK;
            end
        end
        default: next_state = state;
    endcase
end

endmodule


