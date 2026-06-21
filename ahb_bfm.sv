class ahb_bfm;
    ahb_tx tx;
    virtual ahb_intf vif;
	int hold=1;
    function new();
        vif = top.pif;
    endfunction

    task run();
        forever begin
            tx = new();
            gen2bfm.get(tx);
            tx_drive(tx);
        //  tx.print("BFM");
            $display("INSIDE THE BFM");
        end
    endtask
	
    task tx_drive(ahb_tx tx);

        @(posedge vif.hclk);
		
        vif.start      <= tx.start;
        vif.hwrite_in  <= tx.hwrite_in;
        vif.hgrant     <= tx.hgrant;
        vif.hready     <= tx.hready;
        vif.hresp      <= tx.hresp;

        vif.hburst     <= tx.hburst;
        vif.hsize      <= tx.hsize;
        vif.base_addr  <= tx.base_addr;

        if(tx.hwrite_in)
            vif.wr_data <= tx.wr_data;
        else
            vif.wr_data <= 32'h0;

        // capture current DUT outputs
        tx.haddr      = vif.haddr;
        tx.hwdata     = vif.hwdata;
        tx.htrans     = vif.htrans;
        tx.burst_done = vif.burst_done;
		
        if(!tx.hwrite_in)
        begin
            tx.rd_data = vif.rd_data;
        end
        else
        begin
            tx.rd_data = 32'h0;
        end
		if(hold)begin
			@(posedge vif.hclk );
			hold=0;
		end
        $display("BFM DRIVE: start=%0b addr=%h time=%0t",
                 tx.start, tx.base_addr, $time);

        tx.print("BFM");

    endtask

endclass
