`timescale 1ns / 1ps

module top(rst, clk, start, btnU, btnR, btnD, btnL, seg, an, led, hsync, vsync, red, green, blue);
    `include "constants.v"
    input rst, start, clk, btnU, btnR, btnD, btnL;
	output [7:0] seg;
	output [3:0] an;
    output reg [7:0] led;
	output wire hsync;		//horizontal sync out
	output wire vsync;		//vertical sync out
	output wire [2:0] red;	//red vga output
	output wire [2:0] green; //green vga output
	output wire [1:0] blue;	//blue vga output
    
    reg [1:0] game_over_count;
    reg display_blue;
    reg rst1, rst2, start1, start2;
    wire RST, NEW_START;
    reg game_state, START;
    wire[7:0] score;
    wire is_fifth_round, vegetable_consumed;
    
    wire [array_size-1:0] trailX, trailY;
    wire [3:0] s_0, s_1;
    wire clk_1, clk_fast, clk_blink, clk_display;
    wire game_over, game_over1, new_round;
    
    wire btnU_press, btnD_press, btnR_press, btnL_press;
    wire [9:0] pigX, pigY, snackX, snackY, snackX_end, snackY_end, pigX_end, pigY_end, pig_growth;
    wire [9:0] vegetableX, vegetableY, vegetableX_end, vegetableY_end;
    wire signed [10:0] extra_move;

    // Delay blue screen after pig death so that the player can see why pig died


    reg[trail_points-1:0] TEST;
    wire game_over3;
	assign game_over3 = | TEST;
    integer i;
    always @(posedge clk) begin
        if (!RST && !game_over) begin
            led <= score;
        end
        else if (!RST && game_over) begin
            led <= 0;
        end
		if (!RST && clk_1) begin
			if (game_over && game_state) begin
				game_over_count <= game_over_count + 1;
			end
			if (game_over_count == 2) begin
				display_blue <= 1;
			end
		end
        if (RST) begin
            game_state <= 0;
            game_over_count <= 0;
            display_blue <= 0;
        end
		else if(game_state) begin
			START <= 0;
			for(i = 0; i < trail_points; i=i+1) begin
                	
                TEST[i] <= (trailX[bit_width*i +: bit_width] != 31 && trailY[bit_width*i +: bit_width] != 31 &&
                
                    ((pigX > trail_width*trailX[bit_width*i +: bit_width] && pigX < trail_width*trailX[bit_width*i +: bit_width] + trail_width) ||
                    (pigX_end > trail_width*trailX[bit_width*i +: bit_width] && pigX_end < trail_width*trailX[bit_width*i +: bit_width] + trail_width) ||
                    (pigX <= trail_width*trailX[bit_width*i +: bit_width] && pigX_end >= trail_width*trailX[bit_width*i +: bit_width] + trail_width)) &&
                    
                    ((pigY > trail_width*trailY[bit_width*i +: bit_width] && pigY < trail_width*trailY[bit_width*i +: bit_width] + trail_width) ||
                    (pigY_end > trail_width*trailY[bit_width*i +: bit_width] && pigY_end < trail_width*trailY[bit_width*i +: bit_width] + trail_width) ||
                    (pigY <= trail_width*trailY[bit_width*i +: bit_width] && pigY_end >= trail_width*trailY[bit_width*i +: bit_width] + trail_width)));

            end
		end
		else if (NEW_START && !game_state) begin
            game_state <= 1;
            START <= 1;
        end
        rst1 <= rst;
        rst2 <= rst1;
        start1 <= start;
        start2 <= start1;
    end
	
	assign RST = rst1 ^ rst2;
    assign NEW_START = start1 ^ start2;
    assign game_over = game_over1 || game_over3;
    assign is_fifth_round = score != 0 && (score % 5) == 0;
    
    clock_divider CD(.rst(RST), .clk(clk), .one_hz_clk(clk_1), .fast_clk(clk_fast), .display_clk(clk_display),
        .blink_clk(clk_blink));
    counter COUNT(.new_round(new_round), .rst(RST), .clk(clk), .clk_1(clk_1), .count_s1(s_1), .count_s0(s_0),
        .game_over(game_over1), .game_state(game_state));
    Debouncer DEBOUNCEU(.rst(RST), .clk(clk), .button(btnU), .press(btnU_press));
    Debouncer DEBOUNCED(.rst(RST), .clk(clk), .button(btnD), .press(btnD_press));
    Debouncer DEBOUNCER(.rst(RST), .clk(clk), .button(btnR), .press(btnR_press));
    Debouncer DEBOUNCEL(.rst(RST), .clk(clk), .button(btnL), .press(btnL_press));
    pig_locator PIG(.game_state(game_state), .is_fifth_round(is_fifth_round), .clk(clk), .game_over(game_over),
        .rst(RST), .snackX(snackX), .vegetable_consumed(vegetable_consumed), .vegetableX(vegetableX), .vegetableY(vegetableY),
        .snackY(snackY), .up(btnU_press), .down(btnD_press),
        .right(btnR_press), .left(btnL_press), .posX(pigX), .posY(pigY), .new_round(new_round),
        .posX_end(pigX_end), .posY_end(pigY_end), .pig_growth(pig_growth), .score(score), .extra_move(extra_move));
    snack_locator SNACK(.clk(clk), .rst(RST), .new_round(new_round), .pigX(pigX), .pigY(pigY), .pig_growth(pig_growth),
		.posX(snackX), .posX_end(snackX_end),
        .posY_end(snackY_end), .posY(snackY), .start(START));
    vegetable_locator VEGETABLE(.pigX(pigX), .pigY(pigY), .pig_growth(pig_growth), .clk(clk), .rst(RST), .start(START), .new_round(new_round),
        .posX(vegetableX), .posY(vegetableY), .posX_end(vegetableX_end), .posY_end(vegetableY_end));
    trail_locator TRAIL(.clk(clk), .rst(RST), .round(score), .game_state(game_state), .new_round(new_round), .game_over(game_over), .up(btnU_press), .down(btnD_press),
        .left(btnL_press), .right(btnR_press), .pigX(pigX), .pigY(pigY), .pig_growth(pig_growth), .trailX(trailX),
        .trailY(trailY), .extra_move(extra_move));
    ss_display SS(.clk_fast(clk_fast), .blink_clk(clk_blink), .game_over(game_over), .rst(RST), .score(score),
        .count_s1(s_1), .count_s0(s_0), .seg(seg), .an(an));
    vga640x480 VGA(.game_state(game_state), .is_fifth_round(is_fifth_round), .vegetable_consumed(vegetable_consumed),
        .dclk(clk_display), .clr(RST), .game_over(game_over), .display_blue(display_blue),
        .pigX(pigX), .pigX_end(pigX_end), .pigY_end(pigY_end), .pigY(pigY), .snackX(snackX), .snackY(snackY),
        .snackY_end(snackY_end), .snackX_end(snackX_end), .vegetableX(vegetableX), .vegetableY(vegetableY),
        .vegetableX_end(vegetableX_end), .vegetableY_end(vegetableY_end), .trailX(trailX), .trailY(trailY),
        .hsync(hsync), .vsync(vsync), .red(red), .green(green), .blue(blue));
endmodule
