
`include "hvsyncGenerator.v"
`include "bitmappedstarBackground.v"
`include "enemyspriteBitmap.v"
`include "missilespriteBitmap.v"
`include "playerspriteBitmap.v"
`include "playerspriteRendering.v"
`include "pointspriteBitmap.v"
`include "scoreBoard.v"
`include "bitmappedDigits.v"
`include "playerPoints.v"
`include "gameOver.v"


module arcadeGame_top(clk, reset, hsync, vsync, rgb, hpaddle, vpaddle, switches_c1);
//inputs:
  input clk, reset;
  input hpaddle, vpaddle;
  input [7:0] switches_c1;
 //inputs
  
  //outputs:
  output hsync, vsync;
  output [2:0] rgb;
  //outputs

  //wires: continuously assumes the value of its driver
  wire display_on;
  wire [8:0] hpos;
  wire [8:0] vpos;
  wire [3:0] player_sprite_yofs;
  wire [7:0] player_sprite_bits;
  wire [3:0] missile_sprite_yofs;
  wire [7:0] missile_sprite_bits;
  wire player_load = (hpos >= 256) && (hpos < 260);
  wire player_vstart = {1'b0,player_y} == vpos;
  wire player_hstart = {1'b0,player_x} == hpos;
  wire player_gfx;
  wire player_is_drawing;
   wire missile_load = (hpos >= 256) && (hpos < 260);
  wire missile_vstart = player_vstart;
  wire missile_hstart = player_hstart;
  wire missile_gfx;
  wire missile_is_drawing;
  wire enemy_hit_left = (enemy_x == 64);
  wire enemy_hit_right = (enemy_x == 192);
  wire enemy_hit_edge = enemy_hit_left || enemy_hit_right;
  wire enemy2_hit_left = (enemy2_x == 64);
  wire enemy2_hit_right = (enemy2_x == 192);
  wire enemy2_hit_edge = enemy2_hit_left || enemy2_hit_right;
  wire enemy3_hit_left = (enemy3_x == 64);
  wire enemy3_hit_right = (enemy3_x == 192);
  wire enemy3_hit_edge = enemy3_hit_left || enemy3_hit_right;
  wire enemy4_hit_left = (enemy4_x == 64);
  wire enemy4_hit_right = (enemy4_x == 192);
  wire enemy4_hit_edge = enemy4_hit_left || enemy4_hit_right;
  wire point_hit_left = (point_x == 64);
  wire point_hit_right = (point_x == 192);
  wire point_hit_edge = point_hit_left || point_hit_right;
  wire [3:0] enemy_sprite_yofs; 
  wire [7:0] enemy_sprite_bits;
  wire enemy_load = (hpos >= 260);
  wire enemy_vstart = {1'b0,enemy_y} == vpos;
  wire enemy_hstart = {1'b0,enemy_x} == hpos;
  wire enemy_gfx;
  wire enemy_is_drawing;
  wire [3:0] enemy2_sprite_yofs; 
  wire [7:0] enemy2_sprite_bits;
  wire enemy2_load = (hpos >= 260);
  wire enemy2_vstart = {1'b0,enemy2_y} == vpos;
  wire enemy2_hstart = {1'b0,enemy2_x} == hpos;
  wire enemy2_gfx;
  wire enemy2_is_drawing;
  wire [3:0] enemy3_sprite_yofs; 
  wire [7:0] enemy3_sprite_bits;
  wire enemy3_load = (hpos >= 260);
  wire enemy3_vstart = {1'b0,enemy3_y} == vpos;
  wire enemy3_hstart = {1'b0,enemy3_x} == hpos;
  wire enemy3_gfx;
  wire enemy3_is_drawing;
  wire [3:0] enemy4_sprite_yofs; 
  wire [7:0] enemy4_sprite_bits;
  wire enemy4_load = (hpos >= 260);
  wire enemy4_vstart = {1'b0,enemy4_y} == vpos;
  wire enemy4_hstart = {1'b0,enemy4_x} == hpos;
  wire enemy4_gfx;
  wire enemy4_is_drawing;
  wire point_load = (hpos >= 260);
  wire [3:0] point_sprite_yofs; 
  wire [7:0] point_sprite_bits; 
  wire point_vstart = {1'b0,point_y} == vpos;
  wire point_hstart = {1'b0,point_x} == hpos;
  wire point_gfx;
  wire point_is_drawing;
  wire [3:0] digit = hpos[7:4];
  wire [2:0] xofs = hpos[2:0];
  wire [2:0] yofs = vpos[3:1];
  wire [3:0] word_digit = hpos[7:4];
  wire [2:0] word_xofs = hpos[3:1] ;
  wire [2:0] word_yofs = vpos[3:1];
  wire [4:0] word_bits;
  wire [4:0] bits;
  wire background_gfx = (vpos[4:0]!=track_pos[4:0]) && bits[xofs ^ 3'b111];
  reg [3:0] score0;
  reg [3:0] score1;
  wire score_gfx;
  wire collision  = background_gfx && player_gfx;
  reg [3:0] score2;
  reg [3:0] score3;
  wire result_gfx;
  wire comeon_gfx;
  wire main_gfx;
wire r = display_on && (background_gfx | enemy_gfx | enemy2_gfx | enemy3_gfx);
  wire g = display_on && (background_gfx | point_gfx | enemy2_gfx | enemy4_gfx);
   wire b = display_on && (player_gfx | missile_gfx | background_gfx | main_gfx | comeon_gfx | enemy3_gfx | enemy4_gfx);
  //wires
  
  //registers: remembers the last value assigned to it
  reg [15:0] track_pos = 0; // player position along track
  reg [7:0] speed = 40; // player velocity along track
  reg [7:0] player_x;
  reg [7:0] player_y; 
  reg [7:0] missile_x = player_x;
  reg [7:0] missile_y = player_y;  
  reg [7:0] paddle_x;
  reg [7:0] paddle_y;
  reg enemy_dir = 0;
  reg enemy2_dir = 0;
  reg enemy3_dir = 0;
  reg enemy4_dir = 0;
  reg point_dir = 0;
  reg missile_dir = 0;
  reg [7:0] enemy_x = 85;
  reg [7:0] enemy_y = 85;
  reg [7:0] enemy2_x = 128;
  reg [7:0] enemy2_y = 128;
  reg [7:0] enemy3_x = 160;
  reg [7:0] enemy3_y = 160;
  reg [7:0] enemy4_x = 65;
  reg [7:0] enemy4_y = 65;
  reg [7:0] point_x = 45;
  reg [7:0] point_y = 45;
  reg incscore;
  reg incscore2;
  //registers
  
  
//includes
  hvsync_Generator hvsync_gen( 
    .clk(clk),
    .reset(0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
    player_bitmap player(
     .yofs(player_sprite_yofs), 
     .bits(player_sprite_bits));
  
   playersprite_renderer player_renderer(
    .clk(clk),
     .vstart(player_vstart),
     .load(player_load),
     .vsync(vsync),
     .switch_left(switches_c1[0]),
     .hstart(player_hstart),
     .rom_addr(player_sprite_yofs),
     .rom_bits(player_sprite_bits),
     .gfx(player_gfx),
     .in_progress(missile_is_drawing));
    
  
  
     enemy_bitmap enemy(
     .yofs(enemy_sprite_yofs), 
     .bits(enemy_sprite_bits));
  
   playersprite_renderer enemy1_renderer(
    .clk(clk),
     .vstart(enemy_vstart),
     .load(enemy_load),
     .vsync(vsync),
     .switch_left(switches_c1[0]),
     .hstart(enemy_hstart),
     .rom_addr(enemy_sprite_yofs),
     .rom_bits(enemy_sprite_bits),
     .gfx(enemy_gfx),
     .in_progress(enemy_is_drawing));
  
  
  
   enemy_bitmap enemy2(
     .yofs(enemy2_sprite_yofs), 
     .bits(enemy2_sprite_bits));
  
 playersprite_renderer enemy2_renderer(
    .clk(clk),
   .vstart(enemy2_vstart),
   .load(enemy2_load),
   .vsync(vsync),
   .switch_left(switches_c1[0]),
   .hstart(enemy2_hstart),
   .rom_addr(enemy2_sprite_yofs),
   .rom_bits(enemy2_sprite_bits),
   .gfx(enemy2_gfx),
   .in_progress(enemy2_is_drawing));
  
 
  
   enemy_bitmap enemy3(
     .yofs(enemy3_sprite_yofs), 
     .bits(enemy3_sprite_bits));
  
   playersprite_renderer enemy3_renderer(
    .clk(clk),
     .vstart(enemy3_vstart),
     .load(enemy3_load),
     .vsync(vsync),
     .switch_left(switches_c1[0]),
     .hstart(enemy3_hstart),
     .rom_addr(enemy3_sprite_yofs),
     .rom_bits(enemy3_sprite_bits),
     .gfx(enemy3_gfx),
     .in_progress(missile_is_drawing));
  
  
  enemy_bitmap enemy4(
    .yofs(enemy4_sprite_yofs), 
    .bits(enemy4_sprite_bits));
  
   playersprite_renderer enemy4_renderer(
    .clk(clk),
     .vstart(enemy4_vstart),
     .load(enemy4_load),
     .vsync(vsync),
     .switch_left(switches_c1[0]),
     .hstart(enemy4_hstart),
     .rom_addr(enemy4_sprite_yofs),
     .rom_bits(enemy4_sprite_bits),
     .gfx(enemy4_gfx),
     .in_progress(enemy4_is_drawing));
  
 
  
   point_bitmap point(
     .yofs(point_sprite_yofs), 
     .bits(point_sprite_bits));
  
  playersprite_renderer point_renderer(
    .clk(clk),
    .vstart(point_vstart),
    .load(point_load),
    .vsync(vsync),
    .switch_left(switches_c1[0]),
    .hstart(point_hstart),
    .rom_addr(point_sprite_yofs),
    .rom_bits(point_sprite_bits),
    .gfx(point_gfx),
    .in_progress(point_is_drawing));
  
  
  missile_bitmap missile(
    .yofs(missile_sprite_yofs),
    .bits(missile_sprite_bits));
  
   playersprite_renderer missile_renderer(
    .clk(clk),
     .vstart(missile_vstart),
     .load(missile_load),
     .vsync(vsync),
     .switch_left(switches_c1[0]),
     .hstart(missile_hstart),
     .rom_addr(missile_sprite_yofs),
     .rom_bits(missile_sprite_bits),
     .gfx(missile_gfx),
     .in_progress(missile_is_drawing));
    
 Dots_10_case stars(
    .digit(digit),
    .yofs(yofs),
    .bits(bits)
  );
  
    player_stats stats(
    .reset(reset),
    .score0(score0),
    .score1(score1),
    .incscore(incscore)
  );
  
   scoreboard_generator score_gen(
    .score0(score0),
    .score1(score1),
    .vpos(vpos),
    .hpos(hpos), 
    .board_gfx(score_gfx)
  );
     player_stats stats2(
    .reset(reset),
      .score0(score2),
      .score1(score3),
      .incscore(incscore2)
  );
     
     scorepoint_generator scoreboard_gen(
       .score0(score2),
       .score1(score3),
    .vpos(vpos),
    .hpos(hpos),
       .board_gfx(result_gfx)
     );
 
  
   game_Over words(
     .digit(word_digit),
     .yofs(word_yofs),
     .bits(word_bits)
  );
  
  //includes
  
  always @(posedge hsync) //set paddle registers code 
    begin
      if (!hpaddle) 
        paddle_x <= vpos[7:0];
      if (!vpaddle) 
        paddle_y <= vpos[7:0];
    end
  
  always @(posedge vsync) //update code / vertical movement begin
    begin
       enemy_x <= enemy_x - 1;
        enemy2_x <= enemy2_x - 1;
       enemy3_x <= enemy3_x - 1;
      enemy4_x <= enemy4_x - 1;
      point_x <= point_x - 1;
         player_x <= paddle_x;
      player_y <= 180;
      missile_x <= player_x;
      missile_y <= player_y;
//      if (switches_ch1[2]
//          begin
    //  missile_y <= missile_y - {3'b0, speed[6:3]}; 
      
      if (switches_c1[0])
        begin
      enemy_y <= enemy_y + {3'b0, speed[6:3]};
      enemy2_y <= enemy2_y + {3'b0, speed[6:3]};
      enemy3_y <= enemy3_y + {3'b0, speed[6:3]};
      enemy4_y <= enemy4_y + {3'b0, speed[6:3]};
      point_y <= point_y + {3'b0, speed[6:3]};
         /*  if (enemy_hit_edge)
             begin
        enemy_dir <= !enemy_dir;
             end
      else if (enemy2_hit_edge)
        begin
        enemy2_dir <= !enemy2_dir;
          end
      else if (enemy3_hit_edge)
        begin
        enemy3_dir <= !enemy3_dir;
        end
      else if (enemy_dir ^ enemy_hit_edge)
        begin
        enemy_x <= enemy_x - 12;
        end
      else if (enemy2_hit_edge)
        begin
        enemy2_dir <= !enemy2_dir;
        end
      else if (enemy2_dir ^ enemy2_hit_edge)
        begin
        enemy2_x <= enemy2_x + 2;
        end
      else if (enemy3_hit_edge)
        begin
        enemy3_dir <= !enemy3_dir;
        end
      else if (enemy3_dir ^ enemy3_hit_edge)
        begin
        enemy3_x <= enemy3_x + 5;
        end
      else if (enemy4_hit_edge)
        begin
        enemy4_dir <= !enemy4_dir;
        end
      else if (enemy4_dir ^ enemy4_hit_edge)
        begin
        enemy4_x <= enemy4_x + 5;
        end
      else if (point_hit_edge)
        begin
        point_dir <= !point_dir;
        end
      else if (point_dir ^ point_hit_edge)
        begin
        point_x <= point_x + 3;
        end */
      end
         else if (collision && enemy_gfx | collision && enemy2_gfx | collision && enemy3_gfx| collision && enemy4_gfx)
            begin
            enemy_x <= enemy_x;
        enemy2_x <= enemy2_x;
       enemy3_x <= enemy3_x;
      enemy4_x <= enemy4_x;
      point_x <= point_x;
         player_x <= 180;
      player_y <= 180;
      missile_x <= player_x;
            end
        end
     
  
   always @(*)
    begin
      case (vpos[8:3])
        0,1,2: comeon_gfx = result_gfx;
        default: comeon_gfx = 0;
      endcase
      //if(switch_up)
      //  begin
   // end
    end
     
  //point code end
  
  //missile code begin
 /* reg [7:0] missile_x = 45;
  reg [7:0] missile_y = 45;
  wire missile_load = (hpos >= 260);
  wire [3:0] missile_sprite_yofs; 
  wire [7:0] missile_sprite_bits; 
  
   missile_bitmap point(
     .yofs(point_sprite_yofs), 
     .bits(point_sprite_bits));
  
  wire missile_vstart = {1'b0,point_y} == vpos;
  wire missile_hstart = {1'b0,point_x} == hpos;
  wire missile_gfx;
  wire missile_is_drawing;
  

     */
  //missile code end
  
  always @(posedge clk) //sequential logic (memory)
    if((collision && enemy_gfx)|(collision && enemy2_gfx)|(collision && enemy3_gfx)|(collision && enemy4_gfx)) 
   begin 
     
    
    // r <= display_on && 0;
    // g <= display_on && word_bits[word_xofs ^ 3'b111];;
   // b <= display_on && 0;
    
    end
    else if(player_gfx && point_gfx)
       begin       
        incscore<=1;
       end
  else 
    begin
        incscore<=0;
      end
  

 
        

  always @(*)
    if(score0 ==9 && score1 == 9)
       begin
  	
        incscore2 = 1;
       
      end else begin
        incscore2 = 0;
      end
 
  always @(*)
    begin
      case (vpos[8:3])
        0,1,2: comeon_gfx = result_gfx;
        default: comeon_gfx = 0;
      endcase
    end
  
  always @(*) //displays points?
    begin
      case (vpos[8:3])
        0,1,2: main_gfx = score_gfx;
        default: main_gfx = 0;
      endcase
    end
  
  assign rgb = {b,g,r}; // output color code, combinational logic (memoryless)
  
endmodule
