module slide_intf(POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME,MISO,MOSI,SCLK,clk,rst_n,a2d_SS_n);

//Initialize the inputs and outputs
input MISO,rst_n,clk;
output reg [11:0] POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME;
output reg SCLK, MOSI, a2d_SS_n;

//intermediate signals
wire [15:0] res; //shifted data received from Spi_mstr
wire [11:0] res_POT;
reg strt_cnv;//Begin the conversion
reg [2:0]chnnl; //Channel used for the SPI_mstr
reg en_lp,en_b1,en_b2,en_b3,en_hp,en_vol; //enables for the POTS
reg cnv_cmplt;//The bit to let the enables know the conversion is complete

//Initialize the A2D converter interface
A2D_intf a2dint(.clk(clk),.rst_n(rst_n),.strt_cnv(strt_cnv),
	.cnv_cmplt(cnv_cmplt),.chnnl(chnnl),.res(res),
	.a2d_SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));

//state define
typedef enum reg{RESET,CONV}state_t;
state_t state,nxt_state;

assign res_POT = res[11:0];
//Enable Flops for each POT
always@(posedge clk) begin
if(en_lp)
	POT_LP <= res_POT;
end

always@(posedge clk) begin
if(en_b1)
	POT_B1 <= res_POT;
end

always@(posedge clk) begin
if(en_b2)
	POT_B2 <= res_POT;
end

always@(posedge clk) begin
if(en_b3)
	POT_B3 <= res_POT;
end

always@(posedge clk) begin
if(en_hp)
	POT_HP <= res_POT;
end

always@(posedge clk) begin
if(en_vol)
	VOLUME <= res_POT;
end

//state flipflop
always@(posedge clk or negedge rst_n)
begin
   if(!rst_n) begin
	state <= RESET;
   end else begin
	state <= nxt_state;
   end
end


//Enable the POTs in round robin when the conversion is complete
assign en_lp = (chnnl == 3'b000 && cnv_cmplt) ? 1'b1:1'b0; 
assign en_b1 = (chnnl == 3'b001 && cnv_cmplt) ? 1'b1:1'b0;
assign en_b2 = (chnnl == 3'b010 && cnv_cmplt) ? 1'b1:1'b0;
assign en_b3 = (chnnl == 3'b011 && cnv_cmplt) ? 1'b1:1'b0;
assign en_hp = (chnnl == 3'b100 && cnv_cmplt) ? 1'b1:1'b0;
assign en_vol = (chnnl == 3'b111 && cnv_cmplt) ? 1'b1:1'b0;

//Update the chnnl round robin fashion
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		chnnl <= 3'b000;
	end else if(cnv_cmplt) begin
		chnnl <= chnnl + 1;
		if(chnnl == 3'b101) chnnl <= 3'b111; 
	end	
end

	


//state trans logic
always_comb
begin
nxt_state = RESET;
case(state)
	RESET: begin		
		strt_cnv = 1'b1;
		nxt_state = CONV;
	end
	default://defines our conversion state
	begin
		strt_cnv = 1'b0;
		//Waits for the conversion to complete
		if(cnv_cmplt) begin
			nxt_state = RESET;
		end else
			nxt_state = CONV;
		
	end
endcase

end

endmodule
