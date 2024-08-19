`timescale 1ns / 1ps


module fsm_Stopwatch(
    input  clk,
    input  reset,
    input  sw0,            // btn RUN_StOP
    input  sw1,            // btn CLEAR
    input  btn_run_md,     // btn RUN_MODE Change
    input [7:0] rx_data,
    input rx_done,
    
    output reg enable,
    output reg clear,
    output rd_en,
    output reg run_md
);

   parameter STOP = 2'b00, RUN_SM = 2'b01, RUN_HM = 2'b10, CLEAR = 2'b11;

   wire w_run_stop = sw0;
   wire w_clear = sw1;
  
   reg [1:0] state, next_state;  
   reg [7:0] rx_data_reg, rx_data_next;
   reg rd_en_reg, rd_en_next; 
   reg temp_state_reg, temp_state_next;

   assign rd_en = rd_en_reg;     // for RX read

   // state register
   always @(posedge clk, posedge reset) begin
      if(reset) begin
         state <= STOP;  // initial value
         rx_data_reg <= 0;
         rd_en_reg <= 1'b0;
         temp_state_reg <= 1'b0;
      end
      else begin
         state <= next_state;
         rx_data_reg <= rx_data_next;
         rd_en_reg <= rd_en_next;
         temp_state_reg <= temp_state_next;
      end
   end
   
   // next state Combinational Logic
   always @(*) begin
      rx_data_next = 0;
      rd_en_next = 1'b0;
      if(rx_done) begin
         rx_data_next = rx_data;
         rd_en_next = 1'b1;
      end
      
      next_state = state;
      temp_state_next = temp_state_reg;
      case(state)
         STOP: begin
            if((w_run_stop == 1) || (rx_data_reg == "r")) begin
               if(temp_state_reg) begin   // for retrun previous state
                  next_state = RUN_HM;
               end else begin
                  next_state = RUN_SM;
               end 
            end
            else if((w_clear == 1) || (rx_data_reg == "c")) begin
               next_state = CLEAR;
            end else next_state = STOP;
         end
         RUN_SM: begin
            if((w_run_stop == 1) || (rx_data_reg == "s")) begin
               next_state = STOP;
               temp_state_next = 1'b0;    // for retrun RUN_SM
            end else if(btn_run_md) begin
               next_state = RUN_HM;
            end else next_state = RUN_SM;
         end
         RUN_HM: begin
            if((w_run_stop == 1) || (rx_data_reg == "s")) begin
                next_state = STOP;
                temp_state_next = 1'b1;   // for retrun RUN_HM
            end else if(btn_run_md) begin
               next_state = RUN_SM;
            end else next_state = RUN_HM;
         end
         CLEAR: begin
            next_state = STOP;
         end
      endcase
   end
   
   // output Combinational Logic
   always @(*) begin
      enable = 1'b0;
      clear  = 1'b0;
      run_md = 1'b0;
      case(state)
         STOP:    begin enable = 1'b0; clear = 1'b0; end 
         RUN_SM:  begin enable = 1'b1; clear = 1'b0; run_md = 1'b0; end
         RUN_HM:  begin enable = 1'b1; clear = 1'b0; run_md = 1'b1; end
         CLEAR:   begin enable = 1'b0; clear = 1'b1; end
         default: begin enable = 1'b0; clear = 1'b0; end
      endcase
   end

endmodule
