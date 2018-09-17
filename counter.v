`timescale 1ns / 1ps

module counter(new_round, rst, clk, clk_1, count_s1, count_s0, game_over, game_state);
	input new_round, clk, clk_1, rst, game_state;
    output reg game_over;
	output wire [3:0] count_s1, count_s0;
	reg [5:0] count_s;
	
  always @(posedge clk) begin
		if (rst || new_round) begin //reset
			count_s <= 15;
            game_over <= 0;
		end
		
		else if (game_state && clk_1) begin //normal mode
			if (count_s == 0) begin
				game_over <= 1;
			end
			else begin
				count_s <= count_s - 1;
			end
		end
		
	end
	assign count_s1 = count_s / 10;
	assign count_s0 = count_s % 10;

endmodule
