cmake_minimum_required(VERSION 3.22)

project(RV32_pipeline)

find_package(verilator HINTS $ENV{VERILATOR_ROOT})

add_executable(Vtop main.cpp)
verilate(Vtop SOURCES top.v  VERILATOR_ARGS --trace)

target_include_directories(Vtop PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/ELFIO)