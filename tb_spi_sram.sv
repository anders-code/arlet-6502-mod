`resetall
`timescale 1ns / 1ps
`default_nettype none

module tb_spi_sram();

// insure clock starts without posedge @ time 0 to avoid race conditions
// first posedge will be @PERIOD ns
logic clki;
always begin
    #5 clki = 0;
    #5 clki = 1;
end

wire clk;
assign #1 clk = clki;

logic rst;

logic en;
logic cs_n;
wire mosi = mosi_data[63];
logic miso;



spi_sram spi_sram_inst (
   .clk,
   .clk2 (~clk),
   .rst,
   .en,
   .en2 (en),
   .cs_n,
   .mosi,
   .miso
);

logic miso_shift = 0;

initial begin
    #17 rst  = 1;
        en   = 1;
        cs_n = 1;
        spi_sram_inst.mem['h407] = 'h77;
        spi_sram_inst.mem['h408] = 'h88;
        spi_sram_inst.mem['h409] = 'h99;
        spi_sram_inst.mem['h40a] = 'haa;
        spi_sram_inst.mem['h40b] = 'hbb;
        spi_sram_inst.mem['h40c] = 'hcc;

   #100 rst = 0;

   #100 mosi_data = { 8'h83, 24'h800409, 32'b0 };
        cs_n = 0;
   #320 miso_shift = 1;
   #160 cs_n = 1;
   
   #100 mosi_data = { 8'h82, 24'h800405, 32'h11223344 };
        cs_n = 0;
   #640 cs_n = 1;
   
   #100 mosi_data = { 8'h83, 24'h800405, 32'b0 };
        cs_n = 0;
   #640 cs_n = 1;
        
end

reg [63:0]mosi_data;
always @(negedge clk) begin
    if (!cs_n)
        mosi_data <= { mosi_data, 1'b0 };
end

reg [31:0]miso_data = 0;
always @(posedge clk) begin
    if (!cs_n && miso_shift)
        miso_data <= { miso_data, miso };
end

endmodule
`resetall
