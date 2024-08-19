`timescale 1ns / 1ps


// clock divider
module clk_div #(
    parameter HZ = 1000
)( 
    input  clk,
    input  reset,
    output o_clk
);
    reg [$clog2(100_000_000/HZ)-1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 0;
        end else begin
            if (r_counter == 100_000_000/HZ - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end
    
endmodule


// clock divder(100ms) for Ultra_Sonic trigger signal
module clk_div_trigger(
    input  clk,
    input  reset,
    output o_clk
);
    reg [$clog2(100_000_000/5)-1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 0;
        end else begin
            if (r_counter >= 100_000_000/5 - 1) begin
                r_counter <= 0;
                r_clk <= 1'b0;
            end else if(r_counter >= 100_000_000/5 - 1500) begin   // 15us
                r_clk <= 1'b1;
                r_counter <= r_counter + 1;
            end else begin
                r_clk <= 1'b0;
                r_counter <= r_counter + 1;
            end
        end
    end
    
endmodule