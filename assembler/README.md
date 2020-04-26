# Program Assembler
The assembler source code for the provided processor ISA. 

### Team Members

| Name             | Sec | BN  |
|------------------|-----|-----|
| Mohamed Shawky   | 2   | 16  |
| Mahmoud Adas     | 2   | 21  |
| Remonda Talaat   | 1   | 20  |
| Evram Youssef    | 1   | 9   |

### Installation

* python3
* python3-pip

`$ pip3 install --user re2 argparse` 

### Usage

1. Add the program text file to `io` folder. 
2. Run the assembler program
`$ python3 assembler.py --input_file <filename> --output_file <filename>` 
3. Output HEX file is added to `io` folder. 

### Examples

An example output file is added to `io` folder. The output file `ram.hex` contains the whole layout of the ram (2^8 entries) with the corresponding HEX numbers of the provided instructions.

To replicate the results run: `$ python3 assembler.py --input_file OneOperand.asm --output_file ram.hex` 
