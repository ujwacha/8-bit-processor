#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vregister_bank.h"

#include <iostream>
#include <cstdint>



#define DUMP_WAVE if (dump_waves) { \
  tfp->dump(timestamp);		    \
  timestamp += 10;		    \
  }				    \



void print_binary(uint8_t value) {
  for (int i = 7; i >= 0; i--) {
    std::cout << ((value >> i) & 0x01);
    if (i % 4 == 0 && i != 0) std::cout << " ";
  }
  std::cout << std::endl;
}


int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);

  Vregister_bank* top = new Vregister_bank;
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

  std::cout << "##### [TESTING] register_bank #####" << std::endl;


  std::cout << "##### [TESTING] read outputs #####" << std::endl;
  
  for (uint8_t i = 0; i <= 7; i++) {
    for (uint8_t j = 0; j <= 7; j++) {
	total_tests += 1;

	top->cs = 1;

	top->clk = 0;
	top->rst = 0;
	top->r2 = i;
	top->r3 = j;
	top->r1 = 0;
	top->f_ch = 0;
	top->r_in = 0;
	top->flg_in = 0;
	top->eval();
	
	DUMP_WAVE;

	top->clk = 1;
	top->eval();

	DUMP_WAVE;

	// check if the output is matching

	uint8_t valid_out_a = i;
	uint8_t valid_out_b = j;


	if (valid_out_a == top->out_a && valid_out_b == top->out_b) {
	  pass_count += 1;
	  std::cout << "PASSED " << pass_count << std::endl;
	} else {
	  fail_count += 1;
	  if (fail_count > 20) goto END;
	  std::cout << "[FAIL]" << std::endl;
	  print_binary(i);
	  print_binary(j);
	  print_binary(top->out_a);
	  print_binary(top->out_b);
	  std::cout << "###############################" << std::endl;
	}

	DUMP_WAVE;
    }
  }

  
  std::cout << "##### [TESTING] write #####" << std::endl;

  for (uint8_t i = 0; i <= 7; i++) {

    {
	total_tests += 1;
	top->cs = 1;

	// first write to the register

	top->clk = 0;
	top->rst = 0;
	top->r2 = 0;
	top->r3 = 0;
	top->r1 = i;
	top->f_ch = 0;
	top->r_in = i + 1;
	top->flg_in = 0;
	top->eval();

	DUMP_WAVE;


	top->clk = 1;
	top->eval();

	DUMP_WAVE;


	// now read from the clock
	top->clk = 0;
	top->rst = 0;
	top->r2 = i;
	top->r3 = 0;
	top->r1 = 0;
	top->f_ch = 0;
	top->r_in = 0;
	top->flg_in = 0;
	top->eval();
	
	DUMP_WAVE;

	top->clk = 1;
	top->eval();

	DUMP_WAVE;

	// check if the output is matching

	uint8_t valid_out_a = i + 1;


	if (valid_out_a == top->out_a) {
	  pass_count += 1;
	  std::cout << "PASSED " << pass_count << std::endl;
	} else {
	  fail_count += 1;
	  if (fail_count > 20) goto END;
	  std::cout << "[FAIL]" << std::endl;
	  print_binary(i);
	  print_binary(top->out_a);
	  print_binary(top->out_b);
	  std::cout << "###############################" << std::endl;
	}

	DUMP_WAVE;
    }
    
  }


  std::cout << "##### [TESTING] Flag #####" << std::endl;

  for (uint8_t i = 0; i <= 1; i++) {

    // change flag value

    total_tests += 1;
    top->cs = 1;

    // first write to the register

    top->clk = 0;
    top->rst = 0;
    top->r2 = 0;
    top->r3 = 0;
    top->r1 = 0;
    top->f_ch = 1;
    top->r_in = 0;
    top->flg_in = i;
    top->eval();

    DUMP_WAVE;

    top->clk = 1;
    top->eval();

    DUMP_WAVE;


    uint8_t valid_out_flag = i;


    if (valid_out_flag == top->flag_stat) {
      pass_count += 1;
      std::cout << "PASSED " << pass_count << std::endl;
    } else {
      fail_count += 1;
      if (fail_count > 20) goto END;
      std::cout << "[FAIL]" << std::endl;
      print_binary(i);
      std::cout << "###############################" << std::endl;
    }

    DUMP_WAVE;
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
