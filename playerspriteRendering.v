
`ifndef PLAYERSPRITE_RENDERER_H
`define PLAYERSPRITE_RENDERER_H

`include "hvsyncGenerator.v"
`include "playerspriteBitmap.v"


/*
Displays a 16x16 sprite (8 bits mirrored left/right).
*/

   

module playersprite_renderer(clk, vstart, load, hstart, rom_addr, rom_bits, 
                       gfx, in_progress, vsync, switch_left);
  
  input clk;
  input vstart;		// start drawing (top border)
  input load;		// ok to load sprite data?
  input hstart; // start drawing scanline (left border)
  input vsync;
  input switch_left;
  output [3:0] rom_addr;	// select ROM address
  input [7:0] rom_bits;		// input bits from ROM
  output gfx;		// output pixel
  output in_progress;	// 0 if waiting for vstart
  
  reg [2:0] state;	// current state #
  reg [3:0] ycount;	// number of scanlines drawn so far
  reg [3:0] xcount;	// number of horiz. pixels in this line
  
  reg [7:0] outbits;	// register to store bits from ROM
  
  // states for state machine
  localparam WAIT_FOR_VSTART = 0;
  localparam WAIT_FOR_LOAD   = 1;
  localparam LOAD1_SETUP     = 2;
  localparam LOAD1_FETCH     = 3;
  localparam WAIT_FOR_HSTART = 4;
  localparam DRAW            = 5;

  // assign in_progress output bit
  assign in_progress = state != WAIT_FOR_VSTART;

  always @(posedge clk)
    begin
      case (state)
        WAIT_FOR_VSTART: begin
          ycount <= 0; // initialize vertical count
          gfx <= 0; // default pixel value (off)
          // wait for vstart, then next state
          if (vstart)
            state <= WAIT_FOR_LOAD;
        end
        WAIT_FOR_LOAD: begin
          xcount <= 0; // initialize horiz. count
	  gfx <= 0;
          // wait for load, then next state
          if (load)
            state <= LOAD1_SETUP;
        end
        LOAD1_SETUP: begin
          rom_addr <= ycount; // load ROM address
          state <= LOAD1_FETCH;
        end
        LOAD1_FETCH: begin
	  outbits <= rom_bits; // latch bits from ROM
          state <= WAIT_FOR_HSTART;
        end
        WAIT_FOR_HSTART: begin
          // wait for hstart, then start drawing
          if (hstart)
            state <= DRAW;
        end
        DRAW: begin
          // get pixel, mirroring graphics left/right
          gfx <= outbits[xcount<8 ? xcount[2:0] : ~xcount[2:0]];
          xcount <= xcount + 1;
          // finished drawing horizontal slice?
          if (xcount == 15) begin // pre-increment value
            ycount <= ycount + 1;
            // finished drawing sprite?
            if (ycount == 15) // pre-increment value
              state <= WAIT_FOR_VSTART; // done drawing sprite
            else
	      state <= WAIT_FOR_LOAD; // done drawing this scanline
          end
        end
        // unknown state -- reset
        default: begin
          state <= WAIT_FOR_VSTART; 
        end
      endcase
    end
  
 
  reg [7:0] player_x;
  reg [7:0] player_y;
  reg [7:0] player_yy;
  reg [7:0] player_xx;
  reg [7:0] speed = 40; // player velocity along track
  
   always @(posedge vsync)
    begin
      player_x <= player_x;
      player_y <= player_y;
        if (switch_left)
          begin
         player_y <= player_y;
    player_x <= player_x;
       end
    end
  
  
endmodule

/// TEST MODULE

module sprite_render_test_top(clk, hsync, vsync, rgb, hpaddle, vpaddle, switches_p1);

  input clk;
  input hpaddle, vpaddle;
  input [7:0] switches_p1;
  output hsync, vsync;
  output [2:0] rgb;
  wire display_on;
  wire [8:0] hpos;
  wire [8:0] vpos;
  
   // convert player X/Y to 9 bits and compare to CRT hpos/vpos
  wire vstart = {1'b0,player_y} == vpos;
  wire hstart = {1'b0,player_x} == hpos;

    // player position
  reg [7:0] player_x = 180;
  reg [7:0] player_y = 180;
 
  
  // paddle position
  reg [7:0] paddle_x;
  reg [7:0] paddle_y;
  
  reg [7:0] player_yy = paddle_x;
  reg [7:0] player_xx = paddle_y;
  
  // video sync generator
  hvsync_Generator hvsync_gen(
    .clk(clk),
    .reset(0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  // car bitmap ROM and associated wires
  wire [3:0] player_sprite_addr;
  wire [7:0] player_sprite_bits;
  
  player_bitmap player(
    .yofs(player_sprite_addr), 
    .bits(player_sprite_bits));
   

  
  wire player_gfx;		// car sprite video signal
  wire in_progress;	// 1 = rendering taking place on scanline

playersprite_renderer renderer(
    .clk(clk),
    .vstart(vstart),
    .load(hsync),
    .hstart(hstart),
  .rom_addr(player_sprite_addr),
  .rom_bits(player_sprite_bits),
  .gfx(player_gfx),
  .in_progress(in_progress),
  .vsync(vsync),
  .switch_left(switches_p1[0]));
  

    // measure paddle position
  always @(posedge hpaddle)
    paddle_x <= vpos[7:0];

  always @(posedge vpaddle)
    paddle_y <= vpos[7:0];
 


 
  // video RGB output
  wire r = display_on && player_gfx;
  wire g = display_on && player_gfx;
  wire b = display_on && in_progress;
  assign rgb = {b,g,r};
  



endmodule

`endif
