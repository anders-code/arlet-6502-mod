// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`resetall
`timescale 1ns/1ps
`default_nettype none

module tb_spi_nl_vl (
    input wire clk,
    input wire rst,
    input wire nmi,
    input wire irq,
    output wire [7:0]tc,
    output wire [15:0]PC
);

import tb_utils::*;

logic [7:0] ui_in;
wire  [7:0] uo_out;
logic [7:0] uio_in;
wire  [7:0] uio_out;
wire  [7:0] uio_oe;

tt_um_anders_tt_6502 tt_6502_inst (
    .clk,
    .rst_n (!rst),
    .ena   (1'b1),
    .ui_in,
    .uo_out,
    .uio_in,
    .uio_out,
    .uio_oe
);

wire cs_n = uio_out[0];
wire mosi = uio_out[1];
wire miso;
assign uio_in[2] = miso;

assign ui_in[6] = irq;
assign ui_in[7] = nmi;

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

assign PC = { tt_6502_inst.\cpu_inst.PC[15] , tt_6502_inst.\cpu_inst.PC[14] , tt_6502_inst.\cpu_inst.PC[13] , tt_6502_inst.\cpu_inst.PC[12] ,
              tt_6502_inst.\cpu_inst.PC[11] , tt_6502_inst.\cpu_inst.PC[10] , tt_6502_inst.\cpu_inst.PC[9]  , tt_6502_inst.\cpu_inst.PC[8] ,
              tt_6502_inst.\cpu_inst.PC[7]  , tt_6502_inst.\cpu_inst.PC[6]  , tt_6502_inst.\cpu_inst.PC[5]  , tt_6502_inst.\cpu_inst.PC[4] ,
              tt_6502_inst.\cpu_inst.PC[3]  , tt_6502_inst.\cpu_inst.PC[2]  , tt_6502_inst.\cpu_inst.PC[1]  , tt_6502_inst.\cpu_inst.PC[0] };
initial begin
    $readmemh(tb_rel_path("../mem-files/6502_functional_test.mem"), mem, 0, $size(mem)-1);
    mem['hfffc +: 2] = '{ 8'h00, 8'h04 };
end
endmodule
`resetall
