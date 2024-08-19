`timescale 1ns / 1ps

module ultrasonic_top(
    input clk,
    input reset,
    input echo,

    output trig,
    output [13:0] echo_cnt_out
);

wire w_tick_1us;
wire w_tick_15us;
wire w_echo_cnt_en;
wire w_echo_cnt_reset;
wire [19:0] w_echo_cnt;

// 100ms period & 15us trigger
clk_div_trigger U_clk_div_trigger(
    .clk(clk),
    .reset(reset),
    .o_clk(w_tick_15us)
);

// Make tick(1us)
clk_div #(
    .HZ(1_000_000)  // 1us 분주
) ECHO_1us( 
    .clk(clk),
    .reset(reset),

    .o_clk(w_tick_1us)
);

// Count Echo(cm)
Echo_Counter ECHO_CNT( 
    .clk(clk),
    .tick_1us(w_tick_1us),
    .reset(reset),
    .echo_cnt_en(w_echo_cnt_en),
    .echo_cnt_reset(w_echo_cnt_reset),
    
    .count(w_echo_cnt)
);

// Ultra_Sonic FSM
ultra_sonic_fsm U_ultra_sonic_fsm(
    .clk(clk),
    .reset(reset),
    .trig(w_tick_15us), 
    .echo(echo),            // echo pin 
    .echo_cnt(w_echo_cnt),
    //
    .tick_15us(trig),       // trig pin
    .echo_cnt_en(w_echo_cnt_en),    
    .echo_cnt_reset(w_echo_cnt_reset),
    .echo_cnt_out(echo_cnt_out)
);
endmodule