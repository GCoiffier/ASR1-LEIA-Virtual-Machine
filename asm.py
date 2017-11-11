#!/usr/bin/env python
import os
import sys
import re
import argparse

line=0 # global variable to make error reporting easier
current_instr="" # idem
labels={} # global because shared between the two passe

colors = {"white" : 32767 ,
          "black" : 0 , 
          "red" : 31744,
          "green" : 996 ,
          "green2" : 36224,
          "blue" :  31,
          "purple" : 16532,
          "grey" : 8456,
          "brown" : 0b1011010100100000}

def error(e):
    raise BaseException("Error at line " + str(line) + " : " + e)

def twos_complement(x,n_bits):
    '''
    x is an integer. Give the two's complement representation of x, on n bits
    '''
    if x>0 :
        return x
    return ((1<<n_bits) + x)%(1<<n_bits)


def asm_dest_reg(dest, max):
    """
    Converts the string dest into its encoding in the machine instruction. 
    max should be 7 or 15, depending on the instruction
    """
    val = int(dest[1:]) # this removes the "r".
    if dest[0]!='r' or val<0 or val>max:
        error("invalid destination register: " + dest)
    else:
        return val<<8


def asm_operand1(op1):
    """
    Converts the string op1 into its encoding in the machine instruction
    """
    return int(op1[1:])<<4
    
def asm_operand2(op2, signed_constant):
    """
    converts the string s into its encoding in the machine instruction
    """
    code = 0
    if signed_constant :
        code += 1<<11 # If signed_constant, 11th bit is 1
        code += int(op2)
    else :
        code += int(op2[1:]) # Removes the 'r'
    return code


def asm_memory_access(op):
    """
    converts the string op that should contain [rm] into its encoding in the machine instruction
    """
    return int((op.split("[")[-1].split("]")[0])[1:])
    

def asm_condition(cond):
    """
    Converts the string cond into its encoding in the snif machine instruction.
    """
    comparisons = ["eq", "neq", "sgt", "slt", "gt", "ge", "lt", "le"]
    try:
        val = comparisons.index(cond)
    except:
        error("invalid condition: " + cond)
    return val<<8


    
def asm_three_op_instr(op, arguments, signed_constant):
    """
    returns the machine instruction for arithmetic and logical instructions.
    This includes add, sub, and, or, xor, lsl, lsr and asr
    """
    if op == "add" :
        codeop = 0b0001
    elif op == "sub" :
        codeop = 0b0010
    elif op == "and" :
        codeop = 0b0100
    elif op == "or" :
        codeop = 0b0101
    elif op == "xor" :
        codeop = 0b0110
    elif op == "lsl" :
        codeop = 0b0111
    elif op == "lsr" :
        codeop = 0b1000
    elif op == "asr" :
        codeop = 0b1001
    else :
        error("Operation instruction " + op + " is invalid !")

    code = codeop<<12
    code += asm_dest_reg(arguments[0],7) # Destination is ALWAYS a register < 8
    code += asm_operand1(arguments[1])
    code += asm_operand2(arguments[2], signed_constant)

    return code


def asm_snif(arguments, signed_constant):
    code = (0b0011)<<12 # codeop
    arg1 = arguments[0]
    arg2 = arguments[2]
    cond = arguments[1]
    if cond == "eq" :
        cond_code = 0b000
    elif cond == "neq" :
        cond_code = 0b001
    elif cond == "sgt" :
        cond_code = 0b010
    elif cond == "slt" :
        cond_code = 0b011
    elif cond == "gt" :
        cond_code = 0b100
    elif cond == "ge" :
        cond_code = 0b101
    elif cond == "lt" :
        cond_code = 0b110
    elif cond == "le" :
        cond_code = 0b111
    else :
        error("Condition instruction " + cond + " is invalid !")
    code += (cond_code<<8)
    code += asm_operand1(arg1)
    code += asm_operand2(arg2, signed_constant)
    return code

    
def asm_wmem(arguments):
    code = 0b0000 # operation code 
    code += int(arguments[0][1:])<<4 # destination register
    code += asm_memory_access(arguments[1]) # memory adress
    return code

def asm_rmem(arguments,copy = False):
    code = 0b1111 # operation code 
    code <<= 12
    code += asm_dest_reg(arguments[0],15) # destination register
    code += asm_memory_access(arguments[1]) # memory adress
    if copy :
        code += (1<<4)
    return code


def asm_jump(arguments,current_address):
    global labels
    code = 0b1011 << 12
    if arguments not in labels :
        try :  
            # jump can be used with a signed integer rather than a label
            code += twos_complement(int(arguments), 12)
            print(int(arguments))
        except :
            error("argument of jump is not a known label and not an integer")
    else :
        print(labels[arguments] - current_address)
        code += twos_complement(labels[arguments] - current_address, 12)
    return code


