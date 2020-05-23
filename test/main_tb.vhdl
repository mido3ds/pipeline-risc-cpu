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

    signal in_value       : std_logic_vector(31 downto 0) := "00000000000000000000000000001000";
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

        -- keep instr_mem and reg_file from resetting
        procedure reset_cpu is
        begin
            clear_signals;
            info("reset_cpu");

            tb_controls <= '1';
            rst         <= '1';
            wait until falling_edge(clk);

            clear_signals;
        end procedure;

        procedure reset_all is
        begin
            clear_signals;
            info("reset_all");

            rst <= '1';
            wait until falling_edge(clk);

            clear_signals;
        end procedure;

        -- for some reason, ramdata must have 2 vectors at least
        procedure fill_instr_mem(ramdata : WordArrType) is
        begin
            clear_signals;
            info("start filling ram");
            tb_controls <= '1';

            if clk /= '1' then
                warning("clock should be high at beginning");
                wait until clk = '1';
            end if;

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
            variable i         : integer := 0;
        begin
            clear_signals;
            info("start filling instr_mem");
            tb_controls <= '1';

            if clk /= '1' then
                warning("clock should be high at beginning");
                wait until clk = '1';
            end if;

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
            tb_controls <= '1';

            check_equal(ramdata'length mod 2, 0, "data_mem input must be even number of data, given " & to_str(ramdata'length), failure);

            if clk /= '1' then
                warning("clock should be high at beginning");
                wait until clk = '1';
            end if;

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

        procedure test_reg(adr : integer; expected : std_logic_vector(out_src0_value'range)) is
        begin
            clear_signals;
            tb_controls <= '1';

            if clk /= '1' then
                warning("clock should be high at beginning");
                wait until clk = '1';
            end if;

            src0_adr <= to_vec(adr, src0_adr'length);
            wait until rising_edge(clk);

            check_equal(out_src0_value, expected, "test_reg failed");
            clear_signals;
        end procedure;

        procedure set_reg(adr : integer; value : std_logic_vector(in_dst0_value'range)) is
        begin
            clear_signals;
            tb_controls <= '1';

            if clk /= '0' then
                warning("clock should be low at beginning");
                wait until clk = '0';
            end if;

            dst0_adr      <= to_vec(adr, src0_adr'length);
            in_dst0_value <= value;
            wait until falling_edge(clk);

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
            tb_controls <= '1';

            if clk /= '1' then
                warning("clock should be high at beginning");
                wait until clk = '1';
            end if;

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

        if run("not_r0") then
            reset_all;
            fill_instr_mem((
            --$ printf 'not r0 \n end' | ./scripts/asm | head -n2
            to_vec("0111100100000000"),
            to_vec("0111000000000000")
            ));

            reset_cpu;
            wait until hlt = '1';

            test_reg(0, to_vec('1', out_src0_value'length));
        end if;

        if run("inc_r1") then
            reset_all;
            fill_instr_mem((
            --$ printf 'inc r1 \n end' | ./scripts/asm | head -n2
            to_vec("0111101000100000"),
            to_vec("0111000000000000")
            ));
            set_reg(1, to_vec(5, out_src0_value'length));

            reset_cpu;
            wait until hlt = '1';

            test_reg(1, to_vec(6, out_src0_value'length));
        end if;

        if run("dec_r2") then
            reset_all;
            fill_instr_mem((
            --$ printf 'dec r2 \n end' | ./scripts/asm | head -n2
            to_vec("0111101101000000"),
            to_vec("0111000000000000")
            ));
            set_reg(2, to_vec(200, out_src0_value'length));

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec(199, out_src0_value'length));
        end if;

        if run("in_r3") then
            reset_all;
            fill_instr_mem((
            --$ printf 'in r3 \n end' | ./scripts/asm | head -n2
            to_vec("0111100001100000"),
            to_vec("0111000000000000")
            ));
            for i in 0 to 8 loop
                set_reg(i, to_vec(-1, out_src0_value'length));
            end loop;
            in_value <= to_vec(50, in_value'length);

            reset_cpu;
            wait until hlt = '1';

            for i in 0 to 8 loop
                if i = 3 then
                    test_reg(3, to_vec(50, out_src0_value'length));
                else
                    test_reg(i, to_vec(-1, out_src0_value'length));
                end if;
            end loop;
        end if;

        if run("out_r4") then
            reset_all;
            fill_instr_mem((
            --$ printf 'out r4 \n end' | ./scripts/asm | head -n2
            to_vec("0111110010000000"),
            to_vec("0111000000000000")
            ));
            set_reg(4, to_vec(12, out_src0_value'length));

            reset_cpu;
            wait until hlt = '1';

            test_reg(4, to_vec(12, out_src0_value'length));
        end if;

        -- `playground` test-case runs only with `playground` script
        --      `run-test` should ignore `playground` test-case
        -- `playground` test-case reads instr_mem data (created by `playground` script) at out/instr_mem.playground.in
        -- dumps final data_mem content into out/data_mem.playground.out
        -- dumps final ccr value into out/ccr.playground.out
        -- and dumps final reg_file content into out/reg_file.playground.out
        if run("playground") then
            -- vunit: .playground
            reset_all;
            fill_instr_mem_file;

            reset_cpu;
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