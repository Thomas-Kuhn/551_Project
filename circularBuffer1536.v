module circularBuffer1536(clk, rst_n, new_smpl, wrt_smpl, smpl_out, sequencing);

input 	clk, rst_n, wrt_smpl;
input 	[15:0] new_smpl;
output  [15:0] smpl_out;
output reg sequencing;

reg [10:0] samples_in; //counts nuber of samples currently in the buffer
reg [10:0] full_counter; //count how full the buffer is to determine if data should be writtn out
reg [9:0] system_counter; //counter used to slow system clock
reg [10:0] wrtPointer, rdPointer; //pointers to spaces in memory
reg enable_write; //tells buffer when it should write data to memory
reg wrt_initiated; //says that data has been written to buffer
reg need_wrt;

dualPort1536x16 buffer(.clk(clk),.we(enable_write),.waddr(wrtPointer),.raddr(rdPointer),.wdata(new_smpl),.rdata(smpl_out));

//controls buffer read and write
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		enable_write <= 1'b0;
		sequencing <= 1'b0;
     
		full_counter <= 11'h000;
		wrtPointer <= 11'h000;
		rdPointer <= 11'h000;
		need_wrt <= 0;
   	end 
	else if (system_counter == 10'b1111111111) begin
		need_wrt <= need_wrt || wrt_smpl;
		if (need_wrt) begin //write new sample to the buffer when wrt_smpl is high
        
         		wrt_initiated <= 1'b1;
         		enable_write <= 1'b1;
         		wrtPointer <= wrtPointer + 1'b1;
         		if (wrtPointer == 11'h600) 
				wrtPointer <= 11'h000; //prevents pointer overflowing bounds of buffer
         
         		if (full_counter < 11'h5FC)
				full_counter <= full_counter + 1'b1;
		end 
		else 
			enable_write <= 1'b0;
   
		if (wrt_initiated) begin      
			//read out data if there has been a write signaled and the buffer is full
			if (full_counter > 11'h5FA ) begin
				if ( samples_in > 11'h000) begin
					rdPointer <= rdPointer + 1'b1;
					if (rdPointer == 11'h600) 
						rdPointer <= 11'h000; //prevents pointer overflowing bounds of buffer
					sequencing <= 1'b1;
               
            			end 
				else 	sequencing <= 1'b0;
         		end
         		if (samples_in == 11'h000) begin //buffer no longer full when 1531 spots have been read out
            			full_counter <= 10'h000;
            			wrt_initiated <= 1'b0;
         		end
			if (rdPointer == wrtPointer)	$strobe("RD: %h\nWR: %h\n\nFull: %h\nIn : %h\n", rdPointer, wrtPointer, full_counter, samples_in);
      		end
	end
end

//system clock counter
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		system_counter <= 11'h000;
		samples_in <= 0;
	end
	else begin
		system_counter <= system_counter + 1'b1;
      		if (need_wrt) begin
			if (!wrt_initiated) samples_in <= samples_in + 1;
		end
	end
end

endmodule
