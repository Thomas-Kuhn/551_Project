module EqualizerLoopBack(RST_n, clk, SDout, SCL, MCLK, LRCLK, RSTn, SDin);

input RST_n, clk;
wire rst_n;

input SDout;
reg[15:0] rht_out, lft_out;
reg sel;

wire [15:0] rht_in, lft_in;
wire valid;
output reg SDin, LRCLK, SCL, MCLK, RSTn;
rst_synch rs(.RST_n(RST_n), .clk(clk), .rst_n(rst_n));

codec_intf ci(.clk(clk), .rst_n(rst_n), .SDout(SDout), .lft_out(lft_out), .rht_out(rht_out),
		  .SDin(SDin), .valid(valid), .lft_in(lft_in), .rht_in(rht_in), .LRCLK(LRCLK),.SCLK(SCL),.MCLK(MCLK),.RSTn(RSTn));
always @(posedge valid)begin
	if(valid)
		sel <= 1'b1;
	else
		sel <= 1'b0;
end

always @(posedge clk)begin
	if(sel) begin
		rht_out <= rht_in;
		lft_out <= lft_in;
	end
end

endmodule
