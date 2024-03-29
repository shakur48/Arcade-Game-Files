
`ifndef SCOREBOARD_H
`define SCOREBOARD_H

`include "hvsyncGenerator.v"
`include "bitmappedDigits.v"

/*
player_stats - Holds two-digit score and one-digit lives counter.
scoreboard_generator - Outputs video signal with score/lives digits.
*/

module player_stats(reset, score0, score1, incscore);
  
  input reset;
  output reg [3:0] score0;
  output reg [3:0] score1;
  input incscore;

  always @(posedge incscore or posedge reset)
    begin
      if (reset) begin
        score0 <= 0;
        score1 <= 0;
      end else if (score0 == 9) begin
        score0 <= 0;
        score1 <= score1 + 1;
      end else begin
        score0 <= score0 + 1;
      end
    end

endmodule

module scoreboard_generator(score0, score1, vpos, hpos, board_gfx);

  input [3:0] score0;
  input [3:0] score1;
  input [8:0] vpos;
  input [8:0] hpos;
  output board_gfx;

  reg [3:0] score_digit;
  reg [4:0] score_bits;
  
  always @(*)
    begin
      case (hpos[8:5])
        1: score_digit = score1;
        2: score_digit = score0;
        default: score_digit = 15; // no digit
      endcase
    end
  
  digits10_case digits(
    .digit(score_digit),
    .yofs(vpos[4:2]),
    .bits(score_bits)
  );

  assign board_gfx = score_bits[hpos[4:2] ^ 3'b111];
  
endmodule

module scoreboard_top(clk, reset, hsync, vsync, rgb);

  input clk, reset;
  output hsync, vsync;
  output [2:0] rgb;
  wire display_on;
  wire [8:0] hpos;
  wire [8:0] vpos;
  
  wire board_gfx;

  hvsync_Generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  scoreboard_generator scoreboard_gen(
    .score0(0),
    .score1(1),
    .vpos(vpos),
    .hpos(hpos),
    .board_gfx(board_gfx)
  );

  wire r = display_on && board_gfx;
  wire g = display_on && board_gfx;
  wire b = display_on && board_gfx;
  assign rgb = {b,g,r};

endmodule

`endif
