module codec_intf(clk,rst_n, SDout, lft_out, rht_out,
		  SDin, valid, lft_in, rht_in, LRCLK,SCLK,MCLK,RSTn);

input 	clk; 	//50MHz system clock
input 	rst_n;	//Active Low Master Reset
input 	SDout;
input 	[15:0] 	lft_out, rht_out;

output 	reg	SDin;
output  reg 	valid;
output	reg[15:0] lft_in, rht_in;
output 	reg	LRCLK;	//48.828kHz clock to CODEC
output 	reg	SCLK;	//1.5625MHz clock
output	reg	MCLK;	//12.5MHz Clock
output	logic	RSTn;	//Reset to CODEC
//intermediate variables
reg	[9:0]	clkcount; // clock counter
logic	receiving; //output from SM -- only when in ACTIVE mode
logic 	newtrans;	//input to the SM to transition from SLEEP->WAKEUP->ACTIVE
logic	LRCLK_rising, LRCLK_falling, SCLK_rising; //rising and falling edges of LRCLK 
reg	[15:0] lo, ro, shft_mux, shft_reg; //regs needed for the serial shift register

//determine different clock cycles
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		clkcount <= 10'h200; //starts high
	else 
		clkcount <= clkcount + 1;

end

//set up clock
assign MCLK   = clkcount[1];
assign SCLK   = clkcount[4];
assign LRCLK  = clkcount[9];

//define states
typedef enum reg[1:0] {SLEEP, WAKEUP, ACTIVE} state_t;
state_t state, next_state;

//implement state register
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state <= SLEEP;
	else
		state <= next_state;
end


//starts a new transistion for the SM
//clkcount 10'h201 is the count one clk after the rst_n is set (taken off)
assign newtrans = (clkcount == 10'h201);

//valid output: "code should work fine" -- Hoffman
assign valid = (clkcount >= 10'h1ef & clkcount < 10'h200) ? 1 : 0;


assign LRCLK_rising = (clkcount == 10'h1ff); //rising edge of LRCLK
assign LRCLK_falling = (clkcount == 10'h3ff); //falling edge of LRCLK
assign SCLK_rising = (clkcount[4:0] == 5'h0f);
//assign SCLK_falling = (clkcount[4:0] == 5'h1f);

///////////////////////////////////////////
//Outgoing double buffer /////////////////
/////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		lo <= 16'h0000;
		ro <= 16'h0000;
	end 
	else if(valid) begin
		lo <= lft_out;
		ro <= rht_out;
	end
	else begin
		lo <= lo;
		ro <= ro;
	end
end

//The input to the serial shift register
assign shft_mux =	(LRCLK_rising) 	? 	lo[15:0] : 
			(LRCLK_falling) ? 	ro[15:0] :
			(receiving) 	? 	{shft_reg[14:0], SDout} :
		   	shft_reg;

assign SDin = shft_reg[15]; //MSB of shift_reg to CODEC

//Operation of the shift register
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		shft_reg <= 16'h0000;
	else if (SCLK_rising)//shifts only occur on rising edge of SCLK
		shft_reg <= shft_mux;
end


//when LRCLK transitions low, the shift register contains 
//the audo data for the left channel
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		lft_in <= 16'h0000;
	else if(LRCLK_falling)
		lft_in <= shft_reg;
end

//The right data starts coming into the shift register on LRCLK rising
//when valid is asserted, the shift register will have the right audio data,
//therefore, rht_in can simply be assigned to be shft_reg
assign rht_in = shft_reg;


//////////////////////////////////////////////
//state transitions -- combinational logic  //
//////////////////////////////////////////////
always_comb
begin
   next_state = SLEEP;
   RSTn = 0;
   receiving = 0;
   case (state) 
	SLEEP: 	if(newtrans)
			next_state = WAKEUP;
		
	WAKEUP:		
		if(newtrans) 
			next_state = ACTIVE;
		else
			next_state = WAKEUP;
	default:
		begin
		RSTn = 1;
		receiving = 1;
		next_state = ACTIVE;
		end
   endcase
end
endmodule
