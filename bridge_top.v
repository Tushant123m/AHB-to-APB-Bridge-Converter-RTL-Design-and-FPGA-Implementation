`timescale 1ns/1ps


module bridge_top(
    input        hclk,
    input        hresetn,
    input        hwrite,
    input        hreadyin,
    input [31:0] hwdata,
    input [31:0] haddr,
    input [31:0] prdata,
    input [1:0]  htrans,
    output       pwrite,
    output       penable,
    output       hr_readyout,
    output [2:0] psel,
    output [31:0] paddr,
    output [31:0] pwdata,
    output [31:0] hrdata,
    output [1:0]  hresp
);

    // internal nets (names must match instantiations)
    wire valid;
    wire hwrite_reg;
    wire [31:0] hwdata_1, hwdata_2, haddr_1, haddr_2;
    wire [2:0] temp_selx;

    AHB_slave_interface ahb_S (
        .hclk(hclk),
        .hresetn(hresetn),
        .hwrite(hwrite),
        .hreadyin(hreadyin),
        .htrans(htrans),
        .hresp(hresp),
        .hwdata(hwdata),
        .haddr(haddr),
        .prdata(prdata),

        .valid(valid),
        .hwritereg(hwrite_reg),
        .haddr1(haddr_1),
        .haddr2(haddr_2),
        .hwdata1(hwdata_1),
        .hwdata2(hwdata_2),
        .tempselx(temp_selx),
        .hrdata(hrdata)
    );

    apb_controller apb_c (
        .valid(valid),
        .hwritereg(hwrite_reg),
        .hclk(hclk),
        .hresetn(hresetn),
        .hwrite(hwrite),
        .haddr1(haddr_1),
        .haddr2(haddr_2),
        .hwdata1(hwdata_1),
        .hwdata2(hwdata_2),
        .haddr(haddr),
        .hwdata(hwdata),
        .tempselx(temp_selx),

        .pwrite(pwrite),
        .penable(penable),
        .pselx(psel),
        .hreadyout(hr_readyout),
        .pwdata(pwdata),
        .paddr(paddr)
    );

endmodule
