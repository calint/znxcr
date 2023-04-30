#!/bin/sh
# tools:
#   iverilog: Icarus Verilog version 11.0 (stable)
#        vvp: Icarus Verilog runtime version 11.0 (stable)
set -e

iverilog -o cpu -c src_list.txt
vvp cpu


