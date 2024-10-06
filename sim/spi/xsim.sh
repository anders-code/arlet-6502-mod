#!/bin/sh -x

rm -fr xsim.dir/

/opt/Xilinx/Vivado/2023.1/bin/xvlog -sv -relax -nolog -i ../.. -d SIM ../../rtl/spi_sram_slave.sv ../utils/tb*.sv tb_spi_nl.sv sky130_fd_sc_hd.v primitives.v tt_um_anders_tt_6502.nl.v
rm -f *.pb *.jou

/opt/Xilinx/Vivado/2023.1/bin/xelab -debug off -relax -nolog -snapshot tb_spi_nl -top tb_spi_nl
rm -f *.pb *.jou

/opt/Xilinx/Vivado/2023.1/bin/xsim -nolog tb_spi_nl "${1:--R}"
rm -f *.pb *.jou
