module dig_core_intf(clk, rst_n, lft_in, rht_in, lft_out, rht_out, valid, POT_B1, POT_B2, POT_B3, POT_HP, POT_LP, POT_VOL, AMP_ON);

input clk, rst_n, valid;
input signed [15:0]lft_in, rht_in;
input[11:0]POT_B1, POT_B2, POT_B3, POT_HP, POT_LP, POT_VOL;
output signed [15:0]lft_out, rht_out;
output reg AMP_ON;

reg [23:0] POT_B1sq, POT_B2sq, POT_B3sq, POT_LPsq, POT_HPsq;
wire signed [15:0]rd_out_low_L, rd_out_low_R, rd_out_high_L, rd_out_high_R;
wire low_seq_L, low_seq_R, high_seq_L, high_seq_R;
wire signed [15:0]filtered_lp_L, filtered_lp_R,  filtered_b1_L, filtered_b1_R, filtered_b2_L, filtered_b2_R, filtered_b3_L, filtered_b3_R,  filtered_hp_L, filtered_hp_R;
wire signed [15:0]pot_filtered_lp_L, pot_filtered_lp_R,  pot_filtered_b1_L, pot_filtered_b1_R, pot_filtered_b2_L, pot_filtered_b2_R, pot_filtered_b3_L, pot_filtered_b3_R,  pot_filtered_hp_L, pot_filtered_hp_R;
wire signed [15:0] summed_audio_L, summed_audio_R;
wire signed [12:0] POT_VOLin;

assign POT_VOLin = {1'b0,POT_VOL};
circularBuffer1024 lpBuffL(.clk(clk), .rst_n(rst_n), .new_smpl(lft_in), .wrt_smpl(valid), .smpl_out(rd_out_low_L), .sequencing(low_seq_L));
circularBuffer1024 lpBuffR(.clk(clk), .rst_n(rst_n), .new_smpl(rht_in), .wrt_smpl(valid), .smpl_out(rd_out_low_R), .sequencing(low_seq_R));

circularBuffer1536 hpBuffL(.clk(clk), .rst_n(rst_n), .new_smpl(lft_in), .wrt_smpl(valid), .smpl_out(rd_out_high_L), .sequencing(high_seq_L));
circularBuffer1536 hpBuffR(.clk(clk), .rst_n(rst_n), .new_smpl(rht_in), .wrt_smpl(valid), .smpl_out(rd_out_high_R), .sequencing(high_seq_R));

LP_fir lp(.clk(clk), .sequencing(low_seq_L), .rht_in(rd_out_low_R), .lft_in(rd_out_low_L), .filtered_L(filtered_lp_L), .filtered_R(filtered_lp_R));
B1_fir b1(.clk(clk), .sequencing(low_seq_L), .rht_in(rd_out_low_R), .lft_in(rd_out_low_L), .filtered_L(filtered_b1_L), .filtered_R(filtered_b1_R));
B2_fir b2(.clk(clk), .sequencing(low_seq_L), .rht_in(rd_out_low_R), .lft_in(rd_out_low_L), .filtered_L(filtered_b2_L), .filtered_R(filtered_b2_R));
B3_fir b3(.clk(clk), .sequencing(high_seq_L), .rht_in(rd_out_high_R), .lft_in(rd_out_high_L), .filtered_L(filtered_b3_L), .filtered_R(filtered_b3_R));
HP_fir hp(.clk(clk), .sequencing(high_seq_L), .rht_in(rd_out_high_R), .lft_in(rd_out_high_L), .filtered_L(filtered_hp_L), .filtered_R(filtered_hp_R));
assign POT_B1sq = POT_B1 * POT_B1;
assign POT_B2sq = POT_B2 * POT_B2;
assign POT_B3sq = POT_B3 * POT_B3;
assign POT_HPsq = POT_HP * POT_HP;
assign POT_LPsq = POT_LP * POT_LP;

band_scale lp_L(.POT(POT_LPsq), .audio(filtered_lp_L), .scaled(pot_filtered_lp_L));
band_scale lp_R(.POT(POT_LPsq), .audio(filtered_lp_R), .scaled(pot_filtered_lp_R));
band_scale b1_L(.POT(POT_B1sq), .audio(filtered_b1_L), .scaled(pot_filtered_b1_L));
band_scale b1_R(.POT(POT_B1sq), .audio(filtered_b1_R), .scaled(pot_filtered_b1_R));
band_scale b2_L(.POT(POT_B2sq), .audio(filtered_b2_L), .scaled(pot_filtered_b2_L));
band_scale b2_R(.POT(POT_B2sq), .audio(filtered_b2_R), .scaled(pot_filtered_b2_R));
band_scale b3_L(.POT(POT_B3sq), .audio(filtered_b3_L), .scaled(pot_filtered_b3_L));
band_scale b3_R(.POT(POT_B3sq), .audio(filtered_b3_R), .scaled(pot_filtered_b3_R));
band_scale hp_L(.POT(POT_HPsq), .audio(filtered_hp_L), .scaled(pot_filtered_hp_L));
band_scale hp_R(.POT(POT_HPsq), .audio(filtered_hp_R), .scaled(pot_filtered_hp_R));


assign summed_audio_L = pot_filtered_lp_L + pot_filtered_b1_L + pot_filtered_b2_L + pot_filtered_b3_L + pot_filtered_hp_L;
assign summed_audio_R = pot_filtered_lp_R + pot_filtered_b1_R + pot_filtered_b2_R + pot_filtered_b3_R + pot_filtered_hp_R;

//Don't need to pass volume to band scale
//band_scale vol_L(.POT(POT_VOLin), .audio(summed_audio_L), .scaled(lft_out));
//band_scale vol_R(.POT(POT_VOLin), .audio(summed_audio_R), .scaled(rht_out));
assign rht_out = summed_audio_R * POT_VOLin;
assign lft_out = summed_audio_L * POT_VOLin;

assign AMP_ON = low_seq_L || low_seq_R || high_seq_L || high_seq_R;

endmodule
