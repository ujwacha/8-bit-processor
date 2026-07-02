#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcontrol_unit.h"
#include <iostream>
#include <cstdint>
#include <vector>
#include <cassert>

#define DUMP_WAVE if (dump_waves) { tfp->dump(timestamp); timestamp += 10; }

// -----------------------------------------------------------------
// Memory emulation
// -----------------------------------------------------------------
const uint32_t MEM_SIZE = 65536;
uint8_t memory[MEM_SIZE] = {0};

// Test program (little‑endian, 4‑byte instructions)
void init_memory() {
    // Instruction 0: ALU ADD r1, r2 (no immediate)
    // Byte0: alu_out=0, imme=0, r1_s=1  => 0x01
    // Byte1: jmp=0, r2_s=2, sto=0, r1_s=1 => 0x21
    // Byte2: 0x00
    // Byte3: 0x00
    memory[0x0000] = 0x01;
    memory[0x0001] = 0x21;
    memory[0x0002] = 0x00;
    memory[0x0003] = 0x00;

    // Instruction 1: JUMP to 0x0000 (if flag set)
    // Byte0: alu_out=0, imme=1, r1_s=0 => 0x08
    // Byte1: jmp=1, r2_s=0, sto=0, r1_s=0 => 0x80
    // Byte2: imme_high = 0x00
    // Byte3: imme_low  = 0x00
    memory[0x0004] = 0x08;
    memory[0x0005] = 0x80;
    memory[0x0006] = 0x00;
    memory[0x0007] = 0x00;

    // Instruction 2: LOAD r1 from address 0x0010
    // Byte0: alu_out=1 (load), imme=1, r1_s=1 => 0x19
    // Byte1: jmp=0, r2_s=0, sto=1, r1_s=1 => 0x09
    // Byte2: imme_high = 0x00
    // Byte3: imme_low  = 0x10
    memory[0x0008] = 0x19;
    memory[0x0009] = 0x09;
    memory[0x000A] = 0x00;
    memory[0x000B] = 0x10;

    // Instruction 3: STORE r0 to address 0x0011
    // Byte0: alu_out=0 (store), imme=1, r1_s=0 => 0x08
    // Byte1: jmp=0, r2_s=0, sto=1, r1_s=0 => 0x08
    // Byte2: imme_high = 0x00
    // Byte3: imme_low  = 0x11
    memory[0x000C] = 0x08;
    memory[0x000D] = 0x08;
    memory[0x000E] = 0x00;
    memory[0x000F] = 0x11;

    // Data for load
    memory[0x0010] = 0x42;   // value to load into r1
    // r0_stat will be set directly in the testbench (we don't have a register bank)
}

// -----------------------------------------------------------------
// Helper to tick the clock
// -----------------------------------------------------------------
void tick(Vcontrol_unit* top, VerilatedVcdC* tfp, uint64_t& timestamp, bool dump_waves) {
    top->clk = 0;
    top->eval();
    DUMP_WAVE;
    top->clk = 1;
    top->eval();
    DUMP_WAVE;
}

// -----------------------------------------------------------------
// Main test
// -----------------------------------------------------------------
int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vcontrol_unit* top = new Vcontrol_unit;
    VerilatedVcdC* tfp = nullptr;
    bool dump_waves = true;

    if (dump_waves) {
        Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);
        tfp->open("control_unit.vcd");
    }

    uint64_t timestamp = 0;
    uint32_t cycles = 0;
    const uint32_t MAX_CYCLES = 60;

    // Initialize memory
    init_memory();

    // Prepare testbench signals
    top->rst = 1;
    top->r0_stat = 0x55;      // arbitrary initial value for r0
    top->flag_stat = 1;       // set flag to allow jump

    std::cout << "########################################\n";
    std::cout << "##### Control Unit Testbench Start #####\n";
    std::cout << "########################################\n";

    // Reset sequence
    tick(top, tfp, timestamp, dump_waves);
    top->rst = 0;
    tick(top, tfp, timestamp, dump_waves);

    // Main simulation loop
    while (cycles < MAX_CYCLES) {
        // Feed memory data if the control unit is reading
        if (top->mem_sel && top->mem_read) {
            uint32_t addr = top->adress_line;
            top->mem_data_in = memory[addr & 0xFFFF];
        } else {
            top->mem_data_in = 0;   // don't care
        }

        // Optionally, you can drive r0_stat and flag_stat dynamically here
        // For example, change flag_stat before a branch instruction.
        // For simplicity, we keep them constant.

        // Tick the clock
        tick(top, tfp, timestamp, dump_waves);

        // Print some interesting signals every cycle (optional)
        // std::cout << "Cycle " << cycles << ": state=" << top->state
        //           << " if_state=" << top->if_state
        //           << " alu_state=" << top->alu_state
        //           << " pc=" << top->pc
        //           << " adress_line=" << top->adress_line
        //           << " mem_sel=" << top->mem_sel
        //           << " mem_read=" << top->mem_read << "\n";

        cycles++;

        // Check for expected behaviour (simple sanity checks)
        // For example, after a few cycles, the control unit should have finished fetching
        // and be in decode or ALU state. We can add more detailed checks here.
        if (cycles == 8) {
            // By cycle 8, we should have fetched the first instruction and be in decode
            // or in the middle of ALU pipeline.
            std::cout << "Cycle 8: check that control signals are reasonable.\n";
            // (Add more assertions as needed)
        }
    }

    // Final state
    std::cout << "\n--- Simulation finished after " << cycles << " cycles ---\n";
    std::cout << "Final adress_line = " << top->adress_line << "\n";
    std::cout << "Final r1 = " << (int)top->r1 << ", r2 = " << (int)top->r2 << ", r3 = " << (int)top->r3 << "\n";
    std::cout << "Final alu_out = " << (int)top->alu_out << "\n";
    std::cout << "Final f_ch = " << (int)top->f_ch << ", r_ch = " << (int)top->r_ch << ", rb_sel = " << (int)top->rb_sel << "\n";

    if (dump_waves) {
        tfp->close();
        delete tfp;
        std::cout << "Waveform saved to control_unit.vcd\n";
    }

    delete top;
    return 0;
}
