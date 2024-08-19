`timescale 1ns / 1ps

module button(
    input  clk, 
    input  reset,
    input  i_btn, 
    output o_btn
    );

    reg [3:0] shiftReg; // shift register
    reg [1:0] edgeReg; 
    reg [$clog2(100_000)-1 : 0] r_counter;
    reg r_clk_1khz;

    wire w_shift;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
            r_clk_1khz <= 1'b0;
        end
        else begin
            if (r_counter == 100_000-1) begin
            // if (r_counter == 2-1) begin
                r_counter <= 0;
                r_clk_1khz <= 1'b1;
            end
            else begin
                r_counter <= r_counter + 1;
                r_clk_1khz <= 1'b0;
            end
        end
    end

    always @ (posedge r_clk_1khz, posedge reset) begin
        if (reset) begin
            shiftReg <= 0;
        end
        else begin
            shiftReg <= {i_btn, shiftReg[3:1]};   // left: msb
        end
    end

    assign w_shift = &shiftReg;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            edgeReg <= 0;
        end
        else begin
            edgeReg[0] <= w_shift;
            edgeReg[1] <= edgeReg[0];
        end
    end

    assign o_btn = edgeReg[0] & ~edgeReg[1];

endmodule
