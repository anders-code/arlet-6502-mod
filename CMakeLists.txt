cmake_minimum_required(VERSION 3.19)

project(vaxfpga)

file(REAL_PATH ${CMAKE_BINARY_DIR}/.. BUILD_DIR)

set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(BIN_DIR    ${BUILD_DIR}/bin)
set(LIB_DIR    ${BUILD_DIR}/lib)
set(DATA_DIR   ${BUILD_DIR}/data)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BIN_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR})

find_package(verilator 5 HINTS $ENV{VERILATOR_ROOT} REQUIRED)

add_library(v6502 STATIC)

file(GLOB RTL_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    rtl/*.v
)

verilate(v6502
    PREFIX         V6502
    TOP_MODULE     v6502_verilator
    TRACE          1
    THREADS        0
    OPT_SLOW       -O3
    OPT_FAST       -O3
    OPT_GLOBAL     -O3
    VERILATOR_ARGS -DSIM=1 --prof-cfuncs -CFLAGS -DVL_DEBUG -Wall -Wpedantic -Wno-fatal -Werror-USERFATAL -Werror-USERERROR
    SOURCES
        cfg.vlt
        v6502_verilator.sv 
        ${RTL_SOURCES}
)

target_compile_definitions(v6502 PUBLIC
    VM_TRACE=$<BOOL:$<TARGET_PROPERTY:v6502,VERILATOR_TRACE>>
    VM_TRACE_VCD=$<BOOL:$<TARGET_PROPERTY:v6502,VERILATOR_TRACE_VCD>>
)

add_executable(tb1 tb1.cpp)
target_compile_options(tb1 PRIVATE -g3)
target_link_libraries(tb1 v6502)
