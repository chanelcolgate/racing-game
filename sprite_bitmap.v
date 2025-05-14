`ifndef SPRITE_BITMAP_H
`define SPRITE_BITMAP_H

`include "hvsync_generator.v"

/*
* Simple sprite renderer example
* car_bitmap - ROM for a car sprite
* sprite_bitmap_top - Example sprite rendering module
*/

module car_bitmap(yofs, bits);

input [3:0] yofs;

output [7:0] bits;

reg [7:0] bitarray [0:15];

assign bits = bitarray[yofs];

initial begin /*{w:8,h:16}*/
	bitarray[0] = 8'b0000_0000;
	bitarray[1] = 8'b0000_1100;
	bitarray[2] = 8'b1100_1100;
	bitarray[3] = 8'b1111_1100;
	bitarray[4] = 8'b1110_1100;
	bitarray[5] = 8'b1110_0000;
	bitarray[6] = 8'b0110_0000;
	bitarray[7] = 8'b0111_0000;
	bitarray[8] = 8'b0011_0000;
	bitarray[9] = 8'b0011_0000;
	bitarray[10] = 8'b0011_0000;
	bitarray[11] = 8'b0110_1110;
	bitarray[12] = 8'b1110_1110;
	bitarray[13] = 8'b1111_1110;
	bitarray[14] = 8'b1110_1110;
	bitarray[15] = 8'b0010_1110;
end
endmodule

module sprite_bitmap_top(clk, reset, hsync, vsync, rgb);

input clk;
input reset;
output hsync;
output vsync;
output [2:0] rgb;

wire display_on;
wire [8:0] hpos;
wire [8:0] vpos;

reg sprite_active;
reg [3:0] car_sprite_xofs;
reg [3:0] car_sprite_yofs;
wire [7:0] car_sprite_bits;

reg [8:0] player_x = 128;
reg [8:0] player_y = 128;

hvsync_generator hvsync_gen(
	.clk(clk),
	.reset(reset),
	.hsync(hsync),
	.vsync(vsync),
	.display_on(display_on),
	.hpos(hpos),
	.vpos(vpos)
);

car_bitmap car(
	.yofs(car_sprite_yofs),
	.bits(car_sprite_bits)
);

// start Y counter when we hit the top border (player_y)
// do bat dau tu 15 nen xe bi nguoc
always @(posedge hsync)
	if (vpos == player_y)
		car_sprite_yofs <= 15;
	else if (car_sprite_yofs != 0)
		car_sprite_yofs <= car_sprite_yofs - 1;

// start X counter when we hit the left border (player_x)
always @(posedge clk)
	if (hpos == player_x)
		car_sprite_xofs <= 15;
	else if (car_sprite_xofs != 0)
		car_sprite_xofs <= car_sprite_xofs - 1;

// mirror sprite in X direction
wire [3:0] car_bits = car_sprite_xofs[3] ? car_sprite_xofs ^ 7 : car_sprite_xofs;

// reduced 4-bit value to 3 bits and lookup bit in ROM
wire car_gfx = car_sprite_bits[car_bits[2:0]];

wire r = display_on && car_gfx;
wire g = display_on && car_gfx;
wire b = display_on && car_gfx;
assign rgb = {b,g,r};
endmodule
`endif
