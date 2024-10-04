Arlet's 6502 CPU core in Verilog
--------------------------------

This is a modified version of Arlet Ottens very nice little 6502 CPU core
written in Verilog/SystemVerilog from https://github.com/Arlet/verilog-6502.

The purpose of the modifications is ultimatly to wrap the core with the
necessary memory managment logic and host it on
[ASIC](https://github.com/anders-code/tt09-6502) and/or FPGA hardware targets.

### Modifications to core ([ALU.v](rtl/alu_6502.v) and [cpu.v](rtl/cpu_6502.v)):

  - naming consistency
  - cleanup/lint
  - minor bugs/timing
  - for further details see `git log`

### Other Additions:

  - .gitignore, git submodules
  - integrate with simulation/test-benches
    - Verilator
    - Icarus
    - Vivado
  - build system (Make/CMake) for sims
  - SPI SRAM memory manager
  - additions[^1] are licensed under [MIT](LICENSE.md)

> Have fun. 

**Indeed!** :smiley:


Original README content
-----------------------

A Verilog HDL version of the old MOS 6502 CPU.

Note: the 6502 core assumes a synchronous memory. This means that valid
data (DI) is expected on the cycle *after* valid address. This allows
direct connection to (Xilinx) block RAMs. When using asynchronous memory,
I suggest registering the address/control lines for glitchless output signals.

Have fun. 

[^1]: All original code from [Arlet](https://github.com/Arlet/verilog-6502)
and modifications to it, of course, remain copyright Arlet under his original license.
