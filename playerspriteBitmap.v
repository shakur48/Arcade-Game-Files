
`ifndef PLAYERSPRITE_BITMAP_H
`define PLAYERSPRITE_BITMAP_H

`include "hvsyncGenerator.v"

module player_bitmap(yofs, bits);
  
  input [3:0] yofs;
  output [7:0] bits;

  reg [7:0] bitarray[0:15];
  
  assign bits = bitarray[yofs];
  
  initial begin/*{w:8,h:16}*/
     bitarray[0] = 8'b0;
    bitarray[1] = 8'b11111111;
    bitarray[2] = 8'b11111111;
    bitarray[3] = 8'b11111111;
    bitarray[4] = 8'b11111111;
    bitarray[5] = 8'b11111111;
    bitarray[6] = 8'b11111111;
    bitarray[7] = 8'b11111111;
    bitarray[8] = 8'b11111111;
    bitarray[9] = 8'b11111111;
    bitarray[10] = 8'b11111111;
    bitarray[11] = 8'b11111111;
    bitarray[12] = 8'b11111111;
    bitarray[13] = 8'b11111111;
    bitarray[14] = 8'b11111111;
    bitarray[15] = 8'b11111111;
  end
  
endmodule

module playersprite_bitmap_top(clk, reset, hsync, vsync, rgb);

  input clk, reset;
  output hsync, vsync;
  output [2:0] rgb;
  wire display_on;
  wire [8:0] hpos;
  wire [8:0] vpos;
  
  //player sptrites
  reg sprite_active;
  reg [3:0] player_sprite_xofs;
  reg [3:0] player_sprite_yofs;
  wire [7:0] player_sprite_bits;
  
  reg [8:0] player_x = 128;
  reg [8:0] player_y = 128;

  hvsync_Generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  player_bitmap player(
    .yofs(player_sprite_yofs),
    .bits(player_sprite_bits));
  
   // start Y counter when we hit the top border (player_y)
  always @(posedge hsync)
    if (vpos == player_y)
      player_sprite_yofs <= 15;
  else if (player_sprite_yofs != 0)
      player_sprite_yofs <= player_sprite_yofs - 1;
  
  // restart X counter when we hit the left border (player_x)
  always @(posedge clk)
    if (hpos == player_x)
      player_sprite_xofs <= 15;
  else if (player_sprite_xofs != 0)
      player_sprite_xofs <= player_sprite_xofs - 1;
  
  wire [3:0] player_bit = player_sprite_xofs>=8 ? 
                                 15-player_sprite_xofs:
                                 player_sprite_xofs;
  // The actual display of the player
  wire player_gfx = player_sprite_bits[player_bit[2:0]];

  wire r = display_on && player_gfx;
  wire g = display_on && player_gfx;
  wire b = display_on && player_gfx;
  assign rgb = {b,g,r};

endmodule
`endif
