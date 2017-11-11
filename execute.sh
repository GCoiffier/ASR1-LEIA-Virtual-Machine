#!/bin/bash

python3 asm.py $2.s
./simu $1 $2.obj