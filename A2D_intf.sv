module A2D_intf(clk, rst_n, strt_cnv, cnv_cmplt, chnnl, res, a2d_SS_n, SCLK, MOSI, MISO);

output [11:0]res;
output a2d_SS_n, SCLK, MOSI;
output reg cnv_cmplt;
input [2:0]chnnl;
input clk, rst_n, strt_cnv, MISO;
wire [15:0]cmd;
wire done;
reg [1:0]state, nextState;

logic wrt;

localparam IDLE = 2'b00;
localparam FIRSTSPI = 2'b01;
localparam WAIT = 2'b11;
localparam DONE = 2'b10;

assign cmd = {2'b00,chnnl,11'h000};

SPI_mstr(.clk(clk), .rst_n(rst_n), .SS_n(a2d_SS_N), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI), .wrt(wrt), .done(done), .rd_data(res), .cmd(cmd));

//set state register
always@(posedge clk, negedge rst_n) begin
    if(!rst_n) state <= IDLE;
    else state <= nextState;
end

always_comb begin
    nextState = IDLE;
    cnv_cmplt = 1'b0;
    wrt = 1'b0;
    case(state) 
        IDLE: if(strt_cnv) begin
                  wrt = 1'b1;
                  
                  nextState = FIRSTSPI;
              end
        FIRSTSPI: if(done) begin
                     nextState = WAIT;
                 end else nextState = FIRSTSPI;
        WAIT: nextState = DONE;
        default: if(done) begin   //is DONE
                     wrt = 1'b1;
                     cnv_cmplt = 1'b1;
                 end
                     
    endcase
end

endmodule
