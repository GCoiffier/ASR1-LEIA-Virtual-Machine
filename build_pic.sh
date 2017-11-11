#!/bin/bash

python3 picture.py $1.png
python3 asm.py $1.s
./simu f $1.obj