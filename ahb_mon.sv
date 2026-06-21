class ahb_mon;

    ahb_tx tx;
    virtual ahb_intf vif;
    logic [31:0] prev_addr;

    function new();
        vif = top.pif;
        prev_addr = 32'hFFFFFFFF;
    endfunction

    task run();
        $display("INSIDE THE MONITOR");

        forever begin
            @(posedge vif.hclk);
            // active transfer (NONSEQ=2'b10 or SEQ=2'b11) and the bus is ready
            if ((vif.htrans == 2'b10 || vif.htrans == 2'b11) && vif.hready === 1'b1) begin
			//	$display("MON:haddr=%h prev_addr=%h htrans=%b",vif.haddr, prev_addr, vif.htrans);
                if(vif.haddr != prev_addr) begin
			//		$display("MON: htrans=%b haddr=%h time=%0t",vif.htrans, vif.haddr, $time);
                    tx = new();

                    tx.start      = vif.start;
                    tx.hburst     = vif.hburst;
                    tx.hwrite_in  = vif.hwrite_in;
                    tx.base_addr  = vif.base_addr;
                    tx.wr_data    = vif.wr_data;
                    tx.hready     = vif.hready;
                    tx.hgrant     = vif.hgrant;
                    tx.hresp      = vif.hresp;
                    tx.rd_data    = vif.rd_data;
                  //  tx.rd_valid   = vif.rd_valid;
                    tx.haddr      = vif.haddr;
                    tx.htrans     = vif.htrans;
                    //tx.hbusreq    = vif.hbusreq;
                    tx.hwdata     = vif.hwdata;
                    tx.hburst_out = vif.hburst_out;
                    tx.burst_done = vif.burst_done;
				//	tx.hwrite	  =vif.hwrite;
                    prev_addr = vif.haddr;
                   // tx.print("MONITOR_CAPTURE");
                    mon2sbd.put(tx);

                    tx.print("MON");

                end

            end

        end
    endtask

endclass
