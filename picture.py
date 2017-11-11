#!/usr/bin/env python

import os
import sys
import pylab as plb
import argparse
import re

# size of image
WIDTH = None
HEIGHT = None

def get_color(pixel):
    p = [int(x*31) for x in pixel]
    return (p[0]*(1<<10) + p[1]*(1<<5) + p[2])

def generate_colors(imgfile) :
    '''the 14 more used colors of img in a dict'''
    color_dict = {} # occurence dictionnary
    for i in range(HEIGHT):
        for j in range(WIDTH):
            coul = get_color(imgfile[i,j])
            if coul not in color_dict :
                color_dict[coul] = 1
            else :
                color_dict[coul] +=1
    most_common = []
    for i in range(13):
        maxi = -float("inf")
        cur = None
        for x in color_dict:
            if color_dict[x]>maxi:
                maxi = color_dict[x]
                cur = x
        color_dict.pop(x, None)
        most_common.append(x)
    return dict([(most_common[i],i+2) for i in range(len(most_common))])



def generate_full(imgfile):
    """
    function called to plot a full 160*128 picture into the memory
    """
    code = ["letl r0 0",
            "leth r0 176"
            ] #r0 is videomem adress to be incremented
    #r1 will be the current color. other color will be in r2 to r15
    m = generate_colors(imgfile)
    print(m)
    for x in m :
        a,b = x//(1<<8) , x%(1<<8)
        code.append("letl r{0} {1}".format(m[x],b))
        code.append("leth r{0} {1}".format(m[x],a))

    for i in range(HEIGHT):
        for j in range(WIDTH):
            c = get_color(imgfile[i,j])
            if c in m :
                code.append("wmem r{0} r0".format(m[c]))
            else :
                a,b = c//(1<<8) , c%(1<<8)
                code.append("letl r1 {0}".format(b))
                code.append("leth r1 {0}".format(a))
                code.append("wmem r1 r0")
            code.append("add r0 r0 1")
    code.append("jump 0")
    return code


def generate(imgfile):
    """
    function called to plot an image of color r0
    of top_right corner (r1,r2)
    and width and height unknown
    """
    global WIDTH,HEIGHT
    HEIGHT = len(imgfile)
    WIDTH = len(imgfile[0])
    code = [] #current adress of top-right = r4
    for i in range(HEIGHT):
        for j in range(WIDTH):
            if not abs(sum(imgfile[i,j]) - 4) < 1E-5 : #black
                code.append("write r0 r4")
            else :
                if code :
                    tokens = re.findall('[\S]+', code[-1])
                    if tokens[0] == "add" and tokens[-1] != "r5":
                        n = int(tokens[-1])
                        code.pop()
                        code.append("add r4 r4 {0}".format(n+1))
                    else :
                        code.append("add r4 r4 1")
                else :
                    code.append("add r4 r4 1")
        code.append("add r4 r4 r5") #r5 is what to jump when end_of_line
    return code


## ------ main ------
if __name__ == '__main__':

    argparser = argparse.ArgumentParser(description='This file reads an image in black and white, of size 160*128, and generate the assembly code that plots the image (.s file) ')
    argparser.add_argument('filename', help='name of the source file.  Should be a .png')

    options=argparser.parse_args()
    filename = options.filename
    filename = os.path.join("IMG",filename)
    img = plb.imread(filename)
    HEIGHT = len(img)
    WIDTH = len(img[0])
    if (img.shape[0] != 128 or img.shape[1] != 160) :
        code = generate(img)
    else :
        code = generate_full(img)
    basefilename, extension = os.path.splitext(filename)
    obj_file = os.path.split(basefilename)[-1]+".s"
    

    outfile = open(os.path.join("ASM",obj_file), "w")
    for instr in code:
        outfile.write(instr)
        outfile.write("\n")
    outfile.close()
