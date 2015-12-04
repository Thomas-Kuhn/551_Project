module sqrt(mag, go , clk, rst_n,sqrt,done);

//Declare necessary variables
input [15:0]mag;
input go, clk, rst_n;

output [7:0]sqrt;
output done;

//Declare necessary registers
wire[15:0] product, nxt_sqrt;
reg[7:0]cnt_mask, sqrt;
reg done;
wire iteq;
reg init;

//Used for a state machine
localparam IDLE = 2'b00;
localparam COMPUTE = 2'b01;
localparam DONE = 2'b10;

reg[1:0] state, nxt_state;

//Update the state with each clk cycle
always@(posedge clk)begin
	if(!rst_n)
		state <=  IDLE;
	else
		state <= nxt_state;
end

assign product = sqrt*sqrt;
assign iteq = (product>mag) ? 1'b0 : 1'b1;
assign nxt_sqrt = (iteq) ? (sqrt | cnt_mask) : (sqrt & ~cnt_mask) + (cnt_mask[7:1]);

//Update the one hot after every cycle
always @(posedge clk)begin
	if(init)
		cnt_mask <= 8'h80;
	else
		cnt_mask <= cnt_mask >> 1;
end

//Check the last bit of our one hot to see if all bits have been checked
always @(posedge clk)begin
	if(cnt_mask[0])
		done <= 1;
	else
		done <= 0;
end

//Update the square root with the clock
always @(posedge clk)begin
	if(init)
		sqrt <= 8'h80; //Start with the highest first bit
	else if (product != mag)
		sqrt <= nxt_sqrt; //Update sqrt
end

//state logic
always @(*)begin
	init= 0;
	nxt_state = IDLE;
	case(state)
			IDLE: begin
				if(go && !done) begin
					init = 1;
					nxt_state = COMPUTE;
				end
				else nxt_state = IDLE;
				
			end
			COMPUTE: begin
				if(!done) begin
					init = 0;
					nxt_state = COMPUTE;
				end
				else
					
					nxt_state = DONE;
			end
			DONE: begin
				nxt_state = IDLE;
			end
					

	endcase
	end//end state logic always block

endmodule

