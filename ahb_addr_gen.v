module ahb_addr_gen(
    input hclk,
	input start,
    input hresetn,
    input [2:0] state,
    input [31:0] base_addr,
    input hready,
    input [2:0] hburst,
    input [2:0] hsize,
  //  input start,
    input burst_done,
    output wire [31:0] haddr
);
    
   localparam NONSEQ = 3'b001;
   localparam SEQ    = 3'b010;
    // Number of bytes to jump for a burst depending on size 
    wire [31:0] num_bytes = (32'h1 << hsize);
    reg transfer;//indicates the transfer 
    reg [4:0] burst_length; // Increased to 5 bits to safely hold '16'
    reg       wrap;
    reg [31:0]current_addr;
    reg [31:0] next_addr;

always @(posedge hclk or negedge hresetn)begin
    if(!hresetn)
        current_addr = 0;

    else if(state == NONSEQ && hready)
        current_addr = base_addr;

    else if(state == SEQ && hready)
        current_addr = next_addr;
end
    always @(*) begin
        // Default assignments to prevent hardware latches
        wrap         = 1'b0;
        burst_length = 5'd1;
        
        case (hburst)
            3'b000: burst_length = 5'd1;  // SINGLE
            3'b001: burst_length = 5'd1;  // INCR (Undefined length, increments beat-by-beat)
            3'b010: begin                 // WRAP4
                burst_length = 5'd4;
                wrap         = 1'b1;
            end
            3'b011: burst_length = 5'd4;  // INCR4
            
            3'b100: begin                 // WRAP8
                burst_length = 5'd8;
                wrap         = 1'b1;
            end
            3'b101: burst_length = 5'd8;  // INCR8
            
            3'b110: begin                 // WRAP16
                burst_length = 5'd16;
                wrap         = 1'b1;
            end
            3'b111: burst_length = 5'd16; // INCR16
            
            default: begin
                burst_length = 5'd1;
                wrap         = 1'b0;
            end
        endcase
    end

    // Mask calculation block
    wire [31:0] wrap_size  = num_bytes * burst_length;
    wire [31:0] wrap_bound = wrap_size - 32'd1;

    // Next address generation logic
    always @(*) begin
       if(start)begin
	   		transfer=1'b1;	   		
	   end
       else if(burst_done)begin
            next_addr=0;
			transfer=0;
	
			
       end
       else if (wrap && !burst_done&&transfer) begin
            // Your bitmask formula (Perfect!)
            next_addr = (current_addr & ~wrap_bound) | ((current_addr + num_bytes) & wrap_bound);
        end else begin
            // Pure linear increment
            if(!burst_done&&transfer)begin
                next_addr = current_addr + num_bytes;
            end
        end
      end
    //end
assign haddr=current_addr;
endmodule


