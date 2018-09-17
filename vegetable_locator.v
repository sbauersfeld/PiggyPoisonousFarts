`timescale 1ns / 1ps
`include "constants.v"
 
module vegetable_locator(clk, rst, start, new_round, pigX, pigY, pig_growth, posX, posY, posX_end, posY_end);
    input start, clk, rst, start, new_round;
	input wire [10:0] pigX, pigY, pig_growth;
    output reg [10:0] posX, posY;
    output wire [10:0] posX_end, posY_end;
    
    reg[9:0] countX, countY;
    
    assign posX_end = posX + vegetable_size;
    assign posY_end = posY + vegetable_size;
    
    always @(posedge clk) begin
        if (rst) begin
            countX = 300;
            countY = 300;
        end
        else if (start || new_round) begin
            // Relocate vegetable if it's about to spawn on top of Piggy
            // If vegetable is about to spawn on pig, relocate
            if (countX >= pigX - vegetable_size - pig_growth && countX <= pigX + pig_size &&
                countY >= pigY - vegetable_size - pig_growth && countY <= pigY + pig_size)                                                                            
            begin
                //countX = (countX * 15) % (maxX - vegetable_size);
                //countY = (countY * 15) % (maxY - vegetable_size);

                // Relocate up, down, left, or right
                // (the max we need to move is pig_size pixels)
                if (countY - pig_size > minY)
                    countY = countY - pig_size;  // up
                else if (countY + pig_size < maxY - vegetable_size)
                    countY = countY + pig_size;  // down
                else if (countX - pig_size > minX)
                    countX = countX - pig_size;  // left
                else if (countX + pig_size < maxX - vegetable_size)
                    countX = countX + pig_size;  // right
            end
            posX = countX;  // set random vegetable pos
            posY = countY;
        end
        else begin
            if (countX == maxX - vegetable_size)
                countX = minX;
            else
                countX = countX+1;
            if (countY == maxY - vegetable_size)
                countY = minY;
            else
                countY = countY+1;
        end
    end
endmodule
