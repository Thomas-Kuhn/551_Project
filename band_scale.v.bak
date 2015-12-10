module band_scale(POT, audio, scaled);

input 	[11:0]POT;
input	signed [15:0]audio;
output 	reg signed [15:0]scaled;	//should this be of type REG...?
wire 	[23:0]POT_squared;	//stores value of the squared potentiometer
wire	[12:0]trunc_sq_POT;	
wire	signed [28:0]scaled_audio;
wire	signed [3:0] sat;
//POT^2, and then only use 12 MSB and append a 0 in the MSB.
assign POT_squared = POT * POT;

assign trunc_sq_POT = {1'b0,POT_squared[23:12]};

//multiply truncated squared pot value with the audiosignal
assign scaled_audio = trunc_sq_POT * audio;
assign sat = scaled_audio[28:25];

//calculate saturation
always@(*) begin
if	(!sat[3] && (sat[2] || sat[1] || sat[0]))
	scaled = 16'h7fff;		//if sat pos, pass 16'h7fff

else if	(sat[3] && (!sat[2] || !sat[1] || !sat[0]))
	scaled = 16'h8000; 		//if sat neg, pass 16'h8000

else
	scaled = scaled_audio[25:10];	//if neither, pass signal
end
endmodule
