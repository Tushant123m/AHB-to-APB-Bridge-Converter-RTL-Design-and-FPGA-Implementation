`timescale 1ns/1ps

module apb_controller_tb;

    reg         hclk;
    reg         hresetn;
    reg         valid;
    reg         hwrite;
    reg         hwritereg;
    reg [31:0]  haddr;
    reg [31:0]  haddr1;
    reg [31:0]  haddr2;
    reg [31:0]  hwdata;
    reg [31:0]  hwdata1;
    reg [31:0]  hwdata2;
    reg [2:0]   tempselx;

    wire        pwrite;
    wire        penable;
    wire [2:0]  pselx;
    wire        hreadyout;
    wire [31:0] pwdata;
    wire [31:0] paddr;

    // DUT
    apb_controller dut (
        .valid(valid),
        .hwritereg(hwritereg),
        .hclk(hclk),
        .hresetn(hresetn),
        .hwrite(hwrite),
        .haddr1(haddr1),
        .haddr2(haddr2),
        .hwdata1(hwdata1),
        .hwdata2(hwdata2),
        .haddr(haddr),
        .hwdata(hwdata),
        .tempselx(tempselx),
        .pwrite(pwrite),
        .penable(penable),
        .pselx(pselx),
        .hreadyout(hreadyout),
        .pwdata(pwdata),
        .paddr(paddr)
    );

    // clock gen
    initial begin
        hclk = 0;
        forever #5 hclk = ~hclk;  // 100MHz
    end

    // stimulus
    initial begin
        $dumpfile("apb_controller_tb.vcd");
        $dumpvars(0, apb_controller_tb);

        // Reset
        hresetn = 0;
        valid = 0;
        hwrite = 0;
        hwritereg = 0;
        tempselx = 3'b000;
        haddr = 0;
        hwdata = 0;
        #20;
        hresetn = 1;

        // --- WRITE Transfer Start ---
        @(posedge hclk);
        valid  = 1;
        hwrite = 1;
        hwritereg = 1;
        haddr = 32'h80000020;
        hwdata = 32'hDEADBEEF;
        tempselx = 3'b011;
        
        @(posedge hclk); // goes to st_writep
        // expecting pwrite=1, pselx=tempselx, paddr=paddr
        
        @(posedge hclk); // goes to st_wenablep
        // expecting penable=1

        // End transfer
        @(posedge hclk);
        valid = 0;
        
        #20;
        $finish;
    end

endmodule
