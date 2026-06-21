//class ahb_sbd;
//
//    ahb_tx tx;
//
//    bit [31:0] prev_wr_data;
//    bit first_write;
//
//    function new();
//        first_write = 1;
//        prev_wr_data = 0;
//    endfunction
//
//    task run();
//        forever begin
//			
//            tx = new();
//            mon2sbd.get(tx);
//			ahb_common::tran_end=tx.burst_done;
//			if(tx.hwrite_in)begin
//                if(first_write)begin
//                    first_write = 0;
//                end
//                else begin
//                    if(tx.hwdata == prev_wr_data)begin
//                        $display("[SBD] WRITE PIPELINE MATCH");
//                        $display("Expected = %h  Received = %h",prev_wr_data, tx.hwdata);
//                        ahb_common::match++;
//                    end
//                    else begin
//                        $display("[SBD] WRITE PIPELINE MISMATCH");
//                        $display("Expected = %h  Received = %h",prev_wr_data, tx.hwdata);
//                        ahb_common::mismatch++;
//                    end
//                end
//                prev_wr_data = tx.wr_data;
//            end
//        end
//    endtask
//endclass

class ahb_sbd;

    ahb_tx tx;

    bit [31:0] prev_wr_data;
    bit [31:0] prev_prev_wr_data;

    int write_count;

    function new();
        prev_wr_data      = 0;
        prev_prev_wr_data = 0;
        write_count       = 0;
    endfunction

    task run();
        forever begin

            tx = new();
            mon2sbd.get(tx);

            ahb_common::tran_end = tx.burst_done;

            if(tx.hwrite_in) begin

                write_count++;

                // Skip first two monitor samples
                if(write_count > 2) begin

                    if(tx.hwdata == prev_prev_wr_data) begin
                        $display("[SBD] WRITE PIPELINE MATCH");
                        $display("Expected = %h  Received = %h",
                                  prev_prev_wr_data, tx.hwdata);
                        ahb_common::match++;
                    end
                    else begin
                        $display("[SBD] WRITE PIPELINE MISMATCH");
                        $display("Expected = %h  Received = %h",
                                  prev_prev_wr_data, tx.hwdata);
                        ahb_common::mismatch++;
                    end

                end

                prev_prev_wr_data = prev_wr_data;
                prev_wr_data      = tx.wr_data;

            end

        end
    endtask

endclass
