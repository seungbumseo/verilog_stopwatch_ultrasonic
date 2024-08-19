`timescale 1ns / 1ps

module Top_button(
    input clk,
    input reset,
    input btn_run_stop,
    input btn_clear,
    input btn_run_md,

    output o_btn_run_stop,
    output o_btn_clear,
    output o_btn_run_md
    );

button U_button_RunStop(
    .clk(clk),    
    .reset(reset),
    .i_btn(btn_run_stop),
    //
    .o_btn(o_btn_run_stop)
);

button U_button_Clear(
    .clk(clk),    
    .reset(reset),
    .i_btn(btn_clear),
    //
    .o_btn(o_btn_clear)
);

button U_button_RunMode(
    .clk(clk),    
    .reset(reset),
    .i_btn(btn_run_md),
    //
    .o_btn(o_btn_run_md)
);

endmodule
