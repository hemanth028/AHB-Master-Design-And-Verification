interface ahb_intf(input logic hclk,input logic hresetn);

    logic        start;
    logic        hwrite_in;
    logic        hready;
    logic        hgrant;
    logic [1:0]  hresp;
    logic [2:0]  hburst;
    logic [2:0]  hsize;
    logic [31:0] base_addr;
    logic [31:0] wr_data;
    logic [31:0] hrdata;
    logic [31:0] haddr;
    logic [31:0] hwdata;
    logic        hwrite;
    logic [1:0]  htrans;
    logic [2:0]  hburst_out;
    logic [2:0]  hsize_out;
	logic [31:0] rd_data;
	logic        burst_done;
endinterface
