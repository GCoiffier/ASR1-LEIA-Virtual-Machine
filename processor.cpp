/*
  processor.cpp du cours ASR1 2016
	Copyright (c) Florent de Dinechin / ENS-Lyon, 2016
	This file is distributed under the terms of the GPL V3 license
*/
#include <iostream>
#include <iomanip>
#include "processor.hpp"
#include "display.hpp"
#include "sign_extension.cpp"
using namespace std;


processor::processor(word* memory_) {
	// The memory is allocated outside of the processor class,
	// so that it can be pre-filled.
	memory = memory_;
	// Otherwise all the registers must be initialized to 0.
	pc=0;
	for(int i=0; i<16; i++)
		r[i]=0;
}



void processor::illegal_instruction(word address, word instruction) {
	cout << "Illegal instruction: " << hex << instruction
			 << " at address " << hex << address << endl;
}



void processor::step() {
	word instruction = memory[pc];
	int current_pc = pc;
	pc++ ; // Remember in the following that we already increased the PC

	// code op:
	word op = instruction >> 12;

	// number of destination register, when it is on 3 bits:
	word d3 = (instruction >> 8) & 0x7; 

	// number of destination register, when it is on 4 bits:
	word d4 = (instruction >> 8) & 0xf;

	// value of 11th bit (constant or register)
	word bit11 = (instruction >> 11) & 1;

	// number of first operand register
	word i = (instruction >> 4) & 0xf;

	// number of second operand: register or constant 
	word j = (instruction >> 0) & 0xf;

	// the 8 bit constant used in some instructions
	word b = (i<<4)+j;

	// the 12 bit constant used in some instructions
	word c = instruction & 0xfff;

	// sign-extended constant on 16 bits
	word j_signed = sign_extension_twos_comp(j,4,16);


	/* operand 2 is sometimes a register (if bit11 = 0), sometimes an 
		immediate constant (bit11 = 1) which can be sign-extended */
	word value = value_function_of_bit11(bit11, j, r);

	int n = 4; // for two's complement conversion
//#if 0
	if(verbose)
		cout << "pc=" << current_pc << "  instr: " << hex << instruction
				 << "   code_op=" << op
				 << " d3=" << d3
				 << " d4=" << d4
				 << " bit11=" << bit11
				 << " i=" << i
				 << " j=" << j
				 << " j_signed=" << j_signed << " (" << dec << (int16_t) j_signed << ")" << endl;
//#endif
	switch(op) {


	case 0: {// wmem
		if (verbose) {
			cout << "Instruction : wmem" << endl;
		}
		if(d4!=0) {
			illegal_instruction(current_pc, instruction);
		}
		else {
			memory[ r[j] ]  = r[i];
			if ((r[j] >= STARTVIDEOMEM)) //   && (r[j] <= ENDVIDEOMEM) ) always true
				display_needs_refresh = true; // it is reset by refresh()
		}
		break;
	}


	case 1: { // add
		if (verbose) {
			cout << "Instruction : add" << endl;
		}
		r[d3] = (r[i] + value)%(1<<16);
		break;
	}


	case 2: { // sub
		if (verbose) {
			cout << "Instruction : sub" << endl;
		}
		r[d3] = r[i] - value;
		break;
	}


	case 3: { // snif
		switch(d3) {

			case 0 : { //eq
				if (verbose) {
				cout << "Snif with condition eq : " << (r[i] == value) << endl;
				}
				if (r[i] == value) {
					pc++;
				}
				break;
			}

			case 1 : { // neq
				if (verbose) {
				cout << "Snif with condition neq : " << (r[i] != value) << endl;
				}
				if (r[i] != value) {
					pc++;
				}
				break;
			}

			case 2 : { // sgt
				if (bit11 == 0) {
					n=16;
				}
				if (verbose) {
					cout << "Snif with condition sgt : " << (twos_comp_to_int(r[i],16) > twos_comp_to_int(value, n)) << endl;
				}
				if (twos_comp_to_int(r[i],16) > twos_comp_to_int(value, n)) {
					pc++;
				}
				break;
			}

			case 3 : { // slt (ça va bien ?)
				if (bit11 == 0) {
					n=16;
				}
				if (verbose) {
					cout << "Snif with condition slt : " << (twos_comp_to_int(r[i],16) < twos_comp_to_int(value, n)) << endl;
				}
				if (twos_comp_to_int(r[i],16) < twos_comp_to_int(value, n)) {
					pc++;
				}
				break;
			}

			case 4 : { // gt
				if (verbose) {
					cout << "Snif with condition gt : " << (r[i] > value) << endl;
				}
				if (r[i] > value) {
					pc++;
				}	
				break;
			}

			case 5 : { // ge
				if (verbose) {
					cout << "Snif with condition ge : " << (r[i] >= value) << endl;
				}
				if (r[i] >= value) {
					pc++;
				}
				break;
			}

			case 6 : { // lt
				if (verbose) {
					cout << "Snif with condition  lt : " << (r[i] < value) << endl;
				}
				if (r[i] < value) {
					pc++;
				}
				break;
			}

			case 7 : { // le
				if (verbose) {
					cout << "Snif with condition le : " << (r[i] <= value) << endl;
				}
				if (r[i] <= value) {
					pc++;
				}
				break;
			}

			default : {
				break;
			}
		}
		break;
	}


	case 4: { // and
		if (verbose) {
			cout << "Instruction : and : " << (r[i] & j_signed) << endl;
		}	
		if (bit11 == 1) {
			r[d3] = (r[i] & j_signed);
		} else {
			r[d3] = (r[i] & r[j]);
		}
		break;
	}


	case 5: { // or
		if (verbose) {
			cout << "Instruction : or" << endl;
		}
		if (bit11 == 1) {
			r[d3] = (r[i] || j_signed);
		} else {
			r[d3] = (r[i] || r[j]);
		}
		break;
	}

	case 6: // xor
		if (verbose) {
			cout << "Instruction : xor" << endl;
		}
		if (bit11 == 1) {
			r[d3] = ((r[i] && !j_signed) || (!r[i] && j_signed));
		} else {
			r[d3] = ((r[i] && !r[j]) || (!r[i] && r[j]));
		}
		break;


	case 7: // lsl
		if (verbose) {
			cout << "Instruction : lsl" << endl;
		}
			r[d3] = r[i] << value;
		break;


	case 8: // lsr
		if (verbose) {
			cout << "Instruction : lsr" << endl;
		}
			r[d3] = r[i] >> value;
		break;


	case 9: // asr
		if (verbose) {
			cout << "Instruction : asr" << endl;
		}
			if ((r[i]>>15) == 0) {
				r[d3] = r[i] >> value;
			} else {
				r[d3] = sign_extension_twos_comp((r[i]>>value), (16-value), 16);
			}
		break;


	case 10: // call
		if (verbose) {
			cout << "Instruction : call" << endl;
		}
		r[15] = pc;
		pc = c*16;
		break;


	case 11: // jump / return
		if (twos_comp_to_int(c, 12) == 1) {
			if (verbose) {
				cout << "Instruction : return " << endl;
			}
			pc = r[15];
		}
		else {
			// jump
			if (verbose) {
				cout << "Instruction : jump : " << twos_comp_to_int(c, 12) << endl;
			}
			pc += (twos_comp_to_int(c, 12)-1); // We incremented the pc at first so -1 to compensate
		}
		break;


	case 12: // letl
		if (verbose) {
			cout << "Instruction : letl" << endl;
		}
			r[d4] = sign_extension_twos_comp(b, 8, 16);
		break;


	case 13: // leth
		if (verbose) {
			cout << "Instruction : leth" << endl;
		}
			r[d4] = (r[d4] & 0x00ff) + (b<<8);
		break;


	case 15: // rmem / copy
		switch (i) {
		
		case 0 : // rmem
			if (verbose) {
				cout << "Instruction : rmem" << endl;
			}
			r[d4] = memory[ r[j] ];
			if ((r[j] >= STARTVIDEOMEM)) //   && (r[j] <= ENDVIDEOMEM) ) always true
				display_needs_refresh = true; // it is reset by refresh()
			break;

		case 1 : // copy
			if (verbose) {
				cout << "Instruction : copy" << endl;
			}
			r[d4] = r[j];
			break;

		default :
			illegal_instruction(current_pc, instruction);
		}
		break;


	default:
		illegal_instruction(current_pc, instruction);
		break;
	}

	
	if(verbose) {
		cout << "after instr:" << hex << setw(4) << setfill('0') << instruction
				 << " at pc=" << hex << setw(4) << setfill('0') << current_pc
				 << " newpc=" << hex << setw(4) << setfill('0') << pc;
		for (int i=0; i<16; i++)
			cout << " r"<< dec << i << "=" << hex << setw(4) << setfill('0') << r[i];
		cout << endl;
	}
	
}
