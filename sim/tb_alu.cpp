#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Valu.h"

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

  Valu* top = new Valu;
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



  

  std::cout << "##### [TESTING] Addition #####" << std::endl;
  for (uint16_t i = 0; i <= 255; i++) {
    for (uint16_t j = 0; j <= 255; j++) {
      total_tests += 1;


      top->clk = 0;
      top->reset = 0;
      top->a = i;
      top->b = j;
      top->selector = 0x08;
      top->eval();
      if (dump_waves) {
	tfp->dump(timestamp);
	timestamp += 10;
      }

      top->clk = 1;
      top->eval();


      
      // test for validity

      uint8_t valid_out = (0)& 0xFF;
      uint8_t valid_c = i < j ? 1 : 0;


      if (valid_out == top->out && valid_c == top->c) {
	pass_count += 1;
	std::cout << "PASSED " << pass_count << std::endl;
      } else {
	fail_count += 1;
	if (fail_count > 20) goto END;

	std::cout << "######################" << std::endl;
	std::cout << "[FAIL]" << std::endl;
	print_binary(i);
	print_binary(j);
	std::cout << "[Expected]: " << std::endl;
	print_binary(valid_out);
	print_binary(valid_c);
	std::cout << "[GOT]: " << std::endl;
	print_binary(top->out);
	print_binary(top->c);
	std::cout << "######################" << std::endl;

      }

      if (dump_waves) {
	tfp->dump(timestamp);
	timestamp += 10;
      }
	
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
