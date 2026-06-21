class ahb_tx;
	rand bit [31:0] wr_data_q[$];// for reducing the write input delay 
    rand bit        start;
    rand bit        hwrite_in;
    rand bit        hready;
    rand bit        hgrant;

    rand bit [2:0]  hburst;
    rand bit [2:0]  hsize;

    rand bit [1:0]  hresp;

    rand bit [31:0] base_addr;
    rand bit [31:0] wr_data;
    rand bit [31:0] hrdata;

    bit [31:0] haddr;
    bit [31:0] hwdata;
    bit [31:0] rd_data;

    bit        hwrite;
    bit [1:0]  htrans;

    bit [2:0]  hburst_out;
    bit        burst_done;

   // bit [2:0]  hsize_out;

    int total_beats;

    constraint c_addr_aligned {
        base_addr[1:0] == 2'b00;
    }

    constraint burst {
        hburst inside {
            3'b010, // WRAP4
            3'b011, // INCR4
            3'b100, // WRAP8
            3'b101, // INCR8
            3'b110, // WRAP16
            3'b111  // INCR16
        };
    }

    function void post_randomize();

        case(hburst)
            3'b000 : total_beats = 1;
            3'b010 : total_beats = 4;
            3'b011 : total_beats = 4;
            3'b100 : total_beats = 8;
            3'b101 : total_beats = 8;
            3'b110 : total_beats = 16;
            3'b111 : total_beats = 16;
            default: total_beats = 1;
        endcase

    endfunction

    function void print(string name="ahb_tx");

        $display("========================================");
        $display("Component = %s",name);
        $display("----------------------------------------");

        $display("INPUTS");
        $display("start      = %0b",start);
        $display("hwrite_in  = %0b",hwrite_in);
        $display("hburst     = %03b",hburst);
        $display("hsize      = %03b",hsize);
        $display("base_addr  = %08h",base_addr);
        $display("wr_data    = %08h",wr_data);
        $display("hrdata     = %08h",hrdata);
        $display("hready     = %0b",hready);
        $display("hgrant     = %0b",hgrant);
        $display("hresp      = %02b",hresp);

        $display("----------------------------------------");

        $display("OUTPUTS");
        $display("haddr      = %08h",haddr);
        $display("hwdata     = %08h",hwdata);
        $display("hwrite     = %0b",hwrite);
        $display("htrans     = %02b",htrans);
        $display("hburst_out = %03b",hburst_out);
       // $display("hsize_out  = %03b",hsize_out);
        $display("burst_done = %0b",burst_done);
        $display("read out   = %08h",rd_data);
        $display("total_beats= %0d",total_beats);

        $display("========================================");

    endfunction

    function void copy(ahb_tx tx);

        start      = tx.start;
        hwrite_in  = tx.hwrite_in;
        hready     = tx.hready;
        hgrant     = tx.hgrant;

        hburst     = tx.hburst;
        hsize      = tx.hsize;
        hresp      = tx.hresp;

        base_addr  = tx.base_addr;
        wr_data    = tx.wr_data;
        hrdata     = tx.hrdata;

        haddr      = tx.haddr;
        hwdata     = tx.hwdata;
        rd_data    = tx.rd_data;

        hwrite     = tx.hwrite;
        htrans     = tx.htrans;

        hburst_out = tx.hburst_out;
      //hsize_out  = tx.hsize_out;

        burst_done = tx.burst_done;

        total_beats = tx.total_beats;

    endfunction

endclass
