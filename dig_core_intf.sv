module dig_core_intf(clk, rst_n, lft_in, rht_in, lft_out, rht_out, valid, POT_B1, POT_B2, POT_B3, POT_HP, POT_LP, POT_VOL, AMP_ON);

input clk, rst_n, valid;
input [15:0]lft_in, rht_in;
input [12:0]POT_B1, POT_B2, POT_B3, POT_HP, POT_LP, POT_VOL;
output [15:0]lft_out, rht_out;
output reg AMP_ON;

wire [15:0]rd_out_low_L, rd_out_low_R, rd_out_high_L, rd_out_high_R;
wire low_seq_L, low_seq_R, high_seq_L, high_seq_R;
wire signed[31:0] filtered_lp_L, filtered_lp_R,  filtered_b1_L, filtered_b1_R, filtered_b2_L, filtered_b2_R, filtered_b3_L, filtered_b3_R,  filtered_hp_L, filtered_hp_R;

circularBuffer1024 lpBuffL(.clk(clk), .rst_n(rst_n), .new_smpl(lft_in), .wrt_smpl(valid), .smpl_out(rd_out_low_L), .sequencing(low_seq_L));
circularBuffer1024 lpBuffR(.clk(clk), .rst_n(rst_n), .new_smpl(rht_in), .wrt_smpl(valid), .smpl_out(rd_out_low_R), .sequencing(low_seq_R));

circularBuffer1536 hpBuffL(.clk(clk), .rst_n(rst_n), .new_smpl(lft_in), .wrt_smpl(valid), .smpl_out(rd_out_high_L), .sequencing(high_seq_L));
circularBuffer1536 hpBuffR(.clk(clk), .rst_n(rst_n), .new_smpl(rht_in), .wrt_smpl(valid), .smpl_out(rd_out_high_R), .sequencing(high_seq_R));



endmodule
