`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

/*
* Video sync generator, used to drive a simulated CRT
* To use:
	* Wire the hsync and vsync signals to top level outputs
	* Add a 3-bit (or more) "rgb" output to the top level
*/

module hvsync_generator(clk, reset, hsync, vsync, display_on, hpos, vpos);

input clk;
input reset;
output hsync;
output vsync;

output display_on;
output [8:0] hpos;
output [8:0] vpos;

reg hsync;
reg vsync;
reg [8:0] hpos;
reg [8:0] vpos;

// declarations for TV-simulator sync parameters
// horizontal constants
parameter H_DISPLAY 			= 256; 	// horizontal display width
parameter H_BACK					= 23;		// horizontal left border (back porch)	
parameter H_FRONT 				= 7;		// horizontal right border (front porch)
parameter H_SYNC					= 23;		// horizontal sync width

// vertical constants
parameter V_DISPLAY				= 240;	// vertical display height
parameter V_TOP						= 5;		// vertical top border
parameter V_BOTTOM				= 14;		// vertical bottom border
parameter V_SYNC					= 8;		// vertical sync # lines

// derived constants
parameter H_SYNC_START		= H_DISPLAY + H_FRONT;
parameter H_SYNC_END			= H_DISPLAY + H_FRONT + H_SYNC - 1;
parameter H_MAX						= H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
parameter V_SYNC_START  	= V_DISPLAY + V_BOTTOM;
parameter V_SYNC_END			= V_DISPLAY + V_BOTTOM + V_SYNC - 1;
parameter V_MAX						= V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;

wire hmaxxed = (hpos == H_MAX) || reset;	// set when hpos is maximum
wire vmaxxed = (vpos == V_MAX) || reset;	// set when vpos is maximum

// horizontal position counter
always @(posedge clk) begin
	hsync <= (hpos >= H_SYNC_START && hpos <= H_SYNC_END);
	if (hmaxxed)
		hpos <= 0;
	else
		hpos <= hpos + 1;
end

// vertical position counter
always @(posedge clk) begin
	vsync <= (vpos >= V_SYNC_START && vpos <= V_SYNC_END);
	if (hmaxxed)
		if (vmaxxed)
			vpos <= 0;
		else
			vpos <= vpos + 1;
end

// display_on is set when beam is in "safe" visible frame
assign display_on = (hpos<H_DISPLAY) && (vpos < V_DISPLAY);
endmodule

module hvsync_generator_top(clk, reset, hsync, vsync, rgb);

input clk;
input reset;

output hsync;
output vsync;
output [2:0] rgb;

wire display_on;
wire [8:0] hpos;
wire [8:0] vpos;

hvsync_generator hvsync_gen(
	.clk(clk),
	.reset(reset),
	.hsync(hsync),
	.vsync(vsync),
	.display_on(display_on),
	.hpos(hpos),
	.vpos(vpos)
);

// (hpos&7) == 0 <=> hpos[2:0] == 0 (dung slice)
// (hpos&7) == 0 <=> (hpos % 8) == 0 (dung phep chia)
wire r = display_on && (((hpos&7)==0)&&((vpos&7)==0));
wire g = display_on && (vpos[4] || hpos[4]);
wire b = display_on && hpos[4];

assign rgb = {b,g,r};
endmodule
`endif
