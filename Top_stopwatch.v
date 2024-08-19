`timescale 1ns / 1ps

module Top_stopwatch (
    input clk,
    input reset,
    //input enable,
    //input clear,
    input btn_run_stop,
    input btn_clear,
    input btn_run_md,
    //input sel,  // RUN_MODE Change
    input rx,

    output tx,
    output [13:0] count
);

    wire w_tick_100hz;

    wire w_btn_run_stop, w_btn_clear, w_btn_run_md;  // add
    wire w_enable, w_clear, w_rd_en, w_run_md;
    wire w_rx_done;
    wire w_rx_fifo_empty; 
    wire [7:0] w_rx_fifo_data;
    wire [7:0] w_rx_data;
    wire w_rx_fifo_rd_en; 

    clk_div #(
        .HZ(100)        // 100hz
    ) clk_div_stopwatch ( 
        .clk(clk),
        .reset(reset),
        .o_clk(w_tick_100hz)
    );

    // Stop_watch Counter
    Stopwatch_cnt U_Stopwatch_cnt (
        .clk  (clk),
        .reset(reset),
        .tick(w_tick_100hz),
        .enable(w_enable),
        .clear(w_clear),
        .sel(w_run_md),

        .count(count)
    );

    // StopWatch FSM
    fsm_Stopwatch U_fsm_Stopwatch(
        .clk(clk),
        .reset(reset),
        .sw0(btn_run_stop),
        .sw1(btn_clear),
        .btn_run_md(btn_run_md),
        .rx_data(w_rx_fifo_data),
        .rx_done(~w_rx_fifo_empty),
        
        .enable(w_enable),
        .clear(w_clear),
        .rd_en(w_rd_en),
        .run_md(w_run_md)
    );

    // Uart for Stop_Watch
    uart U_uart(
        .clk(clk),
        .reset(reset),
        .start(w_rx_done),
        .tx_data(w_rx_data),
        .tx_done(),
        .tx(tx),
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    // FIFO
    FIFO #(
        .ADDR_WIDTH(3),
        .DATA_WIDTH(8)
    ) U_RxFifo(
        .clk(clk),
        .reset(reset),
        .wr(w_rx_done),
        .full(),
        .wr_data(w_rx_data),
        .rd(w_rd_en),
        .empty(w_rx_fifo_empty),
        .rd_data(w_rx_fifo_data)
    );

endmodule