library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity alu_tb is
    generic (runner_cfg : string);
end entity;

architecture tb of alu_tb is
    constant CLK_FREQ : integer   := 100e6; -- 100 MHz
    constant CLK_PERD : time      := 1000 ms / CLK_FREQ;

    signal clk        : std_logic := '0';
    signal op         : std_logic_vector(3 downto 0);
    signal a, b       : std_logic_vector(31 downto 0);
    signal ccr        : std_logic_vector(2 downto 0);
    signal c          : std_logic_vector(31 downto 0);

    alias zero is ccr(0);
    alias neg is ccr(1);
    alias carry is ccr(2);
begin
    clk <= not clk after CLK_PERD / 2;

    alu : entity work.alu
        port map(
            op  => op,
            a   => a,
            b   => b,
            ccr_in =>(others => '1'),
            ccr => ccr,
            c   => c
        );

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        if run("ALUOP_INC") then
            op <= ALUOP_INC;

            a  <= to_vec(4, a'length);
            b  <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(4 + 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(4 + 1, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(0, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(0 + 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(0 + 1, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(1234124, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(1234124 + 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(1234124 + 1, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec('1', a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('0', c'length), "c");
            check_equal(zero, '1', "zero");
            check_equal(neg, to_std_logic(signed(to_vec('0', c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(x"FFFFFFFF", a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('0', c'length), "c");
            check_equal(zero, '1', "zero");
            check_equal(neg, '0', "neg");
            check_equal(carry, '1', "carry");
        end if;

        if run("ALUOP_DEC") then
            op <= ALUOP_DEC;

            a  <= to_vec(4, a'length);
            b  <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(4 - 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(4 - 1, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(1234124, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(1234124 - 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(1234124 - 1, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec('0', a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('1', c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec('1', c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(x"FFFFFFEF", a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(x"FFFFFFEE", c'length), "c");
            check_equal(carry, '1', "carry");
            check_equal(neg, '1', "neg");
            check_equal(zero, '0', "zero");
        end if;

        if run("ALUOP_ADD") then
            op <= ALUOP_ADD;

            a  <= to_vec(4, a'length);
            b  <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(4 + 1231, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(4 + 1231, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(0, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(0 + 1231, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(0 + 1231, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(1234124, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(1234124 + 1231, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(1234124 + 1231, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec('1', a'length);
            b <= to_vec(1, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('0', c'length), "c");
            check_equal(zero, '1', "zero");
            check_equal(neg, to_std_logic(signed(to_vec('0', c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");
        end if;

        if run("ALUOP_SUB") then
            op <= ALUOP_SUB;

            a  <= to_vec(5, a'length);
            b  <= to_vec(4, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(5 - 4, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(5 - 4, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(0, a'length);
            b <= to_vec(2, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(0 - 2, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(0 - 2, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(1231, a'length);
            b <= to_vec(2, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(1231 - 2, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(1231 - 2, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(0, a'length);
            b <= to_vec(1, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('1', c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec('1', c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(16#FFFF#, a'length);
            b <= to_vec(16#F325#, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(16#0CDA#, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, '0', "neg");
            check_equal(carry, '1', "carry");
        end if;

        if run("ALUOP_AND") then
            op <= ALUOP_AND;

            a  <= to_vec(4, a'length);
            b  <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, std_logic_vector(to_unsigned(4, c'length) and to_unsigned(1231, c'length)), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(std_logic_vector(to_unsigned(4, c'length) and to_unsigned(1231, c'length))) < 0), "neg");

            a <= to_vec(0, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, std_logic_vector(to_unsigned(0, c'length) and to_unsigned(1231, c'length)), "c");
            check_equal(zero, '1', "zero");
            check_equal(neg, to_std_logic(signed(std_logic_vector(to_unsigned(0, c'length) and to_unsigned(1231, c'length))) < 0), "neg");

            a <= to_vec(1234124, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, std_logic_vector(to_unsigned(1234124, c'length) and to_unsigned(1231, c'length)), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(std_logic_vector(to_unsigned(1234124, c'length) and to_unsigned(1231, c'length))) < 0), "neg");

            a <= to_vec('1', a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(1231, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(1231, c'length)) < 0), "neg");
        end if;

        if run("ALUOP_OR") then
            op <= ALUOP_OR;

            a  <= to_vec(4, a'length);
            b  <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, std_logic_vector(to_unsigned(4, c'length) or to_unsigned(1231, c'length)), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(std_logic_vector(to_unsigned(4, c'length) or to_unsigned(1231, c'length))) < 0), "neg");

            a <= to_vec(0, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, std_logic_vector(to_unsigned(0, c'length) or to_unsigned(1231, c'length)), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(std_logic_vector(to_unsigned(0, c'length) or to_unsigned(1231, c'length))) < 0), "neg");

            a <= to_vec(1234124, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, std_logic_vector(to_unsigned(1234124, c'length) or to_unsigned(1231, c'length)), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(std_logic_vector(to_unsigned(1234124, c'length) or to_unsigned(1231, c'length))) < 0), "neg");

            a <= to_vec('1', a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('1', c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec('1', c'length)) < 0), "neg");
        end if;

        if run("ALUOP_NOT") then
            op <= ALUOP_NOT;

            a  <= to_vec('1', a'length);
            b  <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('0', c'length), "c");
            check_equal(zero, '1', "zero");
            check_equal(neg, to_std_logic(signed(to_vec('0', c'length)) < 0), "neg");

            a <= to_vec(0, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('1', c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec('1', c'length)) < 0), "neg");

            a <= to_vec(1234124, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, not to_vec(1234124, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(not to_vec(1234124, c'length)) < 0), "neg");

            a <= to_vec(0, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(x"FFFFFFFF", c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, '1', "neg");

            a <= to_vec(16#10#, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(x"FFFFFFEF", c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, '1', "neg");
        end if;

        if run("ALUOP_SHL") then
            op <= ALUOP_SHL;

            a  <= to_vec(4, a'length);
            b  <= to_vec(1, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(4 * 2, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(4 * 2, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(0, a'length);
            b <= to_vec(3, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(0, c'length), "c");
            check_equal(zero, '1', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(0, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(1234124, a'length);
            b <= to_vec(1, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(1234124 * 2, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(1234124 * 2, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec('1', a'length);
            b <= to_vec(5, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('1', c'length - 5) & "00000", "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec('1', c'length - 5) & "00000") < 0), "neg");
            check_equal(carry, '1', "carry");
        end if;

        if run("ALUOP_SHR") then
            op <= ALUOP_SHR;

            a  <= to_vec(4, a'length);
            b  <= to_vec(1, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(2, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(2, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(0, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(0, c'length), "c");
            check_equal(zero, '1', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(0, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(1234124, a'length);
            b <= to_vec(1, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(617062, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(617062, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec('1', a'length);
            b <= to_vec(1, b'length);
            wait for CLK_PERD/2;
            check_equal(c, "0" & to_vec('1', c'length - 1), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed("0" & to_vec('1', c'length - 1)) < 0), "neg");
            check_equal(carry, '1', "carry");
        end if;

        if run("ALUOP_INC2") then
            op <= ALUOP_INC2;

            a  <= to_vec(3, a'length);
            b  <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(4 + 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(4 + 1, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(-1, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(0 + 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(0 + 1, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(1234124-1, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(1234124 + 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(1234124 + 1, c'length)) < 0), "neg");
            check_equal(carry, '0', "carry");

            a <= to_vec(-2, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec('0', c'length), "c");
            check_equal(zero, '1', "zero");
            check_equal(neg, to_std_logic(signed(to_vec('0', c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");
        end if;

        if run("ALUOP_DEC2") then
            op <= ALUOP_DEC2;

            a  <= to_vec(4+1, a'length);
            b  <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(4 - 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(4 - 1, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(0+1, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(0 - 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(0 - 1, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(1234124+1, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(1234124 - 1, c'length), "c");
            check_equal(zero, '0', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(1234124 - 1, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");

            a <= to_vec(1+1, a'length);
            b <= to_vec(1231, b'length);
            wait for CLK_PERD/2;
            check_equal(c, to_vec(0, c'length), "c");
            check_equal(zero, '1', "zero");
            check_equal(neg, to_std_logic(signed(to_vec(0, c'length)) < 0), "neg");
            check_equal(carry, '1', "carry");
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;