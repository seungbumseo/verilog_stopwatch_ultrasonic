`timescale 1ns / 1ps

module BCD2SEG(
    input [3:0] bcd, 
    output reg [7:0] seg

    );
    always @(bcd) begin
        case (bcd)
        4'h0: seg = 8'hc0;
        4'h1: seg = 8'hf9;
        4'h2: seg = 8'ha4;
        4'h3: seg = 8'hb0;
        4'h4: seg = 8'h99;
        4'h5: seg = 8'h92;
        4'h6: seg = 8'h82;
        4'h7: seg = 8'hf8;
        4'h8: seg = 8'h80;
        4'h9: seg = 8'h90;
        4'ha: seg = 8'h88;
        4'hb: seg = 8'h83;
        4'hc: seg = 8'hc6;
        4'hd: seg = 8'ha1;
        4'he: seg = 8'h86;
        4'hf: seg = 8'h8e;
        
        endcase
    end
endmodule

module decoder_2x4 (
    input      [1:0] x,
    output reg [3:0] y
);
    always @(x) begin
        case(x)
        2'b00 : y = 4'b1110;
        2'b01 : y = 4'b1101;
        2'b10 : y = 4'b1011;
        2'b11 : y = 4'b0111;
    
        endcase
    end
endmodule

module digitSplitter(
    input  [13:0] x,
    output [3:0] dig_1,
    output [3:0] dig_10,
    output [3:0] dig_100,
    output [3:0] dig_1000
);
    assign dig_1 = x % 10;
    assign dig_10 = x / 10 % 10;
    assign dig_100 = x / 100 % 10;
    assign dig_1000 = x / 1000 % 10;

endmodule

module mux_2x1 #(
    parameter array = 10
)(
    input sel,
    input [array-1:0]  x0,
    input [array-1:0]  x1,
    // input [3:0]  x2,
    // input [3:0]  x3,
    output reg [array-1:0] y
);
    always @(*) begin
        case(sel)
            1'b0: y = x0;
            1'b1: y = x1;
            // 2'b10: y = x2;
            // 2'b11: y = x3;
        endcase
    end
endmodule

module mux_4x1 (
    input [1:0]  sel,
    input [3:0]  x0,
    input [3:0]  x1,
    input [3:0]  x2,
    input [3:0]  x3,
    output reg [3:0] y
);
    always @(*) begin
        case(sel)
            2'b00: y = x0;
            2'b01: y = x1;
            2'b10: y = x2;
            2'b11: y = x3;
        endcase
    end
endmodule

module counter (
    input clk, 
    input reset,
    output [1:0] count
);
    reg [1:0] r_counter;
    assign count = r_counter; 
    
    always @ (posedge clk, posedge reset) begin
        if (reset) begin
           r_counter <= 0;
    end else begin
        if (r_counter == 3) begin
            r_counter <= 0;
            
        end
        else begin
        r_counter <= r_counter + 1; 
      end
    end
   end
endmodule   

module clkDiv (
    input clk,
    input reset, 
    output o_clk
);
    reg [16:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk; 
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0; 
            end
          end
        end
endmodule

module clkDiv_dot (
    input clk,  // 1ms
    input reset, 
    input tick_1ms,

    output o_clk
);
    reg [16:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk; 
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 1'b0;
        end else begin
            if(tick_1ms) begin
                if (r_counter == 1000 - 1) begin
                    r_counter <= 0;
                    r_clk <= 1'b0;
                end else if(r_counter >= 500 - 1) begin
                    r_counter <= r_counter + 1;
                    r_clk <= 1'b1;
                end else begin
                    r_counter <= r_counter + 1;
                    r_clk <= 1'b0; 
                end
            end  
        end
    end

endmodule