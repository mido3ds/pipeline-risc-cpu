library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity data_mem_tb is
    generic (runner_cfg : string);
end entity;

architecture tb of data_mem_tb is
    constant CLK_FREQ        : integer   := 100e6; -- 100 MHz
    constant CLK_PERD        : time      := 1000 ms / CLK_FREQ;

    signal clk               : std_logic := '0';

    constant ADR_LENGTH      : integer   := 11;

    signal rd, wr, rst       : std_logic;
    signal is_stack          : std_logic;
    signal data_in, data_out : std_logic_vector(MEM_WORD_LENGTH * 2 - 1 downto 0);
    signal address           : std_logic_vector(ADR_LENGTH - 1 downto 0);
begin
    clk <= not clk after CLK_PERD / 2;

    data_mem : entity work.data_mem
        generic map(ADR_LENGTH => ADR_LENGTH)
        port map(
            rd       => rd,
            wr       => wr,
            is_stack => is_stack,
            address  => address,
            clk      => clk,
            rst      => rst,
            data_in  => data_in,
            data_out => data_out
        );

    main : process
        constant input_case  : std_logic_vector(15 downto 0) := x"A59F";
        constant input_case2 : std_logic_vector(15 downto 0) := x"5fff";
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        info("reset");
        rst <= '1';
        is_stack <= '0';
        wait for 1 ps;
        rst     <= '0';
        wr      <= '0';
        rd      <= '0';
        address <= to_vec(0, address'length);
        data_in <= input_case & x"0000";

        if run("one_word") then
            wr      <= '1';
            rd      <= '0';
            address <= to_vec(0, address'length);
            data_in <= input_case & input_case2;
            wait for CLK_PERD;

            wr      <= '0';
            rd      <= '1';
            address <= to_vec(0, address'length);
            wait for CLK_PERD;
            check_equal(data_out, input_case & input_case2, "data_out is input_case");

            wr      <= '1';
            rd      <= '0';
            address <= to_vec(0, address'length);
            data_in <= input_case2 & input_case;
            wait for CLK_PERD;

            wr      <= '0';
            rd      <= '1';
            address <= to_vec(0, address'length);
            wait for CLK_PERD;
            check_equal(data_out, input_case2 & input_case, "data_out is input_case");
        end if;

        if run("two_words") then
            wr      <= '1';
            rd      <= '0';
            address <= to_vec(0, address'length);
            data_in <= input_case & input_case;
            wait for CLK_PERD;
            wr      <= '1';
            rd      <= '0';
            address <= to_vec(2, address'length);
            data_in <= input_case2 & input_case;
            wait for CLK_PERD;

            wr      <= '0';
            rd      <= '1';
            address <= to_vec(0, address'length);
            wait for CLK_PERD;
            check_equal(data_out, input_case & input_case, "data_out is input_case");
            wr      <= '0';
            rd      <= '1';
            address <= to_vec(2, address'length);
            wait for CLK_PERD;
            check_equal(data_out, input_case2 & input_case, "data_out is input_case2");
        end if;

        if run("all_zeroes") then
            info("zeroing ram");
            for i in 0 to MEM_WORD_LENGTH - 1 loop
                if i mod 2 = 0 then
                    wr      <= '1';
                    rd      <= '0';
                    address <= to_vec(i, address'length);
                    data_in <= x"0000" & x"0000";
                    wait for CLK_PERD;
                end if;
            end loop;

            info("testing all ram is zeroed");
            for i in 0 to MEM_WORD_LENGTH - 1 loop
                if i mod 2 = 0 then
                    wr      <= '0';
                    rd      <= '1';
                    address <= to_vec(i, address'length);
                    wait for CLK_PERD;
                    check_equal(data_out, std_logic_vector(to_unsigned(0, 32)), "data_out is zero");
                end if;
            end loop;
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;
