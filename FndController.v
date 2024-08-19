`timescale 1ns / 1ps

module FndController (
    input clk,
    input reset,
    input [13:0] digit, 
    input echo,                 // echo pin
    input mode,
    output [3:0] fndCom, 
    output [7:0] fndFont
);
    wire w_clk_1khz;
    wire [1:0] w_select;
    wire [3:0] w_digit, w_dig_1, w_dig_10, w_dig_100, w_dig_1000;
    wire [13:0] w_digit_ultra_sonic;
    wire dot_pls;
    wire [3:0] i_fndcom;
    wire [7:0] i_fndfont;
    

clkDiv U_ClkDiv(
    .clk(clk),
    .reset(reset), 
    //
    .o_clk(w_clk_1khz)
);

counter U_counter(
    .clk(w_clk_1khz),
    .reset(reset),
    //
    .count(w_select)
);

clkDiv_dot U_clkDiv_dot(
    .clk(clk),
    .reset(reset), 
    .tick_1ms(w_clk_1khz),
    //
    .o_clk(dot_pls)
);

decoder_2x4 U_Decoder_2x4(
    .x(w_select),
    .y(i_fndcom)
);

digitSplitter U_DigSplitter(
    .x(digit),  // mux ë¡? ?“¤?–´ê°??•¼ ê² ë„¤
    //
    .dig_1(w_dig_1),
    .dig_10(w_dig_10),
    .dig_100(w_dig_100),
    .dig_1000(w_dig_1000)
);

mux_4x1 U_Mux_4x1(
    .sel(w_select),
    .x0(w_dig_1),
    .x1(w_dig_10),
    .x2(w_dig_100),
    .x3(w_dig_1000),
    //
    .y(w_digit)
);

BCD2SEG U_Bcd2Seg(
    .bcd(w_digit),
    //
    .seg(i_fndfont)
);

Make_Dot U_Make_Dot(
    .i_fndcom(i_fndcom),
    .i_fndfont(i_fndfont),
    .dot_pls(dot_pls),
    .sel(mode),
    //.reset(reset),

    .o_fndcom(fndCom),
    .o_fndfont(fndFont)
    );

endmodule 