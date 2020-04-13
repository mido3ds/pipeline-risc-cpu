# dictionary of opcodes for all instructions
OP_CODES_TABLE = {
    "not" : "1111001",
    "inc" : "1111010",
    "dec" : "1111011",
    "out" : "1111100",
    "in" : "1111000",
    "swap" : "0001",
    "add" : "0010",
    "iadd" : "1000",
    "sub" : "0011",
    "and" : "0100",
    "or" : "0101",
    "shl" : "0110",
    "shr" : "0111",
    "push" : "1001",
    "pop" : "1010",
    "ldm" : "1011",
    "ldd" : "1100",
    "std" : "1101",
    "jz" : "0000001",
    "jmp" : "0000010",
    "call" : "0000011",
    "ret" : "0000100",
    "rti" : "0000101"
}

# instruction distribution
INST_2OP = ["swap", "add", "iadd", "sub", "and", "or", "shl", "shr"]

INST_1OP = ["not", "inc", "dec", "out", "in"]

INST_BR = ["jz", "jmp", "call", "ret", "rti"]

INST_MEM = ["push", "pop", "ldm", "ldd", "std"]

# dictionary of register indices
REGISTERS = {
    "R0": "000",
    "R1": "001",
    "R2": "010",
    "R3": "011",
    "R4": "100",
    "R5": "101",
    "R6": "110",
    "R7": "111"
}
