`timescale 1ns / 1ps

module vga640x480(
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,	    //asynchronous reset
    input game_state,
	input game_over,
	input display_blue,
    input is_fifth_round,
    input vegetable_consumed,
	input wire [10:0] pigX,
	input wire [10:0] pigY,
	input wire [10:0] pigX_end,
	input wire [10:0] pigY_end,
	input wire [10:0] snackX,
	input wire [10:0] snackY,
	input wire [10:0] snackY_end, 
	input wire [10:0] snackX_end,
	input wire [10:0] vegetableX,
	input wire [10:0] vegetableY,
	input wire [10:0] vegetableY_end, 
	input wire [10:0] vegetableX_end,
	input wire [array_size-1:0] trailX,
	input wire [array_size-1:0] trailY,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output
	);
	
`include "constants.v"

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// registers for objects
wire [9:0] vga_pigX, vga_pigY;			// Piggy's coordinates on VGA screen
wire [9:0] vga_pigX_end, vga_pigY_end;	// Piggy's ending coordinates on VGA screen
wire [9:0] vga_snackX, vga_snackY;			// snack's coordinates on VGA screen
wire [9:0] vga_snackX_end, vga_snackY_end;	// snack's ending coordinates on VGA screen
wire [9:0] vga_vegetableX, vga_vegetableY;			// vegetable's coordinates on VGA screen
wire [9:0] vga_vegetableX_end, vga_vegetableY_end;	// vegetable's ending coordinates on VGA screen
reg displayPig, displaySnack, displayVegetable;
wire displayFart;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;


assign vga_pigX = pigX + hbp;
assign vga_pigY = pigY + vbp;
assign vga_pigX_end = hbp + pigX_end;
assign vga_pigY_end = vbp + pigY_end;

assign vga_snackX = snackX + hbp;
assign vga_snackY = snackY + vbp;
assign vga_snackX_end = snackX_end + hbp;
assign vga_snackY_end = snackY_end + vbp;

assign vga_vegetableX = vegetableX + hbp;
assign vga_vegetableY = vegetableY + vbp;
assign vga_vegetableX_end = vegetableX_end + hbp;
assign vga_vegetableY_end = vegetableY_end + vbp;

reg [trail_points-1:0] TEST;
integer i;

assign displayFart = | TEST;

always @(dclk) begin
	//displayFart <= 0;
	displayPig <= (hc >= vga_pigX && hc <= vga_pigX_end && vc >= vga_pigY && vc <= vga_pigY_end);
	displaySnack <= (hc >= vga_snackX && hc <= vga_snackX_end && vc >= vga_snackY && vc <= vga_snackY_end);
	if (is_fifth_round && !vegetable_consumed)
		displayVegetable <= (hc >= vga_vegetableX && hc <= vga_vegetableX_end && vc >= vga_vegetableY && vc <= vga_vegetableY_end);
	else
		displayVegetable <= 0;
	for(i = 0; i < trail_points; i=i+1) begin
		TEST[i] <= (trailX[bit_width*i +: bit_width] != 31 && trailY[bit_width*i +: bit_width] != 31 && hc >= (hbp + trail_width*trailX[bit_width*i +: bit_width]) && hc <= (hbp + trail_width*trailX[bit_width*i +: bit_width] + trail_width) && vc >= (vbp + trail_width*trailY[bit_width*i +: bit_width]) && vc <= (vbp + trail_width*trailY[bit_width*i +: bit_width] + trail_width));	
	end
end


// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =

reg [1:0] game_over_count;
always @(*) begin

	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
        if (hc >= hbp && hc < (hbp+640)) begin	// check if we're within horizontal active video range
			if (game_over && game_state && display_blue) begin  // blue screen upon pig death
				// 2 Eyes (white)
				if (((hc >= hbp+edge_length+200 && hc <= hbp+edge_length+250) || (hc >= hbp+edge_length+384 && hc <= hbp+edge_length+434)) && vc >= vbp+edge_length+120 && vc <= vbp+edge_length+170) begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				// Long part of lips (white)
				else if (hc >= hbp+edge_length+50 && hc <= hbp+edge_length+584 && vc >= vbp+edge_length+220 && vc <= vbp+edge_length+270) begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				// Frowning part of lips (white)
				else if (((hc >= hbp+edge_length+50 && hc <= hbp+edge_length+100) || (hc >= hbp+edge_length+534 && hc <= hbp+edge_length+584)) && vc >= vbp+edge_length+270 && vc <= vbp+edge_length+320) begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				// Blue everywhere else
				else begin
					red = 3'b000;
					green = 3'b000;
					blue = 2'b11;
				end
			end
			else begin // game mode
				if (displayPig) begin  // pink square
					red = 3'b111;
					green = 3'b000;
					blue = 2'b11;
				end
				else if (game_state && displaySnack) begin  // blue square
					red = 3'b000;
					green = 3'b000;
					blue = 2'b11;
				end
				else if (game_state && displayVegetable) begin  // green square
					red = 3'b000;
					green = 3'b111;
					blue = 2'b00;
				end
				else if (game_state && displayFart) begin // ORANGE? (mooj's guess) square
					red = 3'b111;
					green = 3'b100;
					blue = 2'b00;
				end
				else begin	// white
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;    
				end
			end
				
        end
        else begin	// must black out the unseen edges or else the screen is weird
            red = 0;
            green = 0;
            blue = 0;
        end
        /*
		// now display different colors every 80 pixels
		// while we're within the active horizontal range
		// -----------------
		// display white bar
		if (hc >= hbp && hc < (hbp+80))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		// display yellow bar
		else if (hc >= (hbp+80) && hc < (hbp+160))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b00;
		end
		// display cyan bar
		else if (hc >= (hbp+160) && hc < (hbp+240))
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b11;
		end
		// display green bar
		else if (hc >= (hbp+240) && hc < (hbp+320))
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
		// display magenta bar
		else if (hc >= (hbp+320) && hc < (hbp+400))
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b11;
		end
		// display red bar
		else if (hc >= (hbp+400) && hc < (hbp+480))
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b00;
		end
		// display blue bar
		else if (hc >= (hbp+480) && hc < (hbp+560))
		begin
			red = 3'b000;
			green = 3'b000;
			blue = 2'b11;
		end
		// display black bar
		else if (hc >= (hbp+560) && hc < (hbp+640))
		begin
			red = 3'b000;
			green = 3'b000;
			blue = 2'b00;
		end
		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
        */
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule



