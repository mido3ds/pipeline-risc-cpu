library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity reg_file_tb is
    generic (runner_cfg : string);
end entity;

architecture tb of reg_file_tb is
    constant CLK_FREQ  : integer   := 100e6; -- 100 MHz
    constant CLK_PERD  : time      := 1000 ms / CLK_FREQ;

    signal clk         : std_logic := '0';

    signal dst0_adr    : std_logic_vector(3 downto 0); -- DST
    signal dst1_adr    : std_logic_vector(3 downto 0);
    signal src0_adr    : std_logic_vector(3 downto 0); -- SRC
    signal src1_adr    : std_logic_vector(3 downto 0);
    signal fetch_adr   : std_logic_vector(3 downto 0);  -- FETCH

    signal wb0_value   : std_logic_vector(31 downto 0); -- WB
    signal wb1_value   : std_logic_vector(31 downto 0);

    signal in_value    : std_logic_vector(31 downto 0); -- IO

    signal rst         : std_logic;

    signal br_io_nop   : std_logic_vector(1 downto 0);  -- STATE

    signal op0_value   : std_logic_vector(31 downto 0); -- OP
    signal op1_value   : std_logic_vector(31 downto 0);

    signal fetch_value : std_logic_vector(31 downto 0);
    signal instr_adr   : std_logic_vector(31 downto 0);

    signal out_value   : std_logic_vector(31 downto 0); -- IO
begin
    clk <= not clk after CLK_PERD / 2;

    reg_file : entity work.reg_file
        port map(
            clk         => clk,
            dst0_adr    => dst0_adr,
            dst1_adr    => dst1_adr,
            src0_adr    => src0_adr,
            src1_adr    => src1_adr,
            fetch_adr   => fetch_adr,
            wb0_value   => wb0_value,
            wb1_value   => wb1_value,
            in_value    => in_value,
            rst         => rst,
            br_io_nop   => br_io_nop,
            op0_value   => op0_value,
            op1_value   => op1_value,
            fetch_value => fetch_value,
            instr_adr   => instr_adr,
            out_value   => out_value
        );

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        if run("name_this_test_case") then
            -- TODO
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;