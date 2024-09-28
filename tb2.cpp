#include <stdlib.h>
//#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "V65022.h"
#include "V65022___024root.h"

#define RESET_TIME 10
#define RUN_TIME 10000000000
//#define RUN_TIME 100000000
#define GO_TIME 8000
#define LOG_TIME 4000000

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env)
{
    VerilatedContext *context = new VerilatedContext();
    context->threads(1);

    V65022 *dut = new V65022(context);

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

    while (sim_time < GO_TIME || dut->rdy || dut->clk)
    {
        dut->clk ^= 1;
        dut->eval();
#if VM_TRACE
        m_trace->dump(sim_time);
#endif
        sim_time++;
    }

    dut->rootp->v6502_verilator2__DOT__cpu_inst__DOT__state = 0x0d;
    dut->rootp->v6502_verilator2__DOT__cpu_inst__DOT__PC = 0x400;
    dut->eval();
#if VM_TRACE
        m_trace->dump(sim_time);
        sim_time++;
#endif

    unsigned ptc = 0xffffffff;
    while (sim_time < RUN_TIME && dut->rootp->v6502_verilator2__DOT__cpu_inst__DOT__PC != 0x3469)
    {
        dut->clk ^= 1;
        dut->eval();
#if VM_TRACE
if (sim_time < GO_TIME+8000 || sim_time > RUN_TIME-LOG_TIME)
        m_trace->dump(sim_time);
#endif
        sim_time++;
        if (sim_time % 10000000 == 0 || ptc != dut->tc)
            printf("cycle: %lu test_case: 0x%02x\n", sim_time, dut->tc);
        ptc = dut->tc;
    }
    printf("PPPPPP: %lu\n", sim_time);

#if VM_TRACE
    m_trace->close();
#endif
//    delete dut;
    return EXIT_SUCCESS;
}

