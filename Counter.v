`timescale 1ns / 1ps

// Stop_Watch Counter for (ms, sec, min, hour)
module clk_counter #(
    parameter CNT = 16
)( 
    input  clk,
    input  reset,
    input  i_tick,
    input  enable,
    input  clear,

    output reg [$clog2(CNT)-1:0] count,
    output reg o_tick
);

    reg pl0, pl1;   // for edge detect
    wire r_edge;    // rising edge

    assign r_edge = pl0 & ~pl1;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            o_tick <= 0;
            pl0 <= 0; pl1 <= 0;
        end else begin
            pl0 <= i_tick; pl1 <= pl0; 
           
            if (enable) begin
                if (r_edge) begin
                    if (count == CNT - 1) begin
                        count <= 0;
                        o_tick <= 1'b1;
                    end else begin
                        count <= count + 1'b1;
                        o_tick <= 1'b0;
                    end
                end
            end else begin
                 if (clear) begin
                    count <= 0;
                    o_tick <= 0;
                    pl0 <= 0; pl1 <= 0;
                end
            end
        end
    end
endmodule


// Echo Pulse Counter
module Echo_Counter (
    input  clk,
    input  tick_1us,
    input  reset,
    input echo_cnt_en,
    input echo_cnt_reset,

    output [19:0] count
);
    reg [15:0] r_counter;
    reg [15:0] cnt_reg;

    assign count = cnt_reg;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            cnt_reg <= 0;
        end else begin
            cnt_reg <= r_counter / 58;
            if(echo_cnt_en) begin
                if(tick_1us) begin
                    if (r_counter == 36_200 - 1) begin//580000
                        r_counter <= 0;
                    end else begin
                        r_counter <= r_counter + 1;
                    end
                end
            end
            else if(echo_cnt_reset) begin
                r_counter <= 0;
            end
        end
    end

endmodule