`timescale 1ns / 1ps

module Stopwatch_cnt (
    input clk,
    input reset,
    input tick, //100hz
    input enable, 
    input clear,
    input sel,  // run_md
    
    output [13:0] count
);

wire w_carry_cnt0, w_carry_cnt1, w_carry_cnt2;
wire [$clog2(100)-1:0] w_ms_count;  // 6:0
wire [$clog2(60)-1:0] w_sec_count;    // 5:0
wire [$clog2(60)-1:0] w_min_count;    // 5:0
wire [$clog2(12)-1:0] w_hour_count;   // 3:0
wire [13:0] y1, y2;

clk_counter #(
    .CNT(100)   // 100진 카운터
) cnt_ms( 
    .clk(clk),
    .reset(reset),
    .i_tick(tick),
    .enable(enable),
    .clear(clear),
    //
    .count(w_ms_count),
    .o_tick(w_carry_cnt0)
);

clk_counter #(
    .CNT(60)   // 60진 카운터
) cnt_sec( 
    .clk(clk),
    .reset(reset),
    .i_tick(w_carry_cnt0),
    .enable(enable),
    .clear(clear),
    //
    .count(w_sec_count),
    .o_tick(w_carry_cnt1)
);

clk_counter #(
    .CNT(60)   // 60진 카운터
) cnt_min( 
    .clk(clk),
    .reset(reset),
    .i_tick(w_carry_cnt1),
    .enable(enable),
    .clear(clear),
    //
    .count(w_min_count),
    .o_tick(w_carry_cnt2)
);

clk_counter #(
    .CNT(12)   // 12진 카운터
) cnt_hour( 
    .clk(clk),
    .reset(reset),
    .i_tick(w_carry_cnt2),
    .enable(enable),
    .clear(clear),
    //
    .count(w_hour_count),
    .o_tick()
);

// x 100 필요
mux_2x1 #(
    .array(14)
) mux1 (
    .sel(sel), 
    .x0({8'b0,w_sec_count}),
    .x1({10'b0,w_hour_count}),
    //
    .y(y1)
);

mux_2x1 #(
    .array(14)
) mux2 (
    .sel(sel), 
    .x0({7'b0,w_ms_count}),
    .x1({8'b0,w_min_count}),
    //
    .y(y2)
);

array_operations U_array_operations(
    .array1(y1),     // 8비트 배열 입력 1
    .array2(y2),     // 8비트 배열 입력 2
    //
    .result(count)     // array1 + array2 결과
);

endmodule


module array_operations(
    input [13:0] array1,  // 14-bit array input 1
    input [13:0] array2,  // 14-bit array input 2
    
    output reg [13:0] result  // result = array1 * 100 + array2
);

reg [13:0] result1;

always @(*) begin
    // Multiply array1 by 100 using bit shifting
    result1 = (array1 << 6) + (array1 << 5) + (array1 << 2);

    // Add result1 and array2 to get the final result
    result = result1 + array2;
end

endmodule
