#include "Vtop.h"
#include "Vtop_datapath.h"
#include "Vtop_PCreg.h"
#include "Vtop_memory.h"
#include "Vtop_memory__S400000.h"
#include "Vtop_regfile.h"
#include "Vtop_rv32.h"
#include "Vtop_top.h"
#include "verilated.h"
#include <verilated_vcd_c.h>

#include "elfio/elfio.hpp"

#include <memory>
#include <iostream>
#include <string>

size_t loadELF(const std::string &filepath, Vtop_memory__S400000 &memory);

int main(int argc, char **argv) {
  auto contextp = std::make_unique<VerilatedContext>();
  contextp->debug(0);
  contextp->traceEverOn(true);
  contextp->commandArgs(argc, argv);

  auto model = std::make_unique<Vtop>(contextp.get(), "TOP");
  auto &regs = model->top->rv32->dp->rf->regs;
  auto &imem_stor = model->top->imem->storage;
  auto &dmem_stor = model->top->dmem->storage;
  auto &pc = model->top->rv32->dp->pcreg->pc;

  Verilated::traceEverOn(true);
  auto vcd = std::make_unique<VerilatedVcdC>();
  model->trace(vcd.get(), 10);
  vcd->open("out.vcd");

  // Init state
  model->clk = 0;
  for (uint32_t r = 0; r < 32; r++) {
    regs[r] = 0;
  }
  std::cout << "Init\n";
  for (uint8_t i = 0; i < 255; i++) {
    dmem_stor[i] = i + 1;
  }

  if (argc < 2) {
    std::cerr << "Enter ELF filename\n";
    return 1;
  }
  pc = loadELF(argv[1], *model->top->imem);

  auto dump_state = [&](size_t clockn) {
    std::cout << "Clock : " << clockn << "\n";
    std::cout << "PC : " << std::hex << pc << "\n";
    std::cout << "Instr: " << model->top->instr << "\n";
    for (uint32_t r = 0; r < 4; r++) {
      for (uint32_t c = 0; c < 8; c++) {
        std::cout << std::dec << "X" << r * 8 + c << " = " << std::hex
                  << regs[r * 8 + c] << " ";
      }
      std::cout << "\n";
    }
    std::cout << "\n";
  };

  // Work
  size_t vtime = 0;
  size_t clockn = 0;
  std::cout << "Evaluate model\n";
  while (!contextp->gotFinish()) {
    model->eval();
    vcd->dump(vtime++);
    model->clk = !model->clk;
    if (model->clk)
      dump_state(++clockn);
    std::cout << "\n";
  }
  vcd->dump(vtime++);
  dump_state(++clockn);
  std::cout << "Mem dump:\n";
  for (uint8_t i = 0; i < 10; i++) {
    std::cout << (int)dmem_stor[i] << " ";
  }
  std::cout << "\n";
  std::cout << "Finished\n";

  model->final();
  vcd->close();
}

size_t loadELF(const std::string &filepath, Vtop_memory__S400000 &memory) {
  auto reader_ptr = std::make_unique<ELFIO::elfio>();
  auto &m_reader = *reader_ptr;
  if (!m_reader.load(filepath))
    throw std::invalid_argument("Bad ELF filename : " + filepath);
  // check for 32-bit
  if (m_reader.get_class() != ELFIO::ELFCLASS32) {
    throw std::runtime_error("Wrong ELF file class.");
  }
  // Check for little-endian
  if (m_reader.get_encoding() != ELFIO::ELFDATA2LSB) {
    throw std::runtime_error("Wrong ELF encoding.");
  }
  ELFIO::Elf_Half seg_num = m_reader.segments.size();
  //
  for (size_t seg_i = 0; seg_i < seg_num; ++seg_i) {
    const ELFIO::segment *segment = m_reader.segments[seg_i];
    if (segment->get_type() != ELFIO::PT_LOAD) {
      continue;
    }
    uint32_t address = segment->get_virtual_address();
    size_t filesz = static_cast<size_t>(segment->get_file_size());
    size_t memsz = static_cast<size_t>(segment->get_memory_size());
    //
    if (memsz) {
      for (uint32_t bytei = 0; bytei < memsz; bytei++) {
        memory.storage[address + bytei] = 0;
      }
    }
    if (filesz) {
      for (uint32_t bytei = 0; bytei < filesz; bytei++) {
        memory.storage[address + bytei] = segment->get_data()[bytei];
      }
    }
  }
  return m_reader.get_entry();
}