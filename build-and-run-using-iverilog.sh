#!/bin/sh
set -e

iverilog -o cpu -c src_list.txt
vvp cpu