def asm_call(arguments, current_address):
    global labels
    code = 0b1010 << 12
    if arguments not in labels :
        error("argument of call is not a known label")
    else :
        print(labels[arguments] - current_address)
        code += twos_complement(labels[arguments]//16, 12)
    return code


def asm_let(opcode, arguments):
    code = 0b1100
    if opcode : #let = leth
        code+=1
    code <<= 12
    code += asm_dest_reg(arguments[0],15) # the destination register
    code += twos_complement(int(arguments[1]),8) # The 8 bit constant 
    return code


def asm_pass(iteration, s_file, begin_adress = 0):
    """ 
    Goes through the code.
    iteration = 1 -> builds the labels and include
    iteration = 2 -> actually generates the bytecode
    begin_adress is here to handle included files
    """
    global line
    global labels
    code =[]
    print("\n PASS " + str(iteration))
    current_address = begin_adress
    source = open(s_file)
    for source_line in source:
        print("processing " + source_line) # just to get rid of the final newline
        tokens = re.findall('[\S]+', source_line) # \S means: any non-whitespace
        '''print(tokens)''' # to debug

        # if there is a label, consume it
        if tokens:
            token=tokens[0]
            if token[-1] == ":": # last character
                label = token[0: -1] # all the characters except last one
                labels[label] = current_address #new label to jump to
                tokens = tokens[1:]
            if token == ".align16" : # we move forward in the memory while the adress% 16 != 0
                while (current_address & 15) !=0:
                    code.append(0)
                    current_address += 1
                tokens = tokens[1:]
            if token == ".include" : #include another file into this one.
                filename = os.path.join("ASM",tokens[1])
                c, current_address = asm_pass(iteration, filename, current_address) # first pass essentially builds the labels
                if iteration == 2 :
                    code += c
                tokens = []

        # now we may have an instruction
        if tokens:
            machine_instr = None
            operation = tokens[0]
            arguments = tokens[1:]
            if operation == ".word":
                machine_instr = int(arguments[0], 0)
            if operation == "rmem":
                machine_instr = asm_rmem(arguments)
            elif operation == "copy":
                machine_instr = asm_rmem(arguments,copy = True)
            elif operation == "wmem" :
                machine_instr = asm_wmem(arguments)
            elif operation in ["add","sub","and","or","xor","lsl","lsr","asr"] :
                signed_constant = (arguments[2][0] != 'r') # not a register
                machine_instr = asm_three_op_instr(operation, arguments, signed_constant)
            elif operation == "snif" :
                signed_constant = (arguments[2][0] != 'r')
                machine_instr = asm_snif(arguments, signed_constant)
            elif operation == "call" :
                if iteration == 2 :
                    machine_instr = asm_call(arguments[0], current_address+begin_adress)
                else :
                    machine_instr = True # valeur bidon != None
            elif operation == "jump" :
                if iteration == 2 :
                    machine_instr = asm_jump(arguments[0],current_address)
                else :
                    machine_instr = True # valeur bidon != None
            elif operation == "return":
                machine_instr = asm_jump("1",current_address+begin_adress)
            elif operation == "letl" :
                machine_instr = asm_let(False, arguments)
            elif operation == "leth" :
                machine_instr = asm_let(True, arguments)
            
            elif operation == "let" :
                # a shortcut to set the value of a register more easily
                if arguments[1] in colors :
                    c = colors[arguments[1]] #predefined keywords for colors
                else :
                    c = int(arguments[1],0)
                a,b = str(c//(1<<8)), str(c%(1<<8))
                code.append(asm_let(False, [arguments[0], b]))
                current_address += 1
                line+=1
                machine_instr = asm_let(True, [arguments[0], a])

            elif operation =="write" :
                #another shortcut to write a pixel in the memory and increment the adress
                code.append(asm_wmem(arguments))
                current_address += 1
                line += 1
                machine_instr = asm_three_op_instr("add", [arguments[1], arguments[1], "1"], True)

            if machine_instr is not None :
                code.append(machine_instr)
                print(format(current_address, "04x") + " : " + format(machine_instr, "04x"))
                current_address += 1
            elif tokens[0][0]!=";": # ; marks a commentary in the code -> end of the line
                error("don't know what to do with: " + tokens[0])
            
        line += 1
        
    source.close()
    print("\n DONE \n")
    return code,current_address

## ------ main ------
if __name__ == '__main__':

    argparser = argparse.ArgumentParser(description='This is the assembler for the ASR2016 processor @ ENS-Lyon')
    argparser.add_argument('filename', help='name of the source file.  "python asm.py toto.s" assembles toto.s into toto.obj \n. /!\ the .s file should be in the ASM folder')

    options=argparser.parse_args()
    filename = options.filename
    filename = os.path.join("ASM",filename)
    basefilename, extension = os.path.splitext(filename)
    obj_file = os.path.split(basefilename)[-1]+".obj"
    asm_pass(1, filename) # first pass essentially builds the labels
    code = asm_pass(2, filename)[0] # second pass is for good
    outfile = open(obj_file, "w")
    for instr in code:
        outfile.write(format(instr, "04x"))
        outfile.write("\n")
    outfile.close()
