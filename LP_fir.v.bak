module LP_fir(clk, sequencing, rht_in, lft_in, filtered_L, filtered_R);



input clk, sequencing;
input signed [15:0] rht_in, lft_in;
output [15:0] filtered_L, filtered_R;

reg [9:0] addr;//the adress that we are at for reading from our ROM
wire signed [15:0] coef;//the coefficient that we pull out of the ROM
reg signed [32:0] ans_L, ans_R;//the answers that we get from our left and right inputs
reg state, next_state;//variables for state machines


//intantiate the ROM
ROM_LP lp(.clk(clk), .addr(addr), .dout(coef));

//the answers that we are outputting
assign filtered_L = ans_L[30:15];
assign filtered_R = ans_R[30:15];


//main logic
always @ (posedge clk) begin

   //if we are at the idle state
   if (state == 0) begin 
       
      //reset our variables
      addr <= 0;
      ans_L <= 0;
      ans_R <= 0;

   //if we are at our computation state
   end else begin
      //make new calculations and increment our address
      ans_L <= ans_L + coef * lft_in;
      ans_R <= ans_R + coef * rht_in;
      addr = (addr + 1) % 10'h3fd;
   end

   

end


//the state logic is entirely dependant on sequencing, but using the always @(*) is good practice
always @(*) begin

   next_state = 0;

   if (sequencing) begin
      next_state = 1;
   end 

end


//always go to the next state on the positive edge
always @(posedge clk) begin
   state <= next_state;
end




endmodule
