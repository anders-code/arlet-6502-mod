#!/bin/sh -x

rm -fr xsim.dir/

/opt/Xilinx/Vivado/2023.1/bin/xvlog -sv -relax -nolog -i ../.. -d SIM ../../rtl/*.sv ../utils/tb*.sv tb_spi_basic.sv
rm -f *.pb *.jou

/opt/Xilinx/Vivado/2023.1/bin/xelab -debug off -relax -nolog -snapshot tb_spi_basic -top tb_spi_basic
rm -f *.pb *.jou

/opt/Xilinx/Vivado/2023.1/bin/xsim -nolog tb_spi_basic "${1:--R}"
rm -f *.pb *.jou
