`timescale 1ns / 1ps
`include "ahb_burst_cntrl.v"
`include "ahb_addr_gen.v"
`include "ahb_fsm.v"
module ahb_master_top(
    input  wire        hclk,
    input  wire        hresetn,
    input  wire        hready,
    input  wire [1:0]  hresp,
    input  wire        hgrant,
    input  wire        start,

    input  wire        hwrite_in,
    input  wire [2:0]  hburst,
    input  wire [2:0]  hsize,
    input  wire [31:0] base_addr,

    input  wire [31:0] wr_data,
    input  wire [31:0] hrdata,

    output wire [31:0] haddr,
    output wire [31:0] hwdata,
    output wire        hwrite,
    output wire [1:0]  htrans,
    output wire [2:0]  hburst_out,
    output wire [2:0]  hsize_out,
	output wire [31:0] rd_data,
	output wire burst_done
);

wire [2:0] state,next;
//wire burst_done;

assign hburst_out = hburst;
assign hsize_out  = hsize;

ahb_addr_gen u_addr_gen(
    .hclk(hclk),
	.start(start),
    .hresetn(hresetn),
    .state(state),
    .base_addr(base_addr),
    .hready(hready),
    .hburst(hburst),
    .hsize(hsize),
    .burst_done(burst_done),
    .haddr(haddr)
);

ahb_burst_ctrl u_burst_ctrl(
    .hclk(hclk),
    .hresetn(hresetn),
    .start(start),
    .hready(hready),
    .hburst(hburst),
    .fsm_state(state),
    .next(next),
    .burst_done(burst_done)
);

ahb_master_fsm u_fsm(
    .hclk(hclk),
    .hresetn(hresetn),
    //.haddr_in(haddr),
    .burst_done(burst_done),
    .hgrant(hgrant),
    .hresp(hresp),
    .hrdata(hrdata),
    .hready(hready),
    .hburst(hburst),
    .start(start),
    .hwrite_in(hwrite_in),
    .wr_data(wr_data),
    .hwrite(hwrite),
    .htrans(htrans),
    .hwdata(hwdata),
    .state(state),
    .next(next),
	.rd_data(rd_data)
);

endmodule
