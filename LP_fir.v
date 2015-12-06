module LP_fir(clk, sequencing, rht_in, lft_in, filtered_L, filtered_R);

input clk, sequencing;
input signed [15:0] rht_in, lft_in;
output [15:0] filtered_L, filtered_R;

reg [9:0] addr;
wire signed [15:0] coef;
reg signed [32:0] ans_L, ans_R;
reg state, next_state;

ROM_LP(.clk(clk), .addr(addr), .dout(coef));


assign filtered_L = ans_L[30:15];
assign filtered_R = ans_R[30:15];

always @ (posedge clk) begin


   if (state == 0) begin 
       
      addr <= 0;
      ans_L <= 0;
      ans_R <= 0;

   end else begin
      ans_L <= ans_L + coef * lft_in;
      ans_R <= ans_R + coef * rht_in;
      addr = (addr + 1) % 10'h3fd;
   end

   

end

always @(*) begin

   next_state = 0;

   if (sequencing) begin
      next_state = 1;
   end 

end

always @(posedge clk) begin
   state <= next_state;
end




endmodule
