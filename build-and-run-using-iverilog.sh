#!/bin/sh
# tools:
#   iverilog: Icarus Verilog version 11.0 (stable)
#        vvp: Icarus Verilog runtime version 11.0 (stable)
set -e

iverilog -o cpu \
    znxrc.srcs/sim_1/TB_Control.v \
    znxrc.srcs/sources_1/ROM.v \
    znxrc.srcs/sources_1/Control.v \
    znxrc.srcs/sources_1/CallStack.v \
    znxrc.srcs/sources_1/LoopStack.v \
    znxrc.srcs/sources_1/Registers.v \
    znxrc.srcs/sources_1/ALU.v \
    znxrc.srcs/sources_1/Zn.v \
    znxrc.srcs/sources_1/RAM.v
vvp cpu


