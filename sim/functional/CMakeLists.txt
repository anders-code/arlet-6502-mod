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

add_executable(tb_functional_vl tb_functional_vl.cpp)

file(GLOB RTL_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    ../../rtl/*.v
)

verilate(tb_functional_vl
    TOP_MODULE     tb_functional_vl
    PREFIX         Vfunctional
    TRACE          1
    THREADS        0
    OPT_SLOW       -O3
    OPT_FAST       -O3
    OPT_GLOBAL     -O3
    VERILATOR_ARGS -DSIM=1 -Wall -Wpedantic -Wno-fatal -Werror-USERFATAL -Werror-USERERROR
    SOURCES
        cfg.vlt
        ../utils/tb_utils.sv
        tb_functional_vl.sv 
        ${RTL_SOURCES}
)

target_compile_definitions(tb_functional_vl PUBLIC
    VM_TRACE=$<BOOL:$<TARGET_PROPERTY:tb_functional_vl,VERILATOR_TRACE>>
    VM_TRACE_VCD=$<BOOL:$<TARGET_PROPERTY:tb_functional_vl,VERILATOR_TRACE_VCD>>
)

#add_executable(tb1 tb1.cpp)
target_compile_options(tb_functional_vl PRIVATE -g3)
#target_link_libraries(tb1 v6502)
