#include "Vtop.h"
#include "Vtop_controller.h"
#include "Vtop_datapath.h"
#include "Vtop_maindec.h"
#include "Vtop_memory.h"
#include "Vtop_memory__S8.h"
#include "Vtop_regfile.h"
#include "Vtop_rv32.h"
#include "Vtop_top.h"
#include "verilated.h"

#include "memory"
#include <iostream>

int main(int argc, char **argv) {
  auto contextp = std::make_unique<VerilatedContext>();
  contextp->debug(0);
  contextp->randReset(2);
  contextp->traceEverOn(true);
  contextp->commandArgs(argc, argv);

  auto model = std::make_unique<Vtop>(contextp.get(), "TOP");
  auto &regs = model->top->rv32->dp->rf->regs;
  auto &imem_stor = model->top->imem->storage;
  auto &dmem_stor = model->top->dmem->storage;
  auto &pc = model->top->rv32->dp->pc;

  // Init state
  model->clk = 0;
  model->reset = 0;
  pc = 0;
  for (uint32_t r = 0; r < 32; r++) {
    regs[r] = 0;
  }
  std::cout << "Init\n";
  for (size_t i = 0; i < 256; i++) {
    imem_stor[i] = 0;
  }

  constexpr uint32_t pause_instr = 0b00000001000000000000000000001111;

  size_t imem_i = 0;
  imem_stor[imem_i++] = 0x00500093; // li      ra,5
  imem_stor[imem_i++] = 0x00200113; // li      sp,2
  imem_stor[imem_i++] = 0x402081b3; // sub     gp,ra,sp
  imem_stor[imem_i++] = 0x0020a1b3; // slt     gp,ra,sp
  imem_stor[imem_i++] = 0x001121b3; // slt     gp,sp,ra
  imem_stor[imem_i++] = 0x0020e1b3; // or      gp,ra,sp
  imem_stor[imem_i++] = 0x0020c1b3; // xor     gp,ra,sp
  imem_stor[imem_i++] = 0x0010c1b3; // xor     gp,ra,ra
  imem_stor[imem_i++] = 0x002091b3; // sll     gp,ra,sp
  imem_stor[imem_i++] = 0x4020d1b3; // sra     gp,ra,sp
  imem_stor[imem_i++] = 0x0020d1b3; // srl     gp,ra,sp
  imem_stor[imem_i++] = pause_instr;

  for (size_t i = 0; i < 256; i++) {
    dmem_stor[i] = 0;
  }

  auto dump_state = [&]() {
    std::cout << "PC : " << std::hex << pc << "\n";
    std::cout << "Instr: " << model->top->instr << "\n";
    for (uint32_t r = 0; r < 4; r++) {
      for (uint32_t c = 0; c < 8; c++) {
        std::cout << std::dec << "X" << r * 8 + c << " = " << std::hex
                  << regs[r * 8 + c] << " ";
      }
      std::cout << "\n";
    }
  };

  // Work
  std::cout << "Evaluate model\n";
  model->top->rv32->c->md->pause = 0;
  while (!contextp->gotFinish() && !model->top->rv32->c->md->pause) {
    model->clk = !model->clk;
    model->eval();
    if (!model->clk) {
      dump_state();
      std::cout << "Controls: " << (int)model->top->rv32->c->md->controls << "\n";
    }
    std::cout << "\n";
  }
  dump_state();
  std::cout << "\n";
  std::cout << "Finished\n";

  model->final();
}
