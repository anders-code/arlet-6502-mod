#include <stdlib.h>
//#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "V6502.h"
#include "V6502___024root.h"

#define RESET_TIME 10
#define RUN_TIME 600000000
//#define RUN_TIME 2000000
#define GO_TIME 200
#define LOG_TIME 100000

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env)
{
    VerilatedContext *context = new VerilatedContext();
    context->threads(1);

    V6502 *dut = new V6502(context);

//    const char *argv2[] = { "+READMEM_PREFIX=./build/data/", 0 };
    Verilated::commandArgs(argc, argv);

#if VM_TRACE
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC();
    dut->trace(m_trace, 10);
    m_trace->open("waveform.vcd");
#endif

    dut->rst = 1;
    dut->nmi = 0;
    dut->irq = 0;

    while (sim_time < RESET_TIME || !dut->clk)
    {
        dut->clk ^= 1;
        dut->eval();
#if VM_TRACE
        m_trace->dump(sim_time);
#endif
        sim_time++;
    }

    dut->rst = 0;

    while (sim_time < GO_TIME || dut->clk)
    {
        dut->clk ^= 1;
        dut->eval();
#if VM_TRACE
        m_trace->dump(sim_time);
#endif
        sim_time++;
    }

    dut->rootp->v6502_verilator__DOT__cpu_inst__DOT__state = 0x0d;
    dut->rootp->v6502_verilator__DOT__cpu_inst__DOT__PC = 0x400;
    dut->eval();

#if 0
    dut->nmi = 1;

    while (dut->rootp->v6502_verilator__DOT__cpu_inst__DOT__state != 0x0b || dut->clk)
    {
        dut->clk ^= 1;
        dut->eval();
#if VM_TRACE
        m_trace->dump(sim_time);
#endif
        sim_time++;
    }

    dut->nmi = 0;

    while (dut->rootp->v6502_verilator__DOT__cpu_inst__DOT__state != 0x16 || dut->clk)
    {
        dut->clk ^= 1;
        dut->eval();
        dut->rootp->v6502_verilator__DOT__memout = 0x00;
        dut->eval();
#if VM_TRACE
        m_trace->dump(sim_time);
#endif
        sim_time++;
    }

    while (dut->rootp->v6502_verilator__DOT__cpu_inst__DOT__state != 0x17 || dut->clk)
    {
        dut->clk ^= 1;
        dut->eval();
        dut->rootp->v6502_verilator__DOT__memout = 0x04;
        dut->eval();
#if VM_TRACE
        m_trace->dump(sim_time);
#endif
        sim_time++;
    }
#endif

    while (sim_time < RUN_TIME && dut->rootp->v6502_verilator__DOT__cpu_inst__DOT__PC != 0x3469)
    {
        dut->clk ^= 1;
        dut->eval();
#if VM_TRACE
if (sim_time < GO_TIME+200 || sim_time > RUN_TIME-LOG_TIME)
        m_trace->dump(sim_time);
#endif
        sim_time++;
    }
    printf("PPPPPP: %lu\n", sim_time);

#if VM_TRACE
    m_trace->close();
#endif
//    delete dut;
    return EXIT_SUCCESS;
}

