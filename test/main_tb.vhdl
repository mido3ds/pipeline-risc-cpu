library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity main_tb is
    generic (
        runner_cfg        : string;
        ENABLE_PLAYGROUND : boolean := false
    );
end entity;

architecture tb of main_tb is
    constant CLK_FREQ     : integer   := 100e6; -- 100 MHz
    constant CLK_PERD     : time      := 1000 ms / CLK_FREQ;

    signal clk            : std_logic := '0';

    signal rst            : std_logic;
    signal interrupt      : std_logic;
    signal hlt            : std_logic;

    signal in_value       : std_logic_vector(31 downto 0)  := "00000000000000000000000000001000";
    signal out_value      : std_logic_vector(31 downto 0);

    -- testing signals
    signal tb_controls    : std_logic;

    -- reg_file
    signal src0_adr       : std_logic_vector(3 downto 0);
    signal dst0_adr       : std_logic_vector(3 downto 0);
    signal in_dst0_value  : std_logic_vector(31 downto 0);
    signal out_src0_value : std_logic_vector(31 downto 0);

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
    signal ccr_sel        : std_logic;
    signal ccr_in         : std_logic_vector(2 downto 0);
    signal ccr_out        : std_logic_vector(2 downto 0);

    type WordArrType is array(natural range <>) of std_logic_vector(im_data_in'range);
begin
    clk <= not clk after CLK_PERD / 2;

    test_runner_watchdog(runner, 2 * 1000 * CLK_PERD);

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
            rf_tb_src0_value => out_src0_value,

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

            tb_ccr_sel       => ccr_sel,
            tb_ccr_in        => ccr_in,
            tb_ccr_out       => ccr_out
        );

    main : process
        procedure clear_signals is
        begin
            rst           <= '0';
            interrupt     <= '0';
            in_value      <= (others => '0');
            tb_controls   <= '0';
            src0_adr      <= (others => '1');
            dst0_adr      <= (others => '1');
            in_dst0_value <= (others => '0');
            im_rd         <= '0';
            im_wr         <= '0';
            im_data_in    <= (others => '0');
            im_adr        <= (others => '0');
            dm_rd         <= '0';
            dm_wr         <= '0';
            dm_data_in    <= (others => '0');
            dm_adr        <= (others => '0');
            ccr_in        <= (others => '0');
            ccr_sel       <= '0';
        end procedure;

        -- set keep_data = true to keep instr_mem and reg_file from resetting
        procedure reset_cpu(keep_data : boolean) is
        begin
            clear_signals;
            info("reset_cpu");

            if keep_data then
                tb_controls <= '1';
            end if;

            rst <= '1';
            wait until falling_edge(clk);

            clear_signals;
        end procedure;

        -- for some reason, ramdata must have 2 vectors at least
        procedure fill_instr_mem(ramdata : WordArrType) is
        begin
            clear_signals;
            info("start filling ram");

            check_equal(clk, '1', "clock should be high at beginning", warning);
            wait until clk = '1';

            tb_controls <= '1';
            for i in ramdata'range loop
                im_adr     <= to_vec(i, im_adr'length);
                im_data_in <= ramdata(i);
                im_rd      <= '0';
                im_wr      <= '1';
                wait until rising_edge(clk);
            end loop;

            info("done filling ram");
            clear_signals;
        end procedure;

        procedure fill_instr_mem_file is
            constant file_path : string := "out/instr_mem." & running_test_case & ".in";
            file file_handler  : text open read_mode is file_path;

            variable row       : line;
            variable data      : std_logic_vector(15 downto 0);
            variable i         : integer := 1;
        begin
            clear_signals;
            info("start filling instr_mem");

            check_equal(clk, '1', "clock should be high at beginning", warning);
            wait until clk = '1';

            tb_controls <= '1';
            while not endfile(file_handler) loop
                readline(file_handler, row);
                read(row, data);

                im_adr     <= to_vec(i, im_adr'length);
                im_data_in <= data;
                im_rd      <= '0';
                im_wr      <= '1';
                wait until rising_edge(clk);

                i := i + 1;
            end loop;

            info("done filling instr_mem");
            clear_signals;
        end procedure;

        -- for some reason, ramdata must have 2 vectors at least
        procedure fill_data_mem(ramdata : WordArrType) is
            variable i                      : integer := 0;
        begin
            clear_signals;
            info("start filling data_mem");

            check_equal(ramdata'length mod 2, 0, "data_mem input must be even number of data, given " & to_str(ramdata'length), failure);

            check_equal(clk, '1', "clock should be high at beginning", warning);
            wait until clk = '1';

            tb_controls <= '1';
            while i < ramdata'length loop
                dm_adr     <= to_vec(i, im_adr'length);
                dm_data_in <= ramdata(i) & ramdata(i + 1);
                dm_rd      <= '0';
                dm_wr      <= '1';
                wait until rising_edge(clk);

                i := i + 2;
            end loop;

            info("done filling data_mem");
            clear_signals;
        end procedure;

        procedure dump_data_mem is
            file file_handler : text open write_mode is "out/data_mem." & running_test_case & ".out";
            variable row      : line;
            variable i        : integer := 0;
        begin
            clear_signals;
            info("start dumping data_mem");

            tb_controls <= '1';
            while i < MEM_NUM_WORDS loop
                dm_adr <= to_vec(i, im_adr'length);
                dm_rd  <= '1';
                dm_wr  <= '0';
                wait for 1 ps;

                write(row, dm_data_out(31 downto 16));
                writeline(file_handler, row);

                write(row, dm_data_out(15 downto 0));
                writeline(file_handler, row);

                i := i + 2;
            end loop;

            info("done dumping data_mem");
            clear_signals;
        end procedure;

        procedure dump_reg_file is
            file file_handler : text open write_mode is "out/reg_file." & running_test_case & ".out";
            variable row      : line;
        begin
            clear_signals;
            info("start dumping reg_file");

            check_equal(clk, '1', "clock should be high at beginning", warning);
            wait until clk = '1';

            tb_controls <= '1';
            for i in 0 to 8 loop
                src0_adr <= to_vec(i, src0_adr'length);
                wait until rising_edge(clk);

                write(row, out_src0_value);
                writeline(file_handler, row);
            end loop;

            info("done dumping reg_file");
            clear_signals;
        end procedure;

        procedure set_ccr(ccr : std_logic_vector(2 downto 0)) is
        begin
            clear_signals;
            info("set_ccr to " & to_str(ccr));

            ccr_in  <= ccr;
            ccr_sel <= '1';
            wait for 1 fs;

            clear_signals;
        end procedure;

        procedure dump_ccr is
            file file_handler : text open write_mode is "out/ccr." & running_test_case & ".out";
            variable row      : line;
        begin
            info("dump ccr");

            write(row, ccr_out);
            writeline(file_handler, row);
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        -- `playground` test-case runs only with `playground` script
        --      `run-test` should ignore `playground` test-case
        -- `playground` test-case reads instr_mem data (created by `playground` script) at out/instr_mem.playground.in
        -- dumps final data_mem content into out/data_mem.playground.out
        -- dumps final ccr value into out/ccr.playground.out
        -- and dumps final reg_file content into out/reg_file.playground.out
        if run("playground") and ENABLE_PLAYGROUND then
            reset_cpu(keep_data => false);
            fill_instr_mem_file;
            reset_cpu(keep_data => true);

            wait until hlt = '1';

            dump_data_mem;
            dump_reg_file;
            dump_ccr;
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;