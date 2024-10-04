// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`resetall
`timescale 1ns/1ps
`default_nettype none

package tb_utils;

bit assdie  = 0;
int asstot  = 0;
int asspass = 0;
int assfail = 0;

task tb_asspass(input string a, input string f, input int n);
    ++asstot;
    ++asspass;
endtask

task tb_assfail(input string a, input string f, input int n);
    ++asstot;
    ++assfail;
    $error("assert failed: %s at (%s:%0d)",a, f, n);
    if (assdie) begin
        $error("dying now due to failed assert!");
        $finish(2);
    end
endtask

task tb_report();
    $display("\nAssert report:");
    $display("    passed: %0d/%0d", asspass, asstot);
    $display("    failed: %0d/%0d", assfail, asstot);
    if (assfail > 0)
        $error("Failed! bad asserts");
    else if (asstot <= 0)
        $error("Failed! no asserts checked");
    else
        $display("Success! all asserts passed!\n");
endtask

endpackage
`resetall
