`timescale 1ns / 1ps

module pig_locator(clk, game_over, game_state, is_fifth_round, vegetable_consumed, rst, up, down, right, left, snackX, snackY, vegetableX, vegetableY, posX, posY_end, posX_end, pig_growth, posY, score, new_round, extra_move);
    `include "constants.v"
    input clk, game_state, is_fifth_round, rst, up, down, right, left, game_over;
	input [10:0] snackX, snackY;
  	input [10:0] vegetableX, vegetableY;
    output reg signed[10:0] posY, posX, pig_growth;
	output wire signed[10:0] posY_end, posX_end;
	output reg [7:0] score;
	output reg new_round;
    output reg vegetable_consumed;

    // Directions delayed by 1 clk cycle
    reg up2, down2, left2, right2;
	
    reg [3:0] last_dir;  // 1000: up, 0100: down, 0010: left, 0001: right
	output reg signed [10:0] extra_move;
    reg signed [10:0] extra_move_perp;  // perpendicular to extra_move

    wire signed [10:0] posX_minus_move;
    wire signed [10:0] posY_minus_move;
    wire signed [10:0] posX_plus_move;
    wire signed [10:0] posY_plus_move;
    wire signed [10:0] posX_end_plus_move;
    wire signed [10:0] posY_end_plus_move;
    wire signed [10:0] pig_snack_overlapX_lower;
    wire signed [10:0] pig_snack_overlapX_upper;
    wire signed [10:0] pig_snack_overlapY_lower;
    wire signed [10:0] pig_snack_overlapY_upper;
    wire signed [10:0] pig_veg_overlapX_lower;
    wire signed [10:0] pig_veg_overlapX_upper;
    wire signed [10:0] pig_veg_overlapY_lower;
    wire signed [10:0] pig_veg_overlapY_upper;
    
    assign posX_minus_move = posX - move - extra_move;         // added extra_move
    assign posY_minus_move = posY - move - extra_move;         // added extra_move
    assign posX_plus_move = posX + move + extra_move;          // added extra_move
    assign posY_plus_move = posY + move + extra_move;          // added extra_move
    assign posX_end_plus_move = posX_end + move + extra_move;  // added extra_move
    assign posY_end_plus_move = posY_end + move + extra_move;  // added extra_move
	assign posY_end = posY + pig_size + pig_growth;
	assign posX_end = posX + pig_size + pig_growth;
    assign pig_snack_overlapX_lower = snackX - pig_size - pig_growth;
    assign pig_snack_overlapX_upper = snackX + snack_size;
    assign pig_snack_overlapY_lower = snackY - pig_size - pig_growth;
    assign pig_snack_overlapY_upper = snackY + snack_size;
    assign pig_veg_overlapX_lower = vegetableX - pig_size - pig_growth;
    assign pig_veg_overlapX_upper = vegetableX + vegetable_size;
    assign pig_veg_overlapY_lower = vegetableY - pig_size - pig_growth;
    assign pig_veg_overlapY_upper = vegetableY + vegetable_size;
	
    // Identify turns and set extra_move for pig accordingly
    always @(posedge clk) begin
        if (rst) begin
            last_dir <= 0;
            extra_move <= 0;
            up2 <= 0;
            down2 <= 0;
            left2 <= 0;
            right2 <= 0;
        end
        else begin
            // Delay directions by 1 clk cycle. These are used by the always block for pig-moving logic.
            up2 <= up;
            down2 <= down;
            left2 <= left;
            right2 <= right;

            // Set the last direction
            if (up2 && (posY_minus_move >= minY))
                last_dir <= 4'b1000;
            if (down2 && (posY_end_plus_move <= maxY))
                last_dir <= 4'b0100;
            if (left2 && (posX_minus_move >= minX))
                last_dir <= 4'b0010;
            if (right2 && ((posX_end_plus_move) <= maxX))
                last_dir <= 4'b0001;
        end
        // If pig turns, move a bit more so that his new trail lines up with the old...

        // Was moving up, now turns left or right
        if (last_dir == 4'b1000 && (left || right)) begin
            extra_move <= (pig_growth >> 1);
            extra_move_perp <= (pig_growth >> 1);
        end
        // Was moving down, now turns left or right
        else if (last_dir == 4'b0100 && (left || right)) begin
            extra_move <= (pig_growth >> 1);
            extra_move_perp <= -(pig_growth >> 1);
        end
        // Was moving left, now turns up or down
        else if (last_dir == 4'b0010 && (up || down)) begin
            extra_move <= (pig_growth >> 1);
            extra_move_perp <= (pig_growth >> 1);
        end
        // Was moving right, now turns up or down
        else if (last_dir == 4'b0001 && (up || down)) begin
            extra_move <= (pig_growth >> 1);
            extra_move_perp <= -(pig_growth >> 1);
        end
        else begin
            extra_move <= 0;
            extra_move_perp <= 0;
        end
    end
    

    // Pig-moving logic
    always @(posedge clk) begin
        if (rst) begin //starting point
            posY <= startY;
            posX <= startX;
			pig_growth <= 0;
			new_round <= 0;
			score <= 0;
            vegetable_consumed <= 0;
        end
        else if (!game_over && game_state) begin
            if (up2 && (posY_minus_move >= minY)) begin
					/* Touch snack */
					if ((posY_minus_move) > pig_snack_overlapY_lower && (posY_minus_move) < pig_snack_overlapY_upper &&
                        posX > pig_snack_overlapX_lower && posX < pig_snack_overlapX_upper)
                    begin
						new_round <= 1;
						vegetable_consumed <= 0;
						score <= score + 1;
						pig_growth <= pig_growth + growth;
						posY <= posY - growth - move - extra_move;  // added extra_move
						posX <= posX - (growth>>1) + extra_move_perp;
					end
					/* Touch vegetable */
					else if ((posY_minus_move) > pig_veg_overlapY_lower && (posY_minus_move) < pig_veg_overlapY_upper &&
                        posX > pig_veg_overlapX_lower && posX < pig_veg_overlapX_upper)
                    begin
						if (is_fifth_round && !vegetable_consumed) begin
							pig_growth <= pig_growth - shrink;
							vegetable_consumed <= 1;
							posY <= posY - move + shrink - extra_move; // down, added extra_move
							posX <= posX + (shrink >> 1) + extra_move_perp; // right
						end
						else begin
							posY <= posY - move - extra_move; // added extra_move
							posX <= posX + extra_move_perp;
						end
					end
					else begin 
						posY <= posY - move - extra_move;  // added extra_move
						posX <= posX + extra_move_perp;
					end
            end
            else if (down2 && ((posY_end_plus_move) <= maxY)) begin
					/* Touch snack */
                    if ((posY_plus_move) > pig_snack_overlapY_lower && (posY_plus_move) < pig_snack_overlapY_upper &&
                        posX > pig_snack_overlapX_lower && posX < pig_snack_overlapX_upper)
                    begin
                    	new_round <= 1;
						vegetable_consumed <= 0;
						score <= score + 1;
						pig_growth <= pig_growth + growth;
						posY <= posY + move + extra_move;  // added extra_move
						posX <= posX - (growth>>1) + extra_move_perp;
					end
					/* Touch vegetable */
					else if ((posY_plus_move) > pig_veg_overlapY_lower && (posY_plus_move) < pig_veg_overlapY_upper &&
                        posX > pig_veg_overlapX_lower && posX < pig_veg_overlapX_upper)
                    begin
						if (is_fifth_round && !vegetable_consumed) begin
                            pig_growth <= pig_growth - shrink;
							vegetable_consumed <= 1;
							posY <= posY + move + extra_move;  // added extra_move
							posX <= posX + (shrink >> 1) + extra_move_perp; // right
						end
						else begin
							posY <= posY + move + extra_move;  // added extra_move
							posX <= posX + extra_move_perp;
						end
					end
					else begin
						posY <= posY + move + extra_move;  // added extra_move
						posX <= posX + extra_move_perp;
					end
            end
            else if (right2 && ((posX_end_plus_move) <= maxX) /*&& ((last_dir != 4'b1000 && last_dir != 4'b0100) || (posX_end_plus_move + (pig_growth>>1) <= maxX))*/) begin
					/* Touch snack */
                    if (posY > pig_snack_overlapY_lower && posY < pig_snack_overlapY_upper &&
                        (posX_plus_move) > pig_snack_overlapX_lower && (posX_plus_move) < pig_snack_overlapX_upper)
                    begin
						new_round <= 1;
						vegetable_consumed <= 0;
						score <= score + 1;
						pig_growth <= pig_growth + growth;
						posX <= posX + move + extra_move;  // added extra_move
						posY <= posY - (growth>>1) + extra_move_perp;
					end
					/* Touch vegetable */
					else if (posY > pig_veg_overlapY_lower && posY < pig_veg_overlapY_upper &&
                        (posX_plus_move) > pig_veg_overlapX_lower && (posX_plus_move) < pig_veg_overlapX_upper)
                    begin
						if (is_fifth_round && !vegetable_consumed) begin
                            pig_growth <= pig_growth - shrink;
							vegetable_consumed <= 1;
							posX <= posX + move + extra_move;  // added extra_move
							posY <= posY + (shrink >> 1) + extra_move_perp; // just down
						end
						else begin
							posX <= posX + move + extra_move;  // added extra_move
							posY <= posY + extra_move_perp;
						end
					end
					else begin
						posX <= posX + move + extra_move;  // added extra_move
						posY <= posY + extra_move_perp;
					end
            end
            else if (left2 && (posX_minus_move >= minX)) begin
					/* Touch snack */
                    if (posY > pig_snack_overlapY_lower && posY < pig_snack_overlapY_upper &&
                        (posX_minus_move) > pig_snack_overlapX_lower && (posX_minus_move) < pig_snack_overlapX_upper)
                    begin
						new_round <= 1;
						vegetable_consumed <= 0;
						score <= score + 1;
						pig_growth <= pig_growth + growth;
						posX <= posX - growth - move - extra_move; //grow in direction of food, added extra_move
						posY <= posY - (growth>>1) + extra_move_perp;
					end
					/* Touch vegetable */
					else if (posY > pig_veg_overlapY_lower && posY < pig_veg_overlapY_upper &&
                        (posX_minus_move) > pig_veg_overlapX_lower && (posX_minus_move) < pig_veg_overlapX_upper)
                    begin
						if (is_fifth_round && !vegetable_consumed) begin
                            pig_growth <= pig_growth - shrink;
							vegetable_consumed <= 1;
							posX <= posX - move + shrink - extra_move;  // added extra_move
							posY <= posY + (shrink >> 1) + extra_move_perp;
						end
						else begin
							posX <= posX - move - extra_move;  // added extra_move
							posY <= posY + extra_move_perp;
						end
					end
					else begin
						posX <= posX - move - extra_move;  // added extra_move
						posY <= posY + extra_move_perp;
					end
            end
			else begin
				new_round <= 0;
			end
        end
    end
endmodule
