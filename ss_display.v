`timescale 1ns / 1ps

module ss_display(clk_fast, blink_clk, game_over, rst, score, count_s1, count_s0, seg, an);
    input clk_fast, blink_clk, rst, game_over;
    input wire [6:0] score;
	input wire [3:0] count_s1, count_s0;
    output reg [7:0] seg;   // CA thru CG + DP
    output wire [3:0] an;    // AN0 thru AN3
    reg [3:0] a;
    wire [3:0] score_1, score_2;
    
    assign score_1 = score % 10;
    assign score_2 = score / 10;

///////////////////////////////////////////////////////////////////////////
// AN cycling
///////////////////////////////////////////////////////////////////////////

    // clk == fast_clk from clock_divider.
    // 1 clk cycle == 1 digit period, so 4 clk cycles == 1 "refresh period"
    always @(posedge clk_fast) begin
        if (rst) begin
            a <= 1;
        end
        else begin
            if (a == 4'b1000) begin
                a <= 4'b0001;
            end
            else begin
                a <= a << 1;  // cycle thru each digit period
            end
        end
    end

    assign an = ~a;

///////////////////////////////////////////////////////////////////////////
// display multiplexing
///////////////////////////////////////////////////////////////////////////

    always @(a) begin
        if (rst == 1) begin
            seg <= 8'b11111111;
        end
        else if (game_over && blink_clk) begin
            seg <= 8'b11111111;
        end
        else if (game_over == 0) begin
            case (a)
                4'b0001: begin
                    case (count_s0)
                        0: begin
                            seg <= ~8'b00111111;
                        end
                        1: begin
                            seg <= ~8'b00000110;
                        end
                        2: begin
                            seg <= ~8'b01011011;
                        end
                        3: begin
                            seg <= ~8'b01001111;
                        end
                        4: begin
                            seg <= ~8'b01100110;
                        end
                        5: begin
                            seg <= ~8'b01101101;
                        end
                        6: begin
                            seg <= ~8'b01111101;
                        end
                        7: begin
                            seg <= ~8'b00000111;
                        end
                        8: begin
                            seg <= ~8'b01111111;
                        end
                        9: begin
                            seg <= ~8'b01100111;
                        end
                        default: begin
                            seg <= 8'b11111111;
                        end
                    endcase
                end
                4'b0010: begin
                    case (count_s1)
                        0: begin
                            seg <= ~8'b00111111;
                        end
                        1: begin
                            seg <= ~8'b00000110;
                        end
                        2: begin
                            seg <= ~8'b01011011;
                        end
                        3: begin
                            seg <= ~8'b01001111;
                        end
                        4: begin
                            seg <= ~8'b01100110;
                        end
                        5: begin
                            seg <= ~8'b01101101;
                        end
                        6: begin
                            seg <= ~8'b01111101;
                        end
                        7: begin
                            seg <= ~8'b00000111;
                        end
                        8: begin
                            seg <= ~8'b01111111;
                        end
                        9: begin
                            seg <= ~8'b01100111;
                        end
                        default: begin
                            seg <= 8'b11111111;
                        end
                    endcase
                end
                4'b0100: begin
                    seg <= 8'b11111111;
                end
                4'b1000: begin
                    seg <= 8'b11111111;
                end
                
                default: begin
                    // something is wrong if this part gets executed
                end
            endcase
        end
        else if (game_over == 1) begin
            case (a)
                4'b0001: begin
                    case (score_1)
                        0: begin
                            seg <= ~8'b00111111;
                        end
                        1: begin
                            seg <= ~8'b00000110;
                        end
                        2: begin
                            seg <= ~8'b01011011;
                        end
                        3: begin
                            seg <= ~8'b01001111;
                        end
                        4: begin
                            seg <= ~8'b01100110;
                        end
                        5: begin
                            seg <= ~8'b01101101;
                        end
                        6: begin
                            seg <= ~8'b01111101;
                        end
                        7: begin
                            seg <= ~8'b00000111;
                        end
                        8: begin
                            seg <= ~8'b01111111;
                        end
                        9: begin
                            seg <= ~8'b01100111;
                        end
                        default: begin
                            seg <= 8'b11111111;
                        end
                    endcase
                end
                4'b0010: begin
                    case (score_2)
                        0: begin
                            seg <= ~8'b00111111;
                        end
                        1: begin
                            seg <= ~8'b00000110;
                        end
                        2: begin
                            seg <= ~8'b01011011;
                        end
                        3: begin
                            seg <= ~8'b01001111;
                        end
                        4: begin
                            seg <= ~8'b01100110;
                        end
                        5: begin
                            seg <= ~8'b01101101;
                        end
                        6: begin
                            seg <= ~8'b01111101;
                        end
                        7: begin
                            seg <= ~8'b00000111;
                        end
                        8: begin
                            seg <= ~8'b01111111;
                        end
                        9: begin
                            seg <= ~8'b01100111;
                        end
                        default: begin
                            seg <= 8'b11111111;
                        end
                    
                       endcase
                   end
                   4'b0100: begin
                        seg <= 8'b11111111;
                   end
                   4'b1000: begin
                        seg <= 8'b11111111;
                   end
            
             endcase
        end
    end
endmodule
