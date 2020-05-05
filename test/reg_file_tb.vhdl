library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

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

    signal br_io_enbl  : std_logic_vector(1 downto 0);  -- STATE

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
            br_io_enbl  => br_io_enbl,
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

        rst        <= '1';
        br_io_enbl <= "00";
        wait for 1 ps;
        rst <= '0';

        if run("rst") then
            wait until rising_edge(clk);

            for i in 0 to 4 loop
                src0_adr   <= to_vec(i, src0_adr'length);
                src1_adr   <= to_vec(i + 4, src1_adr'length);
                br_io_enbl <= "00";
                wait for CLK_PERD;
                check_equal(op0_value, to_vec(0, op0_value'length));
                check_equal(op1_value, to_vec(0, op1_value'length));
            end loop;
        end if;

        if run("write_read") then
            br_io_enbl <= "00";
            for i in 0 to 4 loop
                -- write
                wb0_value <= to_vec(i, wb0_value'length);
                dst0_adr  <= to_vec(i, dst0_adr'length);

                wb1_value <= to_vec(i + 4, wb1_value'length);
                dst1_adr  <= to_vec(i + 4, dst1_adr'length);
                -- read
                src0_adr  <= to_vec(i, src0_adr'length);
                src1_adr  <= to_vec(i + 4, src1_adr'length);

                wait until falling_edge(clk);
                wait for 1 ps;

                check_equal(op0_value, to_vec(i, op0_value'length));
                check_equal(op1_value, to_vec(i + 4, op1_value'length));
            end loop;
        end if;

        if run("br") then
            info("fill regs");
            br_io_enbl <= "00";
            for i in 0 to 4 loop
                -- write
                wb0_value <= to_vec(i, wb0_value'length);
                dst0_adr  <= to_vec(i, dst0_adr'length);

                wb1_value <= to_vec(i + 4, wb1_value'length);
                dst1_adr  <= to_vec(i + 4, dst1_adr'length);
                -- read
                src0_adr  <= to_vec(i, src0_adr'length);
                src1_adr  <= to_vec(i + 4, src1_adr'length);

                wait until falling_edge(clk);
                wait for 1 ps;

                check_equal(op0_value, to_vec(i, op0_value'length));
                check_equal(op1_value, to_vec(i + 4, op1_value'length));
            end loop;

            info("check instr_adr output");
            br_io_enbl <= "11";
            for i in 0 to 8 loop
                src0_adr <= to_vec(i, src0_adr'length);
                wait for CLK_PERD;
                check_equal(instr_adr, to_vec(i, instr_adr'length));
            end loop;
        end if;

        if run("io") then
            for i in 0 to 8 loop
                -- write
                br_io_enbl <= "01";
                dst0_adr   <= to_vec(i, dst0_adr'length);
                in_value   <= to_vec(i, in_value'length);

                wait until rising_edge(clk);
                wait for 1 ps;

                -- read
                br_io_enbl <= "10";
                src0_adr   <= to_vec(i, src0_adr'length);

                wait until falling_edge(clk);
                wait for 1 ps;

                check_equal(out_value, to_vec(i, out_value'length));
            end loop;
        end if;

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;