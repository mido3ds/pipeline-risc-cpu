library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.math_real.all;
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
    signal dm_is_stack    : std_logic;
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

    test_runner_watchdog(runner, 5 * 1000 * CLK_PERD);

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
            tb_dm_is_stack   => dm_is_stack,
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
            dm_is_stack   <= '0';
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

        procedure fill_data_mem(adr : integer; ramdata : WordArrType; is_stack : std_logic) is
            variable i : integer := adr;
            variable j : integer := 0;
        begin
            clear_signals;
            info("start filling data_mem");
            tb_controls <= '1';

            check_equal(ramdata'length mod 2, 0, "data_mem input must be even number of data, given " & to_str(ramdata'length), failure);
            check_equal(adr mod 2, 0, "addr must be even number", failure);

            if clk /= '1' then
                warning("clock should be high at beginning");
                wait until clk = '1';
            end if;

            while j < ramdata'length loop
                dm_adr      <= to_vec(i, im_adr'length);
                dm_data_in  <= ramdata(j) & ramdata(j + 1);
                dm_rd       <= '0';
                dm_wr       <= '1';
                dm_is_stack <= is_stack;
                wait until rising_edge(clk);

                i := (i + 2) when is_stack = '0' else (i - 2);
                j := j + 2;
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

            check_equal(out_src0_value, expected, "test_reg failed, adr=" & to_str(adr));
            clear_signals;
        end procedure;

        procedure test_data_mem(adr : integer; expected : std_logic_vector(15 downto 0); is_stack : std_logic) is
        begin
            clear_signals;
            tb_controls <= '1';

            if adr mod 2 = 0 then
                dm_adr <= to_vec(adr, im_adr'length);
            else
                dm_adr <= to_vec(adr - 1, im_adr'length) when is_stack = '0' else to_vec(adr + 1, im_adr'length);
            end if;
            dm_rd       <= '1';
            dm_wr       <= '0';
            dm_is_stack <= is_stack;
            wait for 1 ps;

            if adr mod 2 = 0 then
                check_equal(dm_data_out(31 downto 16), expected, "test_data_mem failed");
            else
                check_equal(dm_data_out(15 downto 0), expected, "test_data_mem failed");
            end if;

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
                dm_adr      <= to_vec(i, im_adr'length);
                dm_rd       <= '1';
                dm_wr       <= '0';
                dm_is_stack <= '0';
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
            --$ printf '2\n.org 2
            --$ not r0
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0111100100000000"),
            to_vec("0111000000000000")
            ));

            reset_cpu;
            wait until hlt = '1';

            test_reg(0, to_vec('1', 32));
            check_equal(ccr_out(CCR_ZERO), '0', "ccr(zero)");
            check_equal(ccr_out(CCR_NEG), '1', "ccr(neg)");
        end if;

        if run("inc_r1") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ inc r1
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0111101000100000"),
            to_vec("0111000000000000")
            ));
            set_reg(1, to_vec(5, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(1, to_vec(6, 32));
            check_equal(ccr_out(CCR_ZERO), '0', "ccr(zero)");
            check_equal(ccr_out(CCR_NEG), '0', "ccr(neg)");
        end if;

        if run("dec_r2") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ dec r2
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0111101101000000"),
            to_vec("0111000000000000")
            ));
            set_reg(2, to_vec(200, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec(199, 32));
            check_equal(ccr_out(CCR_ZERO), '0', "ccr(zero)");
            check_equal(ccr_out(CCR_NEG), '0', "ccr(neg)");
        end if;

        if run("in_r3") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ in r3
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0111100001100000"),
            to_vec("0111000000000000")
            ));
            for i in 0 to 7 loop
                set_reg(i, to_vec(-1, 32));
            end loop;
            in_value <= to_vec(50, in_value'length);

            reset_cpu;
            wait until hlt = '1';

            for i in 0 to 7 loop
                if i = 3 then
                    test_reg(3, to_vec(50, 32));
                else
                    test_reg(i, to_vec(-1, 32));
                end if;
            end loop;
        end if;

        if run("out_r4") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ out r4
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0111110010000000"),
            to_vec("0111000000000000")
            ));
            set_reg(4, to_vec(12, 32));

            reset_cpu;
            wait until hlt = '1';

            check_equal(out_value, to_vec(12, out_value'length));
        end if;

        if run("swap_r0_r1") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ swap r0, r1
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0000100000100000"),
            to_vec("0111000000000000")
            ));
            set_reg(0, to_vec(12, 32));
            set_reg(1, to_vec(100, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(1, to_vec(12, 32));
            test_reg(0, to_vec(100, 32));
        end if;

        if run("add_r1_r2_r3") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ add r1, r2, r3
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0001000101001100"),
            to_vec("0111000000000000")
            ));
            set_reg(1, to_vec(12, 32));
            set_reg(2, to_vec(-100, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(3, to_vec(-88, 32));
            check_equal(ccr_out(CCR_ZERO), '0', "ccr(zero)");
            check_equal(ccr_out(CCR_NEG), '1', "ccr(neg)");
        end if;

        if run("sub_r2_r3_r4") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ sub r2, r3, r4
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0001101001110000"),
            to_vec("0111000000000000")
            ));
            set_reg(2, to_vec(12, 32));
            set_reg(3, to_vec(12, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(4, to_vec(0, 32));
            check_equal(ccr_out(CCR_ZERO), '1', "ccr(zero)");
            check_equal(ccr_out(CCR_NEG), '0', "ccr(neg)");
        end if;

        if run("and_r3_r4_r5") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ and r3, r4, r5
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0010001110010100"),
            to_vec("0111000000000000")
            ));
            set_reg(3, to_vec(X"0F0F0F0F", 32));
            set_reg(4, to_vec(X"0F00000F", 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(5, to_vec(X"0F00000F", 32));
            check_equal(ccr_out(CCR_ZERO), '0', "ccr(zero)");
            check_equal(ccr_out(CCR_NEG), '0', "ccr(neg)");
        end if;

        if run("or_r3_r4_r5") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ or r3, r4, r5
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0010101110010100"),
            to_vec("0111000000000000")
            ));
            set_reg(3, to_vec(X"0F0F0F0F", 32));
            set_reg(4, to_vec(X"FFF0000F", 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(5, to_vec(X"FFFF0F0F", 32));
            check_equal(ccr_out(CCR_ZERO), '0', "ccr(zero)");
            check_equal(ccr_out(CCR_NEG), '1', "ccr(neg)");
        end if;

        if run("shl_r7_1") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ shl r7, 2
            --$ end' | ./scripts/asm | head -n$((2+3))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("1011011100000000"),
            to_vec("0000001000000000"),
            to_vec("0111000000000000")
            ));
            set_reg(7, to_vec(X"40000000", 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(7, to_vec(0, 32));
            check_equal(ccr_out(CCR_CARRY), '1', "ccr(carry)");
        end if;

        if run("shr_r0_2") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ shr r0, 1
            --$ end' | ./scripts/asm | head -n$((2+3))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("1011100000000000"),
            to_vec("0000000100000000"),
            to_vec("0111000000000000")
            ));
            set_reg(0, to_vec(X"00000002", 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(0, to_vec(1, 32));
        end if;

        if run("push_r0") then
            reset_all;
            test_reg(8, to_vec(2 ** 11 - 2, 32));

            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ push r0
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0100100000000000"),
            to_vec("0111000000000000")
            ));
            set_reg(0, to_vec(100, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(8, to_vec(2 ** 11 - 4, 32));
            test_data_mem(2 ** 11 - 2, to_vec(0, 16), '1');
            test_data_mem(2 ** 11 - 3, to_vec(100, 16), '1');
        end if;

        if run("pop_r1") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ pop r1
            --$ end' | ./scripts/asm | head -n$((2+2))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0101000100000000"),
            to_vec("0111000000000000")
            ));
            set_reg(8, to_vec(2, 32));
            fill_data_mem(4, (to_vec(0, 16), to_vec(100, 16)), '1');

            reset_cpu;
            wait until hlt = '1';

            test_reg(8, to_vec(4, 32));
            test_reg(1, to_vec(100, 32));
        end if;

        if run("ldm_r2_50") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ ldm r2, 50
            --$ end' | ./scripts/asm | head -n$((2+3))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("1101101000000000"),
            to_vec("0101000000000000"),
            to_vec("0111000000000000")
            ));

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec(16#50#, 32));
        end if;

        if run("ldd_r3_20") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ ldd r3, 20
            --$ end' | ./scripts/asm | head -n$((2+3))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("1110001100000000"),
            to_vec("0000001000000000"),
            to_vec("0111000000000000")
            ));
            fill_data_mem(16#20#, (to_vec(0, 16), to_vec(14, 16)), '0');

            reset_cpu;
            wait until hlt = '1';

            test_reg(3, to_vec(0, 16) & to_vec(14, 16));
        end if;

        if run("std_r4_36") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ std r4, 36
            --$ end' | ./scripts/asm | head -n$((2+3))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("1110110000000000"),
            to_vec("0000001101100000"),
            to_vec("0111000000000000")
            ));
            set_reg(4, to_vec(14, 32));

            reset_cpu;
            wait until hlt = '1';

            test_data_mem(16#36#, to_vec(0, 16), '0');
            test_data_mem(16#37#, to_vec(14, 16), '0');
        end if;

        if run("jz_r0_true") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ jz r0 # r0=7, ccr(zero) = 1
            --$ ldm r2, 50
            --$ end
            --$ .org 7
            --$ not r2
            --$ end' | ./scripts/asm | head -n$((2+10))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0000000000000000"),
            to_vec("0000000100000000"),
            to_vec("1101101000000000"),
            to_vec("0101000000000000"),
            to_vec("0111000000000000"),
            to_vec("0000000000000000"),
            to_vec("0000000000000000"),
            to_vec("0111100101000000"),
            to_vec("0111000000000000")
            ));
            set_ccr((CCR_ZERO => '1', others => '0'));
            set_reg(0, to_vec(7, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec('1', 32));
        end if;

        if run("jz_r0_false") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ jz r0 # r0=7, ccr(zero) = 0
            --$ ldm r2, 50
            --$ end
            --$ .org 7
            --$ not r2
            --$ end' | ./scripts/asm | head -n$((2+7))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0000000000000000"),
            to_vec("0000000100000000"),
            to_vec("1101101000000000"),
            to_vec("0101000000000000"),
            to_vec("0111000000000000"),
            to_vec("0111100101000000"),
            to_vec("0111000000000000")
            ));
            set_ccr((CCR_ZERO => '0', others => '0'));
            set_reg(0, to_vec(7, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec(16#50#, 32));
        end if;

        if run("jmp_r3") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ jmp r3 # r3=7
            --$ ldm r2, 50
            --$ end
            --$ .org 7
            --$ not r2
            --$ end' | ./scripts/asm | head -n$((2+9))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0000001001100000"),
            to_vec("1101101000000000"),
            to_vec("0101000000000000"),
            to_vec("0111000000000000"),
            to_vec("0000000000000000"),
            to_vec("0111100101000000"),
            to_vec("0111000000000000")
            ));
            set_reg(3, to_vec(7, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec('1', 32));
        end if;

        if run("call_r4") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ call r4 # r4=7
            --$ ldm r2, 50
            --$ end
            --$ .org 7
            --$ not r2
            --$ end' | ./scripts/asm | head -n$((2+9))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0000001110000000"),
            to_vec("1101101000000000"),
            to_vec("0101000000000000"),
            to_vec("0111000000000000"),
            to_vec("0000000000000000"),
            to_vec("0111100101000000"),
            to_vec("0111000000000000")
            ));
            set_reg(4, to_vec(7, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec('1', 32));
            test_reg(8, to_vec(2 ** 11 - 4, 32));
            test_data_mem(2 ** 11 - 2, to_vec(0, 16), '1');
            test_data_mem(2 ** 11 - 3, to_vec(3, 16), '1');
        end if;

        if run("ret_r4") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ ret # sp=2, M[1]=0, M[2]=5
            --$ end
            --$ .org 5
            --$ not r2
            --$ end' | ./scripts/asm | head -n$((2+5))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0000010000000000"),
            to_vec("0000000000000000"),
            to_vec("0000000000000000"),
            to_vec("0111100101000000"),
            to_vec("0111000000000000")
            ));
            set_reg(8, to_vec(2, 32));
            fill_data_mem(2, (
            to_vec(5, 16),
            to_vec(0, 16)
            ), '1');

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec('1', 32));
        end if;

        if run("call_r4_ret") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ call r4 # r4=7
            --$ ldm r2, 50
            --$ end
            --$ .org 7
            --$ not r2
            --$ ret
            --$ end' | ./scripts/asm | head -n$((2+7))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0000001110000000"),
            to_vec("1101101000000000"),
            to_vec("0101000000000000"),
            to_vec("0111000000000000"),
            to_vec("0000000000000000"),
            to_vec("0111100101000000"),
            to_vec("0000010000000000")
            ));
            set_reg(4, to_vec(7, 32));

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec(16#50#, 32));
            test_reg(8, to_vec(2 ** 11 - 2, 32));
            test_data_mem(2 ** 11 - 2, to_vec(0, 16), '1');
            test_data_mem(2 ** 11 - 3, to_vec(3, 16), '1');
        end if;

        if run("reset") then
            reset_all;
            fill_instr_mem((
            --$ printf '6
            --$ end
            --$ .org 6
            --$ not r2
            --$ end' | ./scripts/asm | head -n8
            to_vec("0000000000000000"),
            to_vec("0000000000000110"),
            to_vec("0111000000000000"),
            to_vec("0000000000000000"),
            to_vec("0000000000000000"),
            to_vec("0000000000000000"),
            to_vec("0111100101000000"),
            to_vec("0111000000000000")
            ));

            reset_cpu;
            wait until hlt = '1';

            test_reg(2, to_vec('1', 32));
        end if;

        if run("interrupt_before_end") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 0 2
            --$ .org 2 6
            --$ .org 4
            --$ end # interrupt before this, M[2:3] = 3
            --$ .org 6 
            --$ not r0
            --$ end' | ./scripts/asm | head -n$((2+3))
            to_vec("0000000000000000"),
            to_vec("0000000000000100"),
            to_vec("0000000000000000"),
            to_vec("0000000000000110"),
            to_vec("0111000000000000"),
            to_vec("0000000000000000"),
            to_vec("0111100100000000"),
            to_vec("0111000000000000")
            ));
            set_ccr("101");

            reset_cpu;
            interrupt <= '1';
            wait for CLK_PERD;
            interrupt <= '0';
            wait until hlt = '1';

            test_reg(0, to_vec('1', 32));
            test_reg(8, to_vec(2 ** 11 - 6, 32));
            test_data_mem(2 ** 11 - 2, to_vec(0, 16 - 3) & "101", '1'); -- stored flags ccr
        end if;

        if run("interrupt_after_end") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 0 2
            --$ .org 2 6
            --$ .org 4
            --$ end # interrupt before this, M[2:3] = 3
            --$ .org 6 
            --$ not r0
            --$ end' | ./scripts/asm | head -n$((2+3))
            to_vec("0000000000000000"),
            to_vec("0000000000000100"),
            to_vec("0000000000000000"),
            to_vec("0000000000000110"),
            to_vec("0111000000000000"),
            to_vec("0000000000000000"),
            to_vec("0111100100000000"),
            to_vec("0111000000000000")
            ));

            reset_cpu;
            wait for CLK_PERD;
            interrupt <= '1';
            wait for CLK_PERD;
            interrupt <= '0';
            wait until hlt = '1';

            test_reg(0, to_vec(0, 32));
        end if;

        if run("rti") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 2
            --$ rti # m[2^11-2] = 010, m[2^11-4] = 5, sp = 2^11-6
            --$ end
            --$ .org 5
            --$ not r0
            --$ end' | ./scripts/asm | head -n$((2+5))
            to_vec("0000000000000000"),
            to_vec("0000000000000010"),
            to_vec("0000010100000000"),
            to_vec("0000000000000000"),
            to_vec("0000000000000000"),
            to_vec("0111100100000000"),
            to_vec("0111000000000000")
            ));
            set_reg(8, to_vec(2 ** 11 - 6, 32));
            fill_data_mem(2 ** 11 - 2, (
            to_vec(5, 16),                     -- 2^11-5
            to_vec(0, 16),                     -- 2^11-4
            to_vec(to_vec(0, 16 - 3) & "010"), -- 2^11-3
            to_vec(0, 16)                      -- 2^11-2
            ), '1');

            reset_cpu;
            wait until hlt = '1';

            test_reg(0, to_vec('1', 32));
            check_equal(ccr_out, to_vec("010", 3), "ccr");
        end if;

        if run("interrupt_rti") then
            reset_all;
            fill_instr_mem((
            --$ printf '2\n.org 0 2
            --$ .org 2 6
            --$ .org 4
            --$ not r1
            --$ end # interrupt before this, M[2:3] = 3
            --$ .org 6 
            --$ not r0
            --$ rti' | ./scripts/asm | head -n$((2+3))
            to_vec("0000000000000000"),
            to_vec("0000000000000100"),
            to_vec("0000000000000000"),
            to_vec("0000000000000110"),
            to_vec("0111100100100000"),
            to_vec("0111000000000000"),
            to_vec("0111100100000000"),
            to_vec("0000010100000000")
            ));
            set_ccr("101");

            reset_cpu;
            interrupt <= '1';
            wait for CLK_PERD;
            interrupt <= '0';
            wait until hlt = '1';

            test_reg(0, to_vec('1', 32));
            test_reg(1, to_vec('1', 32));
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
            wait for 3*CLK_PERD;
            in_value <= "00001100110110101111111000011001";
            wait for CLK_PERD;
            in_value <= "00000000000000001111111111111111";
            wait for CLK_PERD;
            in_value <= "00000000000000001111001100100000";
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
