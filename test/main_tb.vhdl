library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity main_tb is
    generic (runner_cfg : string);
end entity;

architecture tb of main_tb is
    constant CLK_FREQ : integer   := 100e6; -- 100 MHz
    constant CLK_PERD : time      := 1000 ms / CLK_FREQ;

    signal clk        : std_logic := '0';
begin
    clk <= not clk after CLK_PERD / 2;

    test_runner_watchdog(runner, 10 ms);

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        if run("todo") then
            -- TODO
            assert true;
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;