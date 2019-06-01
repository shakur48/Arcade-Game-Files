`ifndef DOTS10_H
`define DOTS10_H
`include "hvsyncGenerator.v"
module Dots_10_case( digit, yofs, bits);
  input [3:0] digit;		// digit 0-9
  input [2:0] yofs;		// vertical offset (0-4)
  output [4:0] bits;		// output (5 bits)
 

  reg [4:0] bitarray[0:15][0:4]; // ROM array (16 x 5 x 5 bits)

  assign bits = bitarray[digit][yofs];	// assign module output
  
  
  integer i,j;
  
  initial begin/*{w:5,h:5,count:10}*/
    bitarray[0][0] = 5'b101;
    bitarray[0][1] = 5'b010;
    bitarray[0][2] = 5'b01010;
    bitarray[0][3] = 5'b01010;
    bitarray[0][4] = 5'b0;

    bitarray[1][0] = 5'b00;
    bitarray[1][1] = 5'b1;
    bitarray[1][2] = 5'b0;
    bitarray[1][3] = 5'b0;
    bitarray[1][4] = 5'b0;

    bitarray[2][0] = 5'b0;
    bitarray[2][1] = 5'b0;
    bitarray[2][2] = 5'b1;
    bitarray[2][3] = 5'b0;
    bitarray[2][4] = 5'b0;

    bitarray[3][0] = 5'b0;
    bitarray[3][1] = 5'b0;
    bitarray[3][2] = 5'b0;
    bitarray[3][3] = 5'b1;
    bitarray[3][4] = 5'b0;

    bitarray[4][0] = 5'b0;
    bitarray[4][1] = 5'b0;
    bitarray[4][2] = 5'b0;
    bitarray[4][3] = 5'b0;
    bitarray[4][4] = 5'b1;

    bitarray[5][0] = 5'b1;
    bitarray[5][1] = 5'b0;
    bitarray[5][2] = 5'b0;
    bitarray[5][3] = 5'b0;
    bitarray[5][4] = 5'b0;

    bitarray[6][0] = 5'b0;
    bitarray[6][1] = 5'b1;
    bitarray[6][2] = 5'b0;
    bitarray[6][3] = 5'b0;
    bitarray[6][4] = 5'b0;

    bitarray[7][0] = 5'b0;
    bitarray[7][1] = 5'b0;
    bitarray[7][2] = 5'b1;
    bitarray[7][3] = 5'b0;
    bitarray[7][4] = 5'b0;

    bitarray[8][0] = 5'b0;
    bitarray[8][1] = 5'b0;
    bitarray[8][2] = 5'b0;
    bitarray[8][3] = 5'b1;
    bitarray[8][4] = 5'b0;

    bitarray[9][0] = 5'b0;
    bitarray[9][1] = 5'b0;
    bitarray[9][2] = 5'b0;
    bitarray[9][3] = 5'b0;
    bitarray[9][4] = 5'b1;
    
    bitarray[10][0] = 5'b0;
    bitarray[10][1] = 5'b1;
    bitarray[10][2] = 5'b0;
    bitarray[10][3] = 5'b0;
    bitarray[10][4] = 5'b0;
    
    bitarray[11][0] = 5'b0;
    bitarray[11][1] = 5'b0;
    bitarray[11][2] = 5'b1;
    bitarray[11][3] = 5'b0;
    bitarray[11][4] = 5'b0;
    
    bitarray[12][0] = 5'b0;
    bitarray[12][1] = 5'b0;
    bitarray[12][2] = 5'b0;
    bitarray[12][3] = 5'b1;
    bitarray[12][4] = 5'b0;
    
    bitarray[13][0] = 5'b0;
    bitarray[13][1] = 5'b0;
    bitarray[13][2] = 5'b0;
    bitarray[13][3] = 5'b0;
    bitarray[13][4] = 5'b1;
    
    bitarray[14][0] = 5'b1;
    bitarray[14][1] = 5'b0;
    bitarray[14][2] = 5'b0;
    bitarray[14][3] = 5'b0;
    bitarray[14][4] = 5'b0;
    
    bitarray[15][0] = 5'b0;
    bitarray[15][1] = 5'b1;
    bitarray[15][2] = 5'b0;
    bitarray[15][3] = 5'b0;
    bitarray[15][4] = 5'b0;
   
    
    
    
    // clear unused array entries
    //for (i = 10; i <= 15; i++)
    //  for (j = 0; j <= 4; j++) 
     //   bitarray[i][j] = 0; 
  end
endmodule

module Dots10_case_top(clk, reset, hsync, vsync, rgb);

  input clk, reset;
  output hsync, vsync;
  output [2:0] rgb;
  wire display_on;
  wire [8:0] hpos;
  wire [8:0] vpos;

  hvsync_Generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  
  
  wire [3:0] digit = hpos[5:2];
  wire [2:0] xofs = hpos[3:1];
  wire [2:0] yofs = vpos[3:1];
  wire [4:0] bits;
  
   // background graphics begin signals
  reg [15:0] background_pos = 1;	// player position along track (16 bits)
  reg [7:0] speed = 31;		// player velocity along track (8 bits)
  wire background_gfx = (vpos[4:0]!=background_pos[4:0]) && bits[xofs ^ 3'b111];
   //Summons the yellow stars
  Dots_10_case yellowStars(
    .digit(digit),
    .yofs(yofs),
    .bits(bits)
  );
  //background graphics end
  wire r = display_on && background_gfx;
  wire g = display_on && background_gfx;
  wire b = display_on && 0;
  assign rgb = {b,g,r};

endmodule
`endif
