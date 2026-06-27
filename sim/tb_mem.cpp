#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vmemory.h"

#include <iostream>
#include <cstdint>

void print_binary(uint8_t value) {
  for (int i = 7; i >= 0; i--) {
    std::cout << ((value >> i) & 0x01);
    if (i % 4 == 0 && i != 0) std::cout << " ";
  }
  std::cout << std::endl;
}


int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);

  Vmemory* top = new Vmemory;
  VerilatedVcdC* tfp = nullptr;
  bool dump_waves = true;


  if (dump_waves) {
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("adder.vcd");
  }


  double total_tests = 0;
  double pass_count = 0;
  double fail_count = 0;
  uint64_t timestamp = 0;
  
  std::cout << "###################" << std::endl;
  std::cout << "##### TESTING #####" << std::endl;
  std::cout << "###################" << std::endl;

  std::cout << "##### [TESTING] memory #####" << std::endl;
  for (uint16_t i = 0; i <= 255; i++) {
    total_tests += 1;
    
    top->clk = 0;
    top->rst = 0;
    top->adr = i;
    top->data_in = i;
    top->read = 0;
    top->eval();
    
    if (dump_waves) {
      tfp->dump(timestamp);
      timestamp += 10;
    }

    top->clk = 1;
    top->eval();
    if (dump_waves) {
      tfp->dump(timestamp);
      timestamp += 10;
    }
    // now we have written to the memory

    top->clk = 0;
    top->rst = 0;
    top->adr = i;
    top->data_in = 0x00;
    top->read = 1;
    top->eval();
    
    if (dump_waves) {
      tfp->dump(timestamp);
      timestamp += 10;
    }    

    top->clk = 1;
    top->rst = 0;
    top->eval();
    
    // test for validity

    uint8_t valid_out = i;

    if (valid_out == top->out) {
      pass_count += 1;
      std::cout << "PASSED " << pass_count << std::endl;
    } else {
      fail_count += 1;
      if (fail_count > 20) goto END;
      std::cout << "[FAIL]" << std::endl;
    }

    if (dump_waves) {
      tfp->dump(timestamp);
      timestamp += 10;
    }
	
  }

 END:
  std::cout << "###################" << std::endl;
  std::cout << "###### STATS ######" << std::endl;
  std::cout << "###################" << std::endl;

  std::cout <<  "total_tests: " << total_tests << std::endl;
  std::cout <<  "pass_count: " << pass_count << std::endl;
  std::cout <<  "fail_count: " << fail_count << std::endl;

  // Cleanup VCD
  if (dump_waves) {
    tfp->close();
    delete tfp;
    std::cout << "Waveform saved" << std::endl;
  }

  // cleanup top
  delete top;

  return (fail_count == 0)? 0 : 1;
}
