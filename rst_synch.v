module rst_synch(RST_n, clk, rst_n);

output reg rst_n;
input RST_n, clk;
reg intermediate;

always@(negedge clk or negedge RST_n) begin

    if(!RST_n) intermediate <= 1'b0;
    else intermediate <= 1'b1;

end

always@(negedge clk or negedge RST_n) begin

    if(!RST_n) rst_n <= 1'b0;
    else rst_n <= intermediate;

end

endmodule
