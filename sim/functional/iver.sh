#!/bin/sh -x

iverilog -g2012 -o tb_functional -I ../.. ../../rtl/*.v ../utils/*.sv tb_functional.sv
