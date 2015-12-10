module Equalizer_tb();
  ////////////////////////////
  // Shell of a test bench //
  //////////////////////////

reg clk,RST_n;		// 50MHz clock and asynch active low reset from push button
reg [7:0] LED;		// Active high outputs that drive LEDs
reg A2D_SS_n;		// Active low slave select to ADC
reg A2D_MOSI;		// Master Out Slave in to ADC
reg A2D_SCLK;		// SCLK on SPI interface to ADC
reg A2D_MISO;			// Master In Slave Out from ADC
reg MCLK; 		// 12.5MHz clock to CODEC
reg  SCLK;				// serial shift clock clock to CODEC
reg  LRCLK; 			// Left/Right clock to CODEC
reg  SDin;			// forms serial data in to CODEC
reg SDout;			// from CODEC SDout pin (serial data in to core)
reg AMP_ON;			// signal to turn amp on	
integer fptr;
           // master clock to the chip
reg RSTn;            // chip reset

           // serial data clock
         // left-right clock - indicates which channel is on
          // serial data output line
           // serial data input line

wire signed [15:0] aout_lft; // flopped left audio on the input line
wire signed [15:0] aout_rht; 
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  Equalizer iDUT(.clk(clk),.RST_n(RST_n),.LED(LED),.A2D_SS_n(A2D_SS_n),.A2D_MOSI(A2D_MOSI),
                 .A2D_SCLK(A2D_SCLK),.A2D_MISO(A2D_MISO),.MCLK(MCLK),.SCL(SCLK),.LRCLK(LRCLK),
				 .SDout(SDout),.SDin(SDin),.AMP_ON(AMP_ON),.RSTn(RSTn));
				 
  //////////////////////////////////////////
  // Instantiate model of CODEC (CS4271) //
  ////////////////////////////////////////
  CS4272  iModel( .MCLK(MCLK), .SCLK(SCLK), .LRCLK(LRCLK),
                .RSTn(RSTn),  .SDout(SDout), .SDin(SDin),
                .aout_lft(aout_lft), .aout_rht(aout_rht));
				
  ///////////////////////////////////////////////////////////////////////
  // Instantiate Model of A2D converter modeling slide potentiometers //
  /////////////////////////////////////////////////////////////////////
  ADC128S iA2D(.clk(clk),.rst_n(RST_n),.SS_n(A2D_SS_n),.SCLK(A2D_SCLK),
               .MISO(A2D_MISO),.MOSI(A2D_MOSI));
				
  initial begin
  fptr = $fopen("audio_out.csv", "w");
  RST_n = 0;
  clk = 0;
  #1000
  RST_n = 1;
  end
  always@(posedge clk) begin
      
      $fwrite(fptr, "%d,%d\n", aout_lft, aout_rht);
  end

  always
    #10 clk = ~clk;

endmodule
