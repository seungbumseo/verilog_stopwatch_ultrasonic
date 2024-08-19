`timescale 1ns / 1ps


module FIFO #(
    parameter ADDR_WIDTH = 3,
    DATA_WIDTH = 8
) (
    input clk,
    input reset,
    input wr,
    output full,
    input [DATA_WIDTH-1 : 0] wr_data,
    input rd,
    output empty,
    output [DATA_WIDTH-1 : 0] rd_data
);

    wire [ADDR_WIDTH-1 : 0] w_wr_addr, w_rd_addr;

    RegisterFile #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) U_RegFile (
        .clk    (clk),
        .w_en   (wr & ~full),
        .rd_addr(w_rd_addr),
        .wr_addr(w_wr_addr),
        .wr_data(wr_data),
        .rd_data(rd_data)
    );

    fifo_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) U_FIFO_CTRL (
        .clk    (clk),
        .reset  (reset),
        .wr     (wr),
        .full   (full),
        .wr_addr(w_wr_addr),
        .rd     (rd),
        .empty  (empty),
        .rd_addr(w_rd_addr)
    );
endmodule

module RegisterFile #(
    parameter ADDR_WIDTH = 3,
    DATA_WIDTH = 8
) (
    input                     clk,
    input                     w_en,     // memory space
    input  [ADDR_WIDTH-1 : 0] rd_addr,  // Read Address size
    input  [ADDR_WIDTH-1 : 0] wr_addr,  // Write Address size 
    input  [DATA_WIDTH-1 : 0] wr_data,
    output [DATA_WIDTH-1 : 0] rd_data
);
    reg [DATA_WIDTH-1 : 0] memory [0 : 2**ADDR_WIDTH-1]; // 8bit memory * 8

    // write operation
    always @(posedge clk) begin
        if (w_en) memory[wr_addr] <= wr_data;
    end

    // read operation
    assign rd_data = memory[rd_addr];
endmodule

module fifo_ctrl #(
    parameter ADDR_WIDTH = 3    // data 8개 저장하겠다
) (
    input                     clk,
    input                     reset,
    input                     wr,
    output                    full,
    output [ADDR_WIDTH-1 : 0] wr_addr,
    input                     rd,
    output                    empty,
    output [ADDR_WIDTH-1 : 0] rd_addr
);
    reg [ADDR_WIDTH-1 : 0] wr_ptr_reg, wr_ptr_next;
    reg [ADDR_WIDTH-1 : 0] rd_ptr_reg, rd_ptr_next;
    reg full_reg, full_next, empty_reg, empty_next;

    assign wr_addr = wr_ptr_reg;
    assign rd_addr = rd_ptr_reg;
    assign full = full_reg;
    assign empty = empty_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            rd_ptr_reg <= 0;
            wr_ptr_reg <= 0;
            empty_reg  <= 1'b1;
            full_reg   <= 1'b0;
        end else begin
            rd_ptr_reg <= rd_ptr_next;
            wr_ptr_reg <= wr_ptr_next;
            empty_reg  <= empty_next;
            full_reg   <= full_next;
        end
    end

    always @(*) begin
        wr_ptr_next = wr_ptr_reg;
        rd_ptr_next = rd_ptr_reg;
        full_next   = full_reg;
        empty_next  = empty_reg;
        case ({
            wr, rd
        })
            2'b01: begin  // read
                if (~empty_reg) begin
                    rd_ptr_next = rd_ptr_reg + 1;
                    full_next   = 1'b0;     // data 가득 찼을 때 1
                    if (rd_ptr_next == wr_ptr_reg) begin
                        empty_next = 1'b1;
                    end
                end
            end
            2'b10: begin  //write
                if (~full_reg) begin
                    wr_ptr_next = wr_ptr_reg + 1;
                    empty_next  = 1'b0;     // data 남아 있으면 0
                    if (wr_ptr_next == rd_ptr_reg) begin
                        full_next = 1'b1;
                    end
                end
            end
            2'b11: begin  // write, read
                if (empty_reg) begin  // 
                    wr_ptr_next = wr_ptr_reg;
                    rd_ptr_next = rd_ptr_reg;
                end else begin
                    wr_ptr_next = wr_ptr_reg + 1;
                    rd_ptr_next = rd_ptr_reg + 1;
                end
            end
            default: ;
        endcase
    end
endmodule
