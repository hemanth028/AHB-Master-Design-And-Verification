class ahb_gen;

    ahb_tx tx,tx_t;
    integer i;
    function new();
    endfunction
    
    task run();
        repeat(ahb_common::count) begin
            tx = new();
      	    if(!tx.randomize() with {tx.start == 1'b1; tx.hgrant == 1'b1; tx.hready == 1'b1;tx.hsize==3'b010;tx.hresp==2'b00;}) begin
               $display("RANDOMIZATION FAILED !!!!!!!!");
           end
           
           tx_t = new();
           tx_t.copy(tx);
       //    gen2bfm.put(tx);
	   	$display("HBURST=%b TOTAL_BEATS=%0d",tx_t.hburst,tx_t.total_beats);
	   	tx.print("GEN");

            for(i = 0; i < tx_t.total_beats; i = i + 1) begin
        		if(i != 0) begin    
                    tx = new();
                    if(!tx.randomize() with {
                        tx.start    == 1'b0; 
                        tx.hgrant   == 1'b1; 
                        tx.hready   == 1'b1; 
                        tx.hburst   == tx_t.hburst; 
                      //tx.haddr_in == tx_t.haddr_in; 
					   tx.base_addr== tx_t.base_addr;
					   tx.hwrite_in   == tx_t.hwrite_in;
					   tx.hresp    ==2'b00;
					   tx.hsize ==tx_t.hsize;
                    }) begin
                        $display("RANDOMIZATION (2) FAILED !!!!!!");
                    end
					
                    gen2bfm.put(tx);
					tx.print("GEN");
                end
				else begin
					gen2bfm.put(tx);
				end
		//		else begin
		//			if(!tx.randomize() with {tx.start == 1'b1; tx.hgrant == 1'b1; tx.hready == 1'b1;tx.hsize==3'b010;tx.hresp==2'b00;}) begin
        //        		$display("RANDOMIZATION FAILED !!!!!!!!");
        //    end
        //   			 tx_t = new();
        //   			 tx_t.copy(tx);
        //    	 	gen2bfm.put(tx);
		//		 	tx.print("GEN");
		//		end
            end
        end
        $display("INSIDE THE GENERATOR");
    endtask

endclass
