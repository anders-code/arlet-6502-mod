// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`resetall
`timescale 1ns/1ps
`default_nettype none

module tb_spi_functional_vl (
    input wire clk,
    input wire rst,
    input wire nmi,
    input wire irq,
    output wire rdy,
    output wire [7:0]tc
);

import tb_utils::*;

logic [15:0]ab;
logic  [7:0]dout;
logic  [7:0]din;
logic       we;

cpu_6502 cpu_inst (
  .clk,
  .reset (rst),
  .AB    (ab),
  .DI    (din),
  .DO    (dout),
  .WE    (we),
  .IRQ   (irq),
  .NMI   (nmi),
  .RDY   (rdy)
);

wire cs_n;
wire mosi;
wire miso;

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
    .mem_addr  ({ 8'b0, ab }),
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
    .en   (1),
    .en2  (1),
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
//reg [7:0]mem_rdata;
always_ff @(posedge clk) begin
    if (mem_en) begin
        if (mem_wr)
            mem[mem_addr[15:0]] <= mem_wdata;
        mem_rdata <= mem[mem_addr[15:0]];
    end
end

assign tc = mem['h0200];

initial begin
    $readmemh(tb_rel_path("../mem-files/6502_functional_test.mem"), mem, 0, $size(mem)-1);
    mem['hfffc +: 2] = '{ 8'h00, 8'h04 };
end
endmodule
`resetall
