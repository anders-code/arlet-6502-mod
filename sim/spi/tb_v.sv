`timescale 1ns/1ps
`default_nettype none

module v6502_verilator2(
    input  wire clk,
    input  wire rst,
    input  wire irq,
    input  wire nmi,
    output wire rdy,
    output wire [7:0]tc
);

wire [15:0]addr;
wire  [7:0]din;
wire  [7:0]dout;
wire       we;
//wire       rdy;
cpu cpu_inst (
    .clk,
    .reset (rst),
    .AB    (addr),
    .DI    (din),
    .DO    (dout),
    .WE    (we),
    .IRQ   (irq),
    .NMI   (nmi),
    .RDY   (rdy)
);

wire cs_n;
wire miso;
wire mosi;

spi_sram_master spi_sram_master_inst (
    .clk,
    .clk2 (~clk),
    .rst,
    .en    (1),
    .en2   (1),
    .ready (rdy),
    .cs_n,
    .miso,
    .mosi,
    .mem_addr  (addr),
    .mem_en    (1'b1),
    .mem_wr    (we),
    .mem_wdata (dout),
    .mem_rdata (din)
);

wire [23:0]mem_addr;
wire       mem_en;
wire       mem_wr;
wire  [7:0]mem_wdata;
reg   [7:0]mem_rdata;

spi_sram_slave spi_sram_slave_inst (
    .clk,
    .clk2 (~clk),
    .rst,
    .en    (1),
    .en2   (1),
    .cs_n,
    .miso,
    .mosi,
    .mem_addr  (mem_addr),
    .mem_en    (mem_en),
    .mem_wr    (mem_wr),
    .mem_wdata (mem_wdata),
    .mem_rdata (mem_rdata)
);

reg [7:0]mem[64*1024];
reg [7:0]memout2;
always_ff @(posedge clk) begin
    if (mem_en) begin
        if (mem_wr)
            mem[mem_addr[15:0]] <= mem_wdata;
        mem_rdata <= mem[mem_addr[15:0]];
    end
    memout2 <= mem[mem_addr[15:0]];
end

assign tc = mem[16'h0200];
initial begin
    string file = "";
    $value$plusargs("IMAGE_FILE=%s", file);
    $readmemh(file, mem);
end

endmodule
