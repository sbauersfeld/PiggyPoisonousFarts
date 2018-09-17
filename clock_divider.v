`timescale 1ns / 1ps
module clock_divider(clk, rst, one_hz_clk, fast_clk, display_clk, blink_clk);
    input clk, rst;
    output reg one_hz_clk, fast_clk, display_clk, blink_clk;
    reg hold_1;
    reg [25:0] one_hz_clk_dv_inc;
    reg display_clk_inc;
	reg [18:0] fast_clk_inc;
	reg [23:0] blink_clk_inc;

    always @(posedge clk) begin
        if (rst) begin
          one_hz_clk <= 1'b0;
          one_hz_clk_dv_inc <= 26'b0;
          fast_clk_inc <= 19'b0;
          fast_clk <= 1'b0;
          blink_clk_inc <= 24'b0;
          blink_clk <= 1'b0;
          hold_1 <= 1'b0;
          display_clk <= 1'b0;
          display_clk_inc <= 1'b0;
        end
        
        else begin
          if (one_hz_clk_dv_inc == 49999999) begin //one hz
              one_hz_clk_dv_inc <= 26'b0;
              one_hz_clk <= hold_1;
              hold_1 <= ~hold_1;
          end
          else begin
              one_hz_clk_dv_inc <= one_hz_clk_dv_inc+1;
              one_hz_clk <= 0;
          end
          //fast clk
          if (fast_clk_inc == 249999) begin
            fast_clk_inc <= 19'b0;
            fast_clk <= ~fast_clk;
          end
          else begin
            fast_clk_inc <= fast_clk_inc + 1;
          end
          //blink clk
          if (blink_clk_inc == 12499999) begin
            blink_clk_inc <= 24'b0;
            blink_clk <= ~blink_clk;
          end
          else begin
            blink_clk_inc <= blink_clk_inc + 1;
          end
          
          if (display_clk_inc == 1) begin
            display_clk_inc <= 0;
            display_clk <= ~display_clk;
          end
          else begin
            display_clk_inc <= display_clk_inc + 1;
          end
        end
    end
endmodule