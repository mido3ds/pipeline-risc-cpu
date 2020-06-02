# Pipelined RICS Processor
Design and VHDL implementation of RISC CPU with 5-stage pipeline.

# Team #4

| Name                  | Section | B. N |
|-----------------------|---------|------|
| Evram Youssef         | 1       | 9    |
| Remonda Talaat        | 1       | 20   |
| Mahmoud Adas          | 2       | 21   |
| Mohamed Shawky        | 2       | 16   |

# Requirements

* docker `19.03.6`
* GNU bash `4.4.19(1)-release`
* gtkwave (only to view simulation output) `3.3.93`
* python3

## After Installing Docker

1. Run Docker Daemon

    `$ sudo systemctl enable --now docker`

2. To run docker without sudo (https://docs.docker.com/engine/install/linux-postinstall/):

```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
$ newgrp docker
```

# Run vunit tests

* To compile and run **all** vunit tests:

    `$ ./run-test`

* To compile and run vunit test `y.vhdl` in directory `test` :

    `$ ./run-test y`

# View waveform

* If file `y.vhdl` has test case with name `some_test_name` , you can view its waveform (after `./run-test` ) with:

    `$ ./wave y.some_test_case`

> `$ ./list-tests` lists all available test cases.

* If `y.vhdl` is not vunit test file, then type `$ ./wave y`

# View vunit logs

To view logs of test case `some_test_name` of file `y.vhdl` :

`$ ./logs y.some_test_case`

# Playground

Run any assembly you want on the cpu simulation, just give it to `playgournd` script from the stdin, and it will compile `test/main_tb.vhdl` and run the cpu till hlt (you should add 'end' instruction at the end).

`playground` script dumps the ccr, reg-file and data-mem at the end to `out/{ccr,data_mem,reg_file}.playground.out`.

`$ printf 'and r0, r1, r2 \n end' | ./playgournd`

`$ ./playgournd <input/full_test/Branch.asm`

# Assembler

`$ ./scripts/asm < /path/to/input.asm > /path/to/output.binary`

# Modelsim Folder Structure

- `modelsim_tests_do` : contains the following :

1) `cases` : the provided test cases assembly. An __END__ instruction is added to mark the end of each section, in order to end the simulation.
2) `cases_binary` : the file that contains binary code from assembler.
3) `cases_do_memory` : do files to initially load instructions in memory one by one.
4) `cases_hex` : same as `cases_binary` but in hex.
5) `cases_mem` : modelsim memory files to be loaded directly to the simulation.
6) `cases_with_NOP` : same as `cases` but with NOPs added to test disabled hazard handling.
7) `do_files` : contains do files for all provided test cases inside `MAIN` folder. However, `MAIN with NOP` folder contains do files for cases tested with NOPs.
8) `scripts` : some python scripts to automate memory loading do files.
9) `waves` : screenshots of the waves produced by all provided test cases.

# Modelsim Usage

- For using modelsim with provided test cases :

1) Copy all vhdl files to a new modelsim project and compile them.
2) Run the do file corresponding to the cases from `modelsim_tests_do/do_files/MAIN/*`.
3) You might need to change the path of the `.mem` file in do file to correspond to memory files in `modelsim_tests_do/cases_mem` or simply add `cases_mem` folder to your modelsim project.

- For using modelsim with other test cases :
1) Copy all vhdl files to a new modelsim project and compile them.
2) Create the binary file from assembler.
3) Load memory file to modelsim one by one.
4) Execute the desired do file.