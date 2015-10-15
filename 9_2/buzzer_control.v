`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:16:42 09/11/2015 
// Design Name: 
// Module Name:    buzzer_control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module buzzer_control(
press_loud,
press_quiet,
low_clk,
clk, // clock from crystal
rst_n, // active low reset
note_div, // div for note generation
audio_left, // left sound audio
audio_right, // right sound audio
level1,
level0,
LED
);
// I/O declaration
input press_loud,press_quiet;
input low_clk;
input clk; // clock from crystal
input rst_n; // active low reset
input [19:0] note_div; // div for note generation
output [15:0] audio_left; // left sound audio
output [15:0] audio_right; // right sound audio
output reg [3:0]level1,level0;
output reg[15:0]LED;
// Declare internal signals
reg [19:0] clk_cnt_next, clk_cnt;
reg b_clk, b_clk_next;
//sound level
reg [3:0]level_t,level;
reg [15:0]loud,loud_t;
reg [15:0]LED_t;
// Note frequency generation
always @(posedge clk or negedge rst_n)
if (~rst_n)
begin
clk_cnt <= 20'd0;
b_clk <= 1'b0;
end
else
begin
clk_cnt <= clk_cnt_next;
b_clk <= b_clk_next;
end
always @*
if (clk_cnt == note_div)
begin
clk_cnt_next = 20'd0;
b_clk_next = ~b_clk;
end
else
begin
clk_cnt_next = clk_cnt + 1'b1;
b_clk_next = b_clk;
end
//sound level control
always@(posedge low_clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		loud_t<=loud;
		level_t<=4'd0;
	end
	else
	begin
		if(~press_loud)
		begin
			loud_t<=loud-16'h0300;
			level_t<=level+4'd1;
			LED_t<=loud_t;
		end
		else if (~press_quiet)
		begin
			loud_t<=loud+16'h0300;
			level_t<=level-4'd1;
			LED_t<=loud_t;
		end
		else
		begin
			loud_t<=loud_t;
			level_t<=level_t;
			LED_t<=LED_t;
		end
	end
end
always@(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		loud<=16'h8000;
		level<=4'd0;
		LED<=loud;
	end
	else
	begin
		loud<=loud_t;
		level<=level_t;
		LED<=LED_t;
	end
end
always@(*)
begin
	level1<=level/10;
	level0<=level%10;
end
// Assign the amplitude of the note
assign audio_left = (b_clk == 1'b0) ? 16'h8000 : loud;
assign audio_right = (b_clk == 1'b0) ? 16'h8000 : loud;
endmodule
