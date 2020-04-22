library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity branch_addrs_tb is
    generic (runner_cfg : string);
end entity;

architecture tb of branch_addrs_tb is
    constant CLK_FREQ     : integer   := 100e6; -- 100 MHz
    constant CLK_PERD     : time      := 1000 ms / CLK_FREQ;

    signal clk            : std_logic := '0';

    signal hashed_address : std_logic_vector(3 downto 0);
    signal update         : std_logic;
    signal opcode         : std_logic_vector(3 downto 0);
    signal taken          : std_logic;
begin
    clk <= not clk after CLK_PERD / 2;

    branch_addrs : entity work.branch_addrs
        port map(
            hashed_address => hashed_address,
            update         => update,
            opcode         => opcode,
            taken          => taken
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