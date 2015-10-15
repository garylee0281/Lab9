`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:14:30 09/11/2015 
// Design Name: 
// Module Name:    Lab9_2 
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
module Lab9_2(
button_loud,
button_quiet,
button_Do,
button_Re,
button_Mi,
clk, // clock from crystal
reset, // active low reset
audio_appsel, // playing mode selection
audio_sysclk, // control clock for DAC (from crystal)
audio_bck, // bit clock of audio data (5MHz)
audio_ws, // left/right parallel to serial control
audio_data, // serial output audio data
display,
display_ctl,
LED
);
// I/O declaration
input button_loud,button_quiet;
input button_Do,button_Re,button_Mi;
input clk; // clock from the crystal
input reset; // active low reset
output audio_appsel; // playing mode selection
output audio_sysclk; // control clock for DAC (from crystal)
output audio_bck; // bit clock of audio data (5MHz)
output audio_ws; // left/right parallel to serial control
output audio_data; // serial output audio data
output [14:0]display;
output [3:0]display_ctl;
output [15:0]LED;
// Declare internal nodes
wire [15:0] audio_in_left, audio_in_right;

wire [3:0] level1,level0;//sound level

wire [1:0]ftsd_ctl_en;
wire [3:0]bcd;
wire clk_out;
// Note generation
//Do 153257 Re 136519 Me 121212
reg [19:0]input_sound;
always@(posedge clk or negedge reset)
begin
	if(~reset)
	begin
		input_sound<=20'd0;
	end
	else
	begin
		if(~button_Do)
		begin
			input_sound<=153257;
		end
		else if (~button_Re)
		begin
			input_sound<=136519;
		end
		else if (~button_Mi)
		begin
			input_sound<=20'd121212;
		end
		else
		begin
			input_sound<=20'd0;
		end
	end
end

buzzer_control Ung(
.press_loud(button_loud),
.press_quiet(button_quiet),
.low_clk(clk_out),
.clk(clk), // clock from crystal
.rst_n(reset), // active low reset
.note_div(input_sound), // div for note generation
.audio_left(audio_in_left), // left sound audio
.audio_right(audio_in_right), // right sound audio
.level1(level1),
.level0(level0),
.LED(LED)
);
speaker_ctl Usc(
.clk(clk), // clock from the crystal
.reset(reset), // active low reset
.audio_in_left(audio_in_left), // left channel audio data input
.audio_in_right(audio_in_right), // right channel audio data input
.audio_appsel(audio_appsel), // playing mode selection
.audio_sysclk(audio_sysclk), // control clock for DAC (from crystal)
.audio_bck(audio_bck), // bit clock of audio data (5MHz)
.audio_ws(audio_ws), // left/right parallel to serial control
.audio_data(audio_data) // serial output audio data
);
//display
freq_divider fd(
	.clk_out(clk_out),
	.clk_ctl(ftsd_ctl_en), // divided clock output for scan freq
	.clk(clk), // global clock input
	.rst_n(reset) // active low reset
	);
scanf sf(
   .ftsd_ctl(display_ctl), // ftsd display control signal 
	.ftsd_in(bcd), // output to ftsd display
	.in0(4'd0), // 1st input
	.in1(4'd0), // 2nd input
	.in2(level1), // 3rd input
	.in3(level0), // 4th input
	.ftsd_ctl_en(ftsd_ctl_en) // divided clock for scan control
	);
bcd_d(
   .display(display), // 14-segment display output
	.bcd(bcd) // BCD input
	);	
endmodule
