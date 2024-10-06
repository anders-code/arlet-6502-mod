// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`resetall
`timescale 1ns/1ps
`default_nettype none


module tb_functional (
    input wire clk,
    input wire rst
);

tb_clkrst clkrst_inst (.clk, .rst);

import tb_utils::*;

wire  [15:0]ab;
wire   [7:0]dout;
wire   [7:0]din;
wire        we;
logic       irq = 0;
logic       nmi = 0;
logic       rdy = 1;

cpu_6502 cpu_inst (
  .clk   (clk),
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

wire [7:0]tc = mem['h0200];
reg [7:0]lasttc = 0;
time lasttm = 100;
time lasttm2 = 0;
always @(posedge clk) begin
    if (tc != lasttc) begin
        $display("test %2d, cycle %0d (%0d)", tc, $time/10, ($time-lasttm)/10);
        lasttc  <= tc;
        lasttm  <= $time;
    end
    else if ($time - lasttm2 >= 10_000_000) begin
        $display("         cycle %0d (%0d)", $time/10, ($time-lasttm)/10);
        lasttm2 <= $time;
    end

    if (cpu_inst.PC == 'h3469)
        $finish(2);
end

initial begin
    $readmemh(tb_rel_path("../mem-files/6502_functional_test.mem"), mem, 0, $size(mem)-1);
    mem['hfffc] = 8'h00;
    mem['hfffd] = 8'h04;

    if ($test$plusargs("trace") != 0) begin
        static string tracefile = "tb_functional.vcd";
        $value$plusargs("tracefile=%s", tracefile);
        $display("tracing to %s...", tracefile);
        $dumpfile(tracefile);
        $dumpvars(100, tb_functional);
    end
end

endmodule
`resetall
