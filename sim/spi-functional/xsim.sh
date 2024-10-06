#!/bin/sh -x

rm -fr xsim.dir/

/opt/Xilinx/Vivado/2023.1/bin/xvlog -sv -relax -nolog -i ../.. -d SIM ../../rtl/*.v ../../rtl/*.sv ../utils/tb*.sv tb_spi_functional.sv
rm -f *.pb *.jou

/opt/Xilinx/Vivado/2023.1/bin/xelab -debug off -relax -nolog -snapshot tb_spi_functional -top tb_spi_functional
rm -f *.pb *.jou

/opt/Xilinx/Vivado/2023.1/bin/xsim -nolog tb_spi_functional "${1:--R}"
rm -f *.pb *.jou
