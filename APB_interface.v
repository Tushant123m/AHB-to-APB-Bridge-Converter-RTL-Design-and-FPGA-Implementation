`timescale 1ns/1ps

module APB_interface
(input pwrite, penable,
                     input [2:0]pselx,
                     input [31:0]paddr,pwdata,
                     output pwrite_out,penable_out,
                     output [2:0]psel_out,
                     output [31:0]paddr_out,pwdata_out,
                     output reg [31:0]prdata);

    assign pwrite_out=pwrite;
    assign psel_out=pselx;
    assign paddr_out=paddr;
    assign pwdata_out=pwdata;
    assign penable_out=penable;


    always@(*)
        begin
            if(!pwrite && !penable)
                begin
                    prdata=8'd25;
                end
        end
endmodule
