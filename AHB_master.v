`timescale 1ns/1ps


module AHB_Master(
    input hclk,
    input hresetn,
    input hreadyout,
    input [31:0] hrdata,
    output reg [31:0] haddr,
    output reg [31:0] hwdata,
    output reg hwrite,
    output reg hreadyin,
    output reg [1:0] htrans
);

    reg [2:0] hburst;  // burst type: single, 4, 8, 16
    reg [2:0] hsize;   // transfer size: 8, 16, 32 bits

    integer i;

    // single write task
// single write task (fixed)
	task single_write();
		 begin
			  // Address phase + write data together
			  @(posedge hclk);
			  #1;
			  begin
					hwrite   = 1;                 // write operation
					htrans   = 2'd2;              // NONSEQ transfer
					hsize    = 0;                 // transfer size
					hburst   = 0;                 // single transfer
					hreadyin = 1;                 // ready for transfer
					haddr    = 32'h8000_0001;     // target address
					hwdata   = 32'h00000080;      // write data (32-bit)
			  end

			  // Next clock: return to IDLE
			  @(posedge hclk);
			  #1;
			  begin
					hwrite   = 0;
					htrans   = 2'd0;              // IDLE
					haddr    = 32'b0;
					hwdata   = 32'b0;
					hreadyin = 1;
			  end
		 end
	endtask


    // single read task
    task single_read();
        begin
            @(posedge hclk);
            begin
                hwrite = 0;
                htrans = 2'd2;
                hsize = 0;
                hburst = 0;
                hreadyin = 1;
                haddr = 32'h8000_0001;
            end
            @(posedge hclk);
            #1;
            begin
                htrans = 2'd0;
            end
        end
    endtask

    // burst write task
    task burst_write();
        begin
            @(posedge hclk);
            #1;
            begin
                hwrite = 1'b1;
                htrans = 2'd2;
                hsize = 0;
                hburst = 3'd3;
                hreadyin = 1;
                haddr = 32'h8000_0001;
            end

            @(posedge hclk);
            #1;
            begin
                haddr = haddr + 1;
                hwdata = ($random) % 256;
                htrans = 2'd3;
            end

            for(i = 0; i < 2; i = i + 1) begin
                @(posedge hclk);
                #1;
                haddr = haddr + 1;
                hwdata = ($random) % 256;
                htrans = 2'd3;
            end

            @(posedge hclk);
            #1;
            begin
                hwdata = ($random) % 256;
                htrans = 2'd0;
            end
        end
    endtask

endmodule
