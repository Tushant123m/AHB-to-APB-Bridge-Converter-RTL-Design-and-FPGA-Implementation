`timescale 1ns/1ps

module top_tb;

    // Clock and reset
    reg hclk;
    reg hresetn;

    // AHB signals
    wire [31:0] haddr;
    wire [31:0] hwdata;
    wire [31:0] hrdata;
    wire [1:0]  hresp;
    wire [1:0]  htrans;
    wire        hwrite;
    wire        hreadyin;
    wire        hreadyout;

    // Bridge <-> APB signals
    wire [2:0]  pselx;
    wire [31:0] paddr;
    wire [31:0] pwdata;
    wire        pwrite;
    wire        penable;

    // APB output wires
    wire [31:0] pwdata_out;
    wire [31:0] paddr_out;
    wire [2:0]  psel_out;
    wire        pwrite_out;
    wire        penable_out;
    wire [31:0] prdata;

    // Instantiate AHB master
    AHB_Master ahb (
        .hclk(hclk),
        .hresetn(hresetn),
        .hreadyout(hreadyout),
        .hrdata(hrdata),
        .haddr(haddr),
        .hwdata(hwdata),
        .hwrite(hwrite),
        .hreadyin(hreadyin),
        .htrans(htrans)
    );

    // Instantiate bridge
    bridge_top bridge (
        .hclk(hclk),
        .hresetn(hresetn),
        .hwrite(hwrite),
        .hreadyin(hreadyin),
        .hwdata(hwdata),
        .haddr(haddr),
        .prdata(prdata),
        .htrans(htrans),
        .pwrite(pwrite),
        .penable(penable),
        .hr_readyout(hr_readyout),
        .psel(pselx),
        .paddr(paddr),
        .pwdata(pwdata),
        .hrdata(hrdata),
        .hresp(hresp)
    );

    // Instantiate APB interface (acts like a peripheral)
    APB_interface apb (
        .pwrite(pwrite),
        .penable(penable),
        .pselx(pselx),
        .paddr(paddr),
        .pwdata(pwdata),

        .pwrite_out(pwrite_out),
        .penable_out(penable_out),
        .psel_out(psel_out),
        .paddr_out(paddr_out),
        .pwdata_out(pwdata_out),
        .prdata(prdata)
    );

    // Clock generation
    initial begin
        hclk = 1'b0;
        forever #10 hclk = ~hclk; // 20ns period = 50MHz
    end

    // Reset task
    task reset();
        begin
            @(negedge hclk);
            hresetn = 1'b0;
            @(negedge hclk);
            hresetn = 1'b1;
        end
    endtask

    // ==================================================
    // ?? MONITOR SECTION: Print AHB and APB transactions
    // ==================================================
    initial begin
        $display("\n==== AHB?APB BRIDGE TRANSACTION LOG ====\n");
        $monitor("T=%0t | HWRITE=%b | HADDR=%h | HWDATA=%h | HRDATA=%h | HREADY=%b | PADDR=%h | PWDATA=%h | PWRITE=%b | PENABLE=%b",
                 $time, hwrite, haddr, hwdata, hrdata, hreadyin, paddr, pwdata, pwrite, penable);
    end

    // Test stimulus
    initial begin
        // Dump VCD for waveforms
        $dumpfile("bridge_system_tb.vcd");
        $dumpvars(0, top_tb);

        // Apply reset
        reset();

        // Wait a few cycles
        repeat (5) @(posedge hclk);

        // Run AHB Master operations
        //ahb.burst_write();   // Use the existing burst_write() task
        ahb.single_write();
       // ahb.single_read();

        // Wait for some time
        repeat (50) @(posedge hclk);

        $display("\nSimulation completed at %0t\n", $time);
        $finish;
    end

endmodule

