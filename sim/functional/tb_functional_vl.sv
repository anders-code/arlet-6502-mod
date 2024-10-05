// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`resetall
`timescale 1ns/1ps
`default_nettype none

module tb_functional_vl (
    input wire clk,
    input wire rst,
    input wire nmi,
    input wire irq,
    input wire rdy,
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

assign tc = mem['h0200];

initial begin
    $readmemh(tb_rel_path("../mem-files/6502_functional_test.mem"), mem, 0, $size(mem)-1);
    mem['hfffc +: 2] = '{ 8'h00, 8'h04 };
end
endmodule
`resetall
