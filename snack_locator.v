`timescale 1ns / 1ps

 
module snack_locator(clk, rst, new_round, pigX, pigY, pig_growth, posX, posY, start, posX_end, posY_end);
	input start, clk, rst, new_round;
	input wire [10:0] pigX, pigY, pig_growth;
	output reg [10:0] posX, posY;
	output wire [10:0] posX_end, posY_end;
	
	`include "constants.v"
	
	reg[9:0] countX, countY;
	
	assign posX_end = posX + snack_size;
	assign posY_end = posY + snack_size;
	
	always @(posedge clk) begin
		if (rst) begin
			countX = minX;
            countY = minY;
		end
        else if (start || new_round) begin
            // If snack is about to spawn on pos, relocate
            if (countX >= posX - snack_size - pig_growth && countX <= posX + pig_size &&
                countY >= posY - snack_size - pig_growth && countY <= posY + pig_size)                                                                            
            begin
                //countX = (countX * 15) % (maxX - snack_size);
                //countY = (countY * 15) % (maxY - snack_size);

                // Relocate up, down, left, or right
                // (the max we need to move is pig_size pixels)
                if (countY - pig_size > minY)
                    countY = countY - pig_size;  // up
                else if (countY + pig_size < maxY - snack_size)
                    countY = countY + pig_size;  // down
                else if (countX - pig_size > minX)
                    countX = countX - pig_size;  // left
                else if (countX + pig_size < maxX - snack_size)
                    countX = countX + pig_size;  // right
            end
            posX = countX;	// set random snack pos
			posY = countY;
        end
		else begin
			if (countX == maxX - snack_size)
				countX = minX;
			else
				countX = countX+1;
			if (countY == maxY - snack_size)
				countY = minY;
			else
				countY = countY+1;
		end
	end
endmodule
