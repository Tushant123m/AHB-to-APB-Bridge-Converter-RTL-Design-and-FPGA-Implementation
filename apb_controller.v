`timescale 1ns/1ps

module apb_controller(
    input valid,
    input hwritereg,
    input hclk,
    input hresetn,
    input hwrite,
    input [31:0] haddr1,
    input [31:0] haddr2,
    input [31:0] hwdata1,
    input [31:0] hwdata2,
    input [31:0] haddr,
    input [31:0] hwdata,
    input [2:0] tempselx,
    output reg pwrite,
    output reg penable,
    output reg [2:0] pselx,
    output reg hreadyout,
    output reg [31:0] pwdata,
    output reg [31:0] paddr
);

    parameter st_idle     = 3'b000,
              st_wait     = 3'b001,
              st_write    = 3'b010,
              st_writep   = 3'b011,
              st_wenablep = 3'b100,
              st_wenable  = 3'b101,
              st_read     = 3'b110,
              st_renable  = 3'b111;

    reg [2:0] state, next_state;

    // temporary storage — ensures outputs are driven
    reg [31:0] paddr_temp, pwdata_temp;
    reg penable_temp, pwrite_temp, hreadyout_temp;
    reg [2:0]  pselx_temp;

    // state register
    always @(posedge hclk) begin
        if (!hresetn) begin
            state <= st_idle;
        end else begin
            state <= next_state;
        end
    end

    // next-state combinational
    always @(*) begin
        case (state)
            st_idle: begin
                if (valid && hwrite) next_state = st_wait;
                else if (valid && ~hwrite) next_state = st_read;
                else next_state = st_idle;
            end

            st_wait: begin
                if (valid) next_state = st_writep;
                else next_state = st_write;
            end

            st_writep: next_state = st_wenablep;

            st_write: begin
                if (valid) next_state = st_wenablep;
                else next_state = st_wenable;
            end

            st_wenablep: begin
                if (valid && hwritereg) next_state = st_writep;
                else if (~hwritereg) next_state = st_read;
                else if (~valid) next_state = st_write;
                else next_state = st_wenablep;
            end

            st_wenable: begin
                if (valid && ~hwrite) next_state = st_read;
                else if (~valid) next_state = st_idle;
                else next_state = st_wenable;
            end

            st_read: next_state = st_renable;

            st_renable: begin
                if (valid && ~hwrite) next_state = st_read;
                else if (valid && hwrite) next_state = st_wait;
                else if (~valid) next_state = st_idle;
                else next_state = st_renable;
            end

            default: next_state = st_idle;
        endcase
    end

    // Simple sequential driver to ensure outputs are driven
    // Replace with your APB transfer logic later
    always @(posedge hclk) begin
        if (!hresetn) begin
            pwrite        <= 1'b0;
            penable       <= 1'b0;
            pselx         <= 3'b000;
            hreadyout     <= 1'b1;
            pwdata        <= 32'b0;
            paddr         <= 32'b0;
            paddr_temp    <= 32'b0;
            pwdata_temp   <= 32'b0;
            penable_temp  <= 1'b0;
            pwrite_temp   <= 1'b0;
            hreadyout_temp<= 1'b1;
            pselx_temp    <= 3'b000;
        end else begin
            // default pass-through of temps
            pwrite    <= pwrite_temp;
            penable   <= penable_temp;
            pselx     <= pselx_temp;
            hreadyout <= hreadyout_temp;
            pwdata    <= pwdata_temp;
            paddr     <= paddr_temp;

            // placeholder example behavior
            if (state == st_writep) begin
                pwrite_temp  <= 1'b1;
                paddr_temp   <= haddr;
                pwdata_temp  <= hwdata;
                penable_temp <= 1'b0;
                pselx_temp   <= tempselx;
                hreadyout_temp <= 1'b0;
            end else if (state == st_wenablep) begin
                penable_temp <= 1'b1;
                hreadyout_temp <= 1'b0;
            end else begin
                pwrite_temp <= 1'b0;
                penable_temp <= 1'b0;
                pselx_temp <= 3'b000;
                hreadyout_temp <= 1'b1;
            end
        end
    end

endmodule
