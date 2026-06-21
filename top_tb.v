`timescale 1ns/1ps

module top_tb;

reg hclk;
reg hresetn;
reg hready;
reg [1:0] hresp;
reg hgrant;
reg start;
reg hwrite_in;

reg [2:0] hburst;
reg [2:0] hsize;

reg [31:0] base_addr;
reg [31:0] wr_data;
reg [31:0] hrdata;

wire [31:0] haddr;
wire [31:0] hwdata;
wire hwrite;
wire [1:0] htrans;

ahb_master_top dut(
    .hclk(hclk),
    .hresetn(hresetn),
    .hready(hready),
    .hresp(hresp),
    .hgrant(hgrant),
    .start(start),
    .hwrite_in(hwrite_in),
    .hburst(hburst),
    .hsize(hsize),
    .base_addr(base_addr),
    .wr_data(wr_data),
    .hrdata(hrdata),
    .haddr(haddr),
    .hwdata(hwdata),
    .hwrite(hwrite),
    .htrans(htrans)
);

always #5 hclk = ~hclk;

integer cycle;

always @(posedge hclk)
begin
    cycle = cycle + 1;

    $display(
    "Cycle=%0d STATE=%0d HTRANS=%b HADDR=%h HWDATA=%h WR_DATA=%h",
    cycle,
    dut.state,
    htrans,
    haddr,
    hwdata,
    wr_data
    );
end

initial
begin
    cycle = 0;

    hclk      = 0;
    hresetn   = 0;
    hready    = 1;
    hresp     = 2'b00;
    hgrant    = 1;
    start     = 0;

    hwrite_in = 1;

    hburst    = 3'b010;      // WRAP4
    hsize     = 3'b010;      // WORD

    base_addr = 32'h00000034;

    wr_data   = 32'h11111111;
    hrdata    = 32'h0;

    //---------------- RESET ----------------//
    #20;
    hresetn = 1;

    //---------------- START BURST ----------//
    @(posedge hclk);
    start = 1;

    @(posedge hclk);
    start = 0;

    //---------------- DATA -----------------//
    @(posedge hclk);
    wr_data = 32'h22222222;

    @(posedge hclk);
    wr_data = 32'h33333333;

    @(posedge hclk);
    wr_data = 32'h44444444;

    @(posedge hclk);
    wr_data = 32'h55555555;

    //---------------- END ------------------//
    #50;
    $finish;
end

endmodule
