`timescale 1ns / 1ps

module Make_Dot(
    input [3:0] i_fndcom,
    input [7:0] i_fndfont,
    input dot_pls,
    input sel,

    output [3:0] o_fndcom,
    output [7:0] o_fndfont
    );

    reg [7:0] o_fndfont_reg;

    assign o_fndcom = i_fndcom;
    assign o_fndfont = ((sel == 0) && dot_pls && (i_fndcom == 4'b1011)) ? {1'b0, i_fndfont[6:0]} : i_fndfont;

    // always @(*) begin
    //     o_fndfont_reg = i_fndfont;  // 기본적으로 입력 값을 할당
    //     if (sel == 1'b0) begin
    //         if (dot_pls == 1'b1 && i_fndcom == 4'b1011) begin
    //             o_fndfont_reg = i_fndfont | 8'h80;  // MSB를 1로 설정하여 점 추가
    //         end
    //     end
    //     // sel == 1'b1일 때는 o_fndfont_reg를 i_fndfont로 유지
    // end

endmodule