library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity branch_adr_tb is
    generic (runner_cfg : string);
end entity;

architecture tb of branch_adr_tb is
    constant CLK_FREQ          : integer   := 100e6; -- 100 MHz
    constant CLK_PERD          : time      := 1000 ms / CLK_FREQ;

    signal clk                 : std_logic := '0';

    signal next_pc_adr         : std_logic_vector(31 downto 0);
    signal instr_adr           : std_logic_vector(31 downto 0);
    signal incr_pc_adr         : std_logic_vector(31 downto 0);
    signal hashed_adr          : std_logic_vector(3 downto 0);
    signal feedback_hashed_adr : std_logic_vector(3 downto 0);
    signal opcode              : std_logic_vector(3 downto 0);
    signal ccr                 : std_logic_vector(2 downto 0);

    signal if_flush            : std_logic;
    signal branch_adr_sig      : std_logic_vector(31 downto 0);
begin
    clk <= not clk after CLK_PERD / 2;

    branch_adr : entity work.branch_adr
        port map(
            next_pc_adr         => next_pc_adr,
            instr_adr           => instr_adr,
            incr_pc_adr         => incr_pc_adr,
            hashed_adr          => hashed_adr,
            feedback_hashed_adr => feedback_hashed_adr,
            opcode              => opcode,
            if_flush            => if_flush,
            branch_adr          => branch_adr_sig,
            ccr                 => ccr
        );

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);

        if run("is_opcode_branch") then
            check(is_opcode_branch(to_vec(0, 4)));
            check(is_opcode_branch(to_vec(0, 5)));
            check(not is_opcode_branch(to_vec(0, 3)));
            check(not is_opcode_branch(to_vec(1, 4)));
        end if;

        -- TODO: add tests

        wait for CLK_PERD/2;
        test_runner_cleanup(runner);
        wait;
    end process;
end architecture;