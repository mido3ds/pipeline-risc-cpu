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
