// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`resetall
`timescale 1ns/1ps
`default_nettype none

`include "sim/utils/tb_assert.vh"

module tb_spi_nl();

import tb_utils::*;

logic clk;
logic rst;
tb_clkgen tb_clkgen_inst( .clk );

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

wire cs_n = (uio_out[0] !== 0) ? 1'b1 : 1'b0;
wire mosi = (uio_out[1] !== 0) ? 1'b1 : 1'b0;
wire miso;
assign uio_in[2] = (miso !== 0);

logic irq;
logic nmi;
assign ui_in[6] = irq;
assign ui_in[7] = nmi;

//logic [15:0]ab;
//logic  [7:0]dout;
//logic  [7:0]din;
//logic       we;
//logic       irq;
//logic       nmi;
//logic       rdy;

//cpu_6502 cpu_inst (
//  .clk,
//  .reset (rst),
//  .AB    (ab),
//  .DI    (din),
//  .DO    (dout),
//  .WE    (we),
//  .IRQ   (irq),
//  .NMI   (nmi),
//  .RDY   (rdy)
//);

//wire cs_n;
//wire miso;
//wire mosi;

//spi_sram_master spi_sram_master_inst (
//    .clk,
//    .clk2 (~clk),
//    .rst,
//    .en    (1),
//    .en2   (1),
//    .ready (rdy),
//    .cs_n,
//    .miso,
//    .mosi,
//    .mem_addr  (ab),
//    .mem_en    (1'b1),
//    .mem_wr    (we),
//    .mem_wdata (dout),
//    .mem_rdata (din)
//);

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

logic [7:0]tc, lasttc;
assign tc = mem['h0200];

time t1, t2;

wire [15:0]PC = { tt_6502_inst.\cpu_inst.PC[15] , tt_6502_inst.\cpu_inst.PC[14] , tt_6502_inst.\cpu_inst.PC[13] , tt_6502_inst.\cpu_inst.PC[12] ,
                  tt_6502_inst.\cpu_inst.PC[11] , tt_6502_inst.\cpu_inst.PC[10] , tt_6502_inst.\cpu_inst.PC[9]  , tt_6502_inst.\cpu_inst.PC[8] ,
                  tt_6502_inst.\cpu_inst.PC[7]  , tt_6502_inst.\cpu_inst.PC[6]  , tt_6502_inst.\cpu_inst.PC[5]  , tt_6502_inst.\cpu_inst.PC[4] ,
                  tt_6502_inst.\cpu_inst.PC[3]  , tt_6502_inst.\cpu_inst.PC[2]  , tt_6502_inst.\cpu_inst.PC[1]  , tt_6502_inst.\cpu_inst.PC[0] };

initial begin
    $readmemh(tb_rel_path("../mem-files/6502_functional_test.mem"), mem, 0, $size(mem)-1);
    mem['hfffc] = 8'h00;
    mem['hfffd] = 8'h04;

    #17 rst = 1;
   #100 rst = 0;
        irq = 0;
        nmi = 0;
//        rdy = 1;

        @(posedge clk);
        t1 = $time();
        t2 = t1;

        wait(PC == 'h3469);
        @(posedge clk);
        $display("yay! %0d", ($time-t1)/10);
        $finish(2);

//   #200 wait(cpu_inst.state == cpu_inst.DECODE && rdy);
//        @(posedge clk);
//        `tb_assert(cpu_inst.PC_temp == 'h0401);
//        tb_assert_report;
//        $finish(2);
end

always begin
    #1_000_000;
    $display("test %0d (%0d) %0d", tc, ($time-t1)/10000, ($time-t2)/10000);
end

always @* begin
    if (lasttc !== tc) begin            
        $display("test %0d (%0d) %0d", tc, ($time-t1)/10000, ($time-t2)/10000);
        lasttc = tc;
        t2 = $time;
    end
end

endmodule
`resetall
