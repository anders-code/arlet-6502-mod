// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`resetall
`timescale 1ns/1ps
`default_nettype none

`include "sim/utils/tb_assert.vh"

module tb_functional();

import tb_utils::*;

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

logic [7:0]tc, lasttc;
assign tc = mem['h0200];

time t1, t2;

initial begin
    $readmemh(tb_rel_path("../mem-files/6502_functional_test.mem"), mem, 0, $size(mem)-1);
    mem['hfffc] = 8'h00;
    mem['hfffd] = 8'h04;

    #17 rst = 1;
   #100 rst = 0;
        irq = 0;
        nmi = 0;
        rdy = 1;

        @(posedge clk);
        t1 = $time();
        t2 = t1;

        wait(cpu_inst.PC == 'h3469);
        @(posedge clk);
        $display("yay! %0d", ($time-t1)/10);
        $finish(2);
//        forever begin
//            if (lasttc !== tc) begin            
//                $display("test %0d (%0d) %0d", tc, $time-t1, $time-t2);
//                lasttc = tc;
//                t2 = $time;
//            end
//        end

//   #200 wait(cpu_inst.state == cpu_inst.DECODE && rdy);
//        @(posedge clk);
//        `tb_assert(cpu_inst.PC_temp == 'h0401);
//        `tb_assert_report;
//        $finish(2);
end

always begin
    #10_000_000;
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
