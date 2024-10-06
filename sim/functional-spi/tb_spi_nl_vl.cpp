#include <stdlib.h>
//#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vspi_nl.h"
//#include "Vspi_nl___024root.h"

#define RESET_TIME 20
//#define RUN_TIME 10000000000
//#define RUN_TIME 200000000
#define RUN_TIME (192482758+100000)*44ULL
#define LOG_TIME 200000

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env)
{
    VerilatedContext *context = new VerilatedContext();
    context->threads(1);

    Vspi_nl *dut = new Vspi_nl(context);

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

    unsigned ptc = 0xffffffff;
    while (sim_time < RUN_TIME && dut->PC != 0x3469 || dut->clk)
    {
        dut->clk ^= 1;
        dut->eval();
#if VM_TRACE
if (sim_time < LOG_TIME || sim_time > RUN_TIME-LOG_TIME)
        m_trace->dump(sim_time);
#endif
        sim_time++;
        if (sim_time % 10000000 == 0 || ptc != dut->tc)
            printf("cycle: %lu test_case: 0x%02x\n", sim_time, dut->tc);
        ptc = dut->tc;
    }
    // http://forum.6502.org/viewtopic.php?f=8&t=6202#p90723
    printf("Success: %lu (%lu) ideal 96241364\n", sim_time, sim_time/2-15);

#if VM_TRACE
    m_trace->close();
#endif
//    delete dut;
    return EXIT_SUCCESS;
}

