from common import *
from utils import *
import argparse
import re

def assemble(input_txt, output_txt):
    """
        Go through the input text, 
        assemble RAM words
        and save them to output text.
        Parameters:
        input_txt (string): name of input text.
        output_txt (string): name of outut text.
    """
    ### initialize variables
    in_file = open("io/"+input_txt, "r")
    ram_entries = dict()
    ram_div = ''

    ### loop over every line in the input program
    for line in in_file:

        ## remove comments
        com_idx = line.find("#")
        if (com_idx != -1):
            if (com_idx != 0):
                line = line[:com_idx-1]
            else:
                continue

        ## split words by delimiters        
        line_words = re.split(';|,| |\n', line)    
        line_words = [x for x in line_words if x != '']
        if (len(line_words) == 0):
            continue  

        ## parse instruction
        inst =  line_words[0].lower() 

        # check for memory organization
        if (inst == ".org"):
            ram_div = line_words[1]
            ram_entries[ram_div] = []

        # handle NOP instruction
        elif (inst == "nop"):
            ram_entries[ram_div].append("0000000000000000")

        # handle 1-operand instruction    
        elif (inst in INST_1OP):
            new_entry = OP_CODES_TABLE[inst]
            new_entry = "0" + new_entry + REGISTERS[line_words[1].upper()] + "00000"
            ram_entries[ram_div].append(new_entry)

        # handle 2-operand instruction     
        elif (inst in INST_2OP):
            new_entry = OP_CODES_TABLE[inst]
            if (inst == "swap"):
                new_entry = "0" + new_entry + REGISTERS[line_words[1].upper()] + \
                            REGISTERS[line_words[2].upper()] + "00000"
                ram_entries[ram_div].append(new_entry)            
            elif (inst in ["add", "sub", "and", "or"]):
                new_entry = "0" + new_entry + REGISTERS[line_words[1].upper()] + \
                            REGISTERS[line_words[2].upper()] + REGISTERS[line_words[3].upper()] + "00"
                ram_entries[ram_div].append(new_entry)            
            elif (inst in ["shl", "shr"]):
                new_entry = "1" + new_entry + REGISTERS[line_words[1].upper()] + bin(int(line_words[2],16))[2:][:8]
                ram_entries[ram_div].append(new_entry)
                ram_entries[ram_div].append(bin(int(line_words[2],16))[2:][8:]+"00000000")
            else:
                new_entry = "1" + new_entry + REGISTERS[line_words[1].upper()] + \
                            REGISTERS[line_words[2].upper()] + bin(int(line_words[3],16))[2:][:5]
                ram_entries[ram_div].append(new_entry)
                ram_entries[ram_div].append(bin(int(line_words[3],16))[2:][5:]+"00000") 

        # handle memory instruction   
        elif (inst in INST_MEM):
            new_entry = OP_CODES_TABLE[inst]
            if (inst in ["push", "pop"]):
                new_entry = "0" + new_entry + REGISTERS[line_words[1].upper()] + "00000000"
                ram_entries[ram_div].append(new_entry)
            elif (inst in ["ldd", "std"]):
                new_entry = "1" + new_entry + REGISTERS[line_words[1].upper()] + bin(int(line_words[2],16))[2:][:8]
                ram_entries[ram_div].append(new_entry)
                ram_entries[ram_div].append(bin(int(line_words[2],16))[2:][8:]+"0000")
            else:
                new_entry = "1" + new_entry + REGISTERS[line_words[1].upper()] + bin(int(line_words[2],16))[2:][:8]
                ram_entries[ram_div].append(new_entry)
                ram_entries[ram_div].append(bin(int(line_words[2],16))[2:][8:]+"00000000") 

        # handle branch instruction     
        elif (inst in INST_BR):
            new_entry = OP_CODES_TABLE[inst]
            if (inst in ["jz", "jmp", "call"]):
                new_entry = "0" + new_entry + REGISTERS[line_words[1].upper()] + "00000"
                ram_entries[ram_div].append(new_entry)
            else:
                new_entry = "0" + new_entry + "00000000"
                ram_entries[ram_div].append(new_entry)
                for i in range(3): # add three NOPs after RET and RTI for hazard avoidance
                    ram_entries[ram_div].append("0000000000000000")

        # handle pc addresses
        else:
            try:
                new_entry = bin(int(inst,16))[2:]
                if (len(new_entry) > 16):
                    pad_len = 32-len(new_entry)
                    split_idx = len(new_entry)-16
                    ram_entries[ram_div].append("0"*pad_len+new_entry[:split_idx])
                    ram_entries[ram_div].append(new_entry[split_idx:])
                else:
                    pad_len = 16-len(new_entry)
                    ram_entries[ram_div].append("0"*16)
                    ram_entries[ram_div].append("0"*pad_len+new_entry[:])
            except:
                continue            

    ram_layout = gen_layout(ram_entries) # generate full ram layout from processed instructions
    write_hex(ram_layout, output_txt) # write output hex files

def main():
    """
        The main driver of the assembler,
        For argument parsing.
    """
    argparser = argparse.ArgumentParser(description=__doc__)
    argparser.add_argument(
        '-if', '--input_file',
        metavar='IF',
        default='program.asm',
        help='name of input text in io directory')
    argparser.add_argument(
        '-of', '--output_file',
        metavar='OF',
        default='ram.hex',
        help='name of output text in io directory'
    )
    args = argparser.parse_args()
    assemble(args.input_file, args.output_file)

if __name__ == '__main__':
    main()
