// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`resetall
`timescale 1ns/1ps
`default_nettype none

`include "sim/utils/tb_assert.vh"

import tb_utils::*;

module tb_basic();

logic clk;
logic rst;
tb_clkgen tb_clkgen_inst( .clk );

logic [15:0]ab;
logic  [7:0]dout;
logic  [7:0]din;
logic       we;
logic       irq;
logic       nmi;
logic       rdy;

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

reg [7:0]mem[64*1024];
reg [7:0]memout;
always_ff @(posedge clk) begin
    if (rdy) begin
        if (we)
            mem[ab] <= dout;
        memout <= mem[ab];
    end
end
assign din = memout;

initial begin
    mem['hfffa +:2] = '{ 8'h00, 8'h06 }; // nmi
    mem['hfffc +:2] = '{ 8'h00, 8'h04 }; // reset
    mem['hfffe +:2] = '{ 8'h00, 8'h05 }; // irq

    mem['h0400 +:3] = '{ 8'h4c, 8'h00, 8'h04 }; // jmp 0400
    mem['h0500 +:3] = '{ 8'h4c, 8'h00, 8'h05 }; // jmp 0500
    mem['h0600 +:3] = '{ 8'h4c, 8'h00, 8'h06 }; // jmp 0600

    #17 rst = 1;
   #100 rst = 0;
        irq = 0;
        nmi = 0;
        rdy = 1;

   #200 wait(cpu_inst.state == cpu_inst.DECODE && rdy);
        @(posedge clk);
        `tb_assert(cpu_inst.PC_temp == 'h0401);
        tb_report();
        $finish(2);
end

endmodule
`resetall
