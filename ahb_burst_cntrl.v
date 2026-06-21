    module ahb_burst_ctrl(
        input wire hclk,
        input wire hresetn,
        input wire start,
        input wire hready,
        input wire [2:0] hburst,
        input wire [2:0] fsm_state,
        input wire [2:0] next, 
        output reg burst_done
    );
    
    localparam NONSEQ = 3'b001;
    localparam SEQ    = 3'b010;
    
    reg [4:0] beat_count;
    reg [4:0] total_beat;
    
    always @(*) begin
        case(hburst)
            3'b000: total_beat = 5'd1;
            3'b010,
            3'b011: total_beat = 5'd4;
            3'b100,
            3'b101: total_beat = 5'd8;
            3'b110,
            3'b111: total_beat = 5'd16;
            default: total_beat = 5'd1;
        endcase
    end
    always @(posedge hclk or negedge hresetn)
    begin
        if(!hresetn)
            beat_count <= 0;
    
        //else if(start)
          //  beat_count <= 0;
    
        else if(burst_done)
            beat_count <= 0;
    
        else if(hready && next == NONSEQ)
            beat_count <= 1;
    
        else if(hready && (fsm_state == SEQ||fsm_state== NONSEQ)&&(!burst_done))
            beat_count <= beat_count + 1;
    end
        always @(posedge hclk) begin
       		 burst_done <= 1'b0;
    
        if((fsm_state == NONSEQ || fsm_state == SEQ) &&(beat_count == total_beat))begin
            burst_done <= 1'b1;
        end
    end
    
    endmodule

