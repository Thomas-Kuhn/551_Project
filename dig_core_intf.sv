module dig_core_intf(clk, rst_n, lft_in, rht_in, lft_out, rht_out, valid, POT_B1, POT_B2, POT_B3, POT_HP, POT_LP, POT_VOL, AMP_ON);

input clk, rst_n, valid;
input [15:0]lft_in, rht_in;
input [12:0]POT_B1, POT_B2, POT_B3, POT_HP, POT_LP, POT_VOL;
output [15:0]lft_out, rht_out;
output reg AMP_ON;

reg [9:0]addr;
wire fil_out_b1, fil_out_b2, fil_out_b3, fil_out_lp, fil_out_hp, fil_out_vol;

ROM_B1 b1(.clk(clk), .addr(addr), .dout(fil_out_b1));
ROM_B2 b2(.clk(clk), .addr(addr), .dout(fil_out_b2));
ROM_B3 b3(.clk(clk), .addr(addr), .dout(fil_out_b3));
ROM_LP lp(.clk(clk), .addr(addr), .dout(fil_out_lp));
ROM_HP hp(.clk(clk), .addr(addr), .dout(fil_out_hp));
ROM_HP vol(.clk(clk), .addr(addr), .dout(fil_out_vol));

circularBuffer1024 b1BuffL(.clk(clk), .rst_n(rst_n), .new_smpl(lft_in), .wrt_smpl(valid), .smpl_out(lft_out), .sequencing(AMP_ON));
circularBuffer1024 b1BuffR(.clk(clk), .rst_n(rst_n), .new_smpl(rht_in), .wrt_smpl(valid), .smpl_out(rht_out), .sequencing(AMP_ON));

endmodule
