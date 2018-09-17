`timescale 1ns / 1ps


module trail_locator(clk, rst, new_round, game_state, game_over, round, up, down, left, right, pigX, pigY, trailX, trailY, pig_growth, extra_move);
    input clk, rst, game_state, up, down, left, right, game_over, new_round;
	input [7:0] round;
    input [9:0] pigX, pigY, pig_growth;
    input signed [10:0] extra_move;
    output reg [array_size-1:0] trailX, trailY;
	wire [9:0] ta;

	`include "constants.v"
	
	reg [4:0] tempX, tempY;
	reg first_move;
	reg [5:0] num_points;
	
	reg signed[10:0] pig_growth2;
	reg up2, down2, left2, right2;

	assign ta = bit_width*num_points;
    always @(posedge clk) begin
		if (!rst) begin
			up2<=up;
			right2<=right;
			down2<=down;
			left2<=left;
			/*if (new_round && 2*round < trail_points) begin
                num_points <= 2*round - 1;
            end*/
		end
		
        if (rst) begin
			trailX <= {array_size{1'b1}};
			trailY <= {array_size{1'b1}};
			num_points <= 0;
			tempX <= 0;
			tempY <= 0;
			up2<=0;
			right2<=0;
			down2<=0;
			left2<=0;
			first_move <= 0;
		  end
		  else if (!game_over && game_state && ((up2&&pigY>=minY+move+extra_move) || (down2&&pigY+pig_size+pig_growth+move+extra_move<=maxY) || (right2&&pigX+pig_size+pig_growth+move+extra_move<=maxX) || (left2&&pigX>=minX+move+extra_move))) begin
            if (first_move == 0) begin
				first_move <= 1;
				trailX[ta +: bit_width] <= startX_trail;
				trailY[ta +: bit_width] <= startY_trail;
				if (up2) begin
					tempX <= startX_trail;
					tempY <= startY_trail - 1;
				end
				else if (down2) begin
					tempX <= startX_trail;
					tempY <= startY_trail + 1;
				end
				if (right2) begin
					tempX <= startX_trail + 1;
					tempY <= startY_trail;
				end
				if (left2) begin
					tempX <= startX_trail - 1;
					tempY <= startY_trail;
				end
			end
			
			else if (up2) begin
				tempX <= tempX;
				tempY <= tempY - 1;
            end
			
            else if (down2) begin
				tempX <= tempX;
				tempY <= tempY + 1;
            end
			
            else if (right2) begin
				tempX <= tempX + 1;
				tempY <= tempY;
            end
			
            else if (left2) begin
				tempX <= tempX - 1;
				tempY <= tempY;
            end
				
			if (first_move != 0) begin
				trailX[ta +: bit_width] <= tempX;
				trailY[ta +: bit_width] <= tempY;
			end
			
			if (num_points == 2*round) begin
				num_points <= 0;
			end
			else if (num_points == trail_points-1) begin
				num_points <= 0;
			end
			else begin
				num_points <= num_points+1;
			end
				
        end
    end
endmodule