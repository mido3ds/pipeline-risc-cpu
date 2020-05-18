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
    constant CLK_FREQ     : integer   := 100e6; -- 100 MHz
    constant CLK_PERD     : time      := 1000 ms / CLK_FREQ;

    signal clk            : std_logic := '0';

    signal rst            : std_logic;
    signal interrupt      : std_logic;
    signal hlt            : std_logic;

    signal in_value       : std_logic_vector(31 downto 0);
    signal out_value      : std_logic_vector(31 downto 0);

    -- testing signals
    signal tb_controls    : std_logic;

    -- reg_file
    signal src0_adr       : std_logic_vector(3 downto 0);
    signal dst0_adr       : std_logic_vector(3 downto 0);
    signal in_dst0_value  : std_logic_vector(31 downto 0);
    signal out_dst0_value : std_logic_vector(31 downto 0);

    -- instr_mem
    signal im_rd          : std_logic;
    signal im_wr          : std_logic;
    signal im_data_in     : std_logic_vector(15 downto 0);
    signal im_adr         : std_logic_vector(31 downto 0);
    signal im_data_out    : std_logic_vector(15 downto 0);

    -- data_mem
    signal dm_rd          : std_logic;
    signal dm_wr          : std_logic;
    signal dm_data_in     : std_logic_vector(31 downto 0);
    signal dm_adr         : std_logic_vector(31 downto 0);
    signal dm_data_out    : std_logic_vector(31 downto 0);

    -- ccr
    signal ccr_in         : std_logic_vector(2 downto 0);
    signal ccr_out        : std_logic_vector(2 downto 0);
begin
    clk <= not clk after CLK_PERD / 2;

    test_runner_watchdog(runner, 10 ms);

    main_unit : entity work.main
        port map(
            clk              => clk,
            rst              => rst,
            interrupt        => interrupt,
            hlt              => hlt,

            in_value         => in_value,
            out_value        => out_value,

            -- testing signals
            tb_controls      => tb_controls,

            tb_rf_src0_adr   => src0_adr,
            tb_rf_dst0_adr   => dst0_adr,
            tb_rf_dst0_value => in_dst0_value,
            rf_tb_dst0_value => out_dst0_value,

            tb_im_rd         => im_rd,
            tb_im_wr         => im_wr,
            tb_im_data_in    => im_data_in,
            tb_im_adr        => im_adr,
            tb_im_data_out   => im_data_out,

            tb_dm_rd         => dm_rd,
            tb_dm_wr         => dm_wr,
            tb_dm_data_in    => dm_data_in,
            tb_dm_adr        => dm_adr,
            tb_dm_data_out   => dm_data_out,

            tb_ccr_in        => ccr_in,
            tb_ccr_out       => ccr_out
        );

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        -- This testcase doesnt enject any data 
        -- into memories, it expects that the memory be loaded by `integrate` script
        if run("integration") then
            -- TODO
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;