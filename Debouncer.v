`timescale 1ns / 1ps

module Debouncer(rst, clk, button, press);
	input rst, clk, button;
    output reg press;
	reg state;
	reg in, in_0;
	reg [30:0] cnt;
	
    always @(posedge clk) begin
		in_0 <= button; 
	end
  
	always @(posedge clk) begin
		in <= in_0; 
	end
	
    always @ (posedge clk) begin		
        if (rst) begin
            state <= 0;
            cnt <= 0;
            press <= 0;
        end
		
        if (state == 0 && in == 1) begin
			state <= 1;
            press <= 1;
			cnt <= 0;
		end
        else if (state == 1) begin
			cnt <= cnt + 1;
            press <= 0;
		end
		
        if (cnt == 12499999) begin //50000000
			state <= 0;
			cnt <= 0;
            press <= 0;
		end
	 end
endmodule
