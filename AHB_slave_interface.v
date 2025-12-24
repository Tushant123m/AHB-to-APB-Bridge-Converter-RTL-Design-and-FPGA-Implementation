`timescale 1ns/1ps

module AHB_slave_interface(
    input  wire        hclk,
    input  wire        hresetn,
    input  wire        hwrite,
    input  wire        hreadyin,
    input  wire [1:0]  htrans,
    output reg  [1:0]  hresp,
    input  wire [31:0] hwdata,
    input  wire [31:0] haddr,
    input  wire [31:0] prdata,

    // outputs to APB controller / bridge (names MUST match bridge_top)
    output reg         valid,
    output reg         hwritereg,
    output reg [31:0]  haddr1,
    output reg [31:0]  haddr2,
    output reg [31:0]  hwdata1,
    output reg [31:0]  hwdata2,
    output reg [2:0]   tempselx,
    output reg [31:0]  hrdata
);

    // Simple, synthesizable stub that drives all outputs.
    // Use this as a working interface until you replace with full logic.

    always @(posedge hclk) begin
        if (!hresetn) begin
            valid     <= 1'b0;
            hwritereg <= 1'b0;
            haddr1    <= 32'b0;
            haddr2    <= 32'b0;
            hwdata1   <= 32'b0;
            hwdata2   <= 32'b0;
            tempselx  <= 3'b000;
            hrdata    <= 32'b0;
            hresp     <= 2'b00;
        end else begin
            // default: keep outputs stable
            valid     <= 1'b0;
            hwritereg <= hwrite;
            hresp     <= 2'b00;
            hrdata    <= prdata; // pass-through example

            // If bus indicates a transfer (NONSEQ/SEQ) and master is ready, latch
            if (hreadyin && (htrans == 2'd2 || htrans == 2'd3)) begin
                valid     <= 1'b1;
                hwritereg <= hwrite;
                haddr1    <= haddr;
                hwdata1   <= hwdata;
                // optional alternate bank write to show haddr2/hwdata2 usage
                haddr2    <= haddr + 32'd4;
                hwdata2   <= hwdata ^ 32'hA5A5A5A5;
                tempselx  <= haddr[4:2]; // simple example decode
                hrdata    <= prdata;
                hresp     <= 2'b00;
            end
        end
    end

endmodule
