library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity branch_adr is
    port (
        --predicted
        next_pc_adr         : in std_logic_vector(31 downto 0);
        --from reg file
        instr_adr           : in std_logic_vector(31 downto 0);
        --pc++
        incr_pc_adr         : in std_logic_vector(31 downto 0);
        --proposed by predictor
        hashed_adr          : in std_logic_vector(3 downto 0);
        --enable this unit
        --opcode              : in std_logic_vector(6 downto 0);
        branch_enable       : in std_logic;

        --only zero flag is needed
        zero_flag           : in std_logic;

        if_flush            : out std_logic;
        branch_adr_correct  : out std_logic_vector(31 downto 0);
        feedback_hashed_adr : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of branch_adr is
begin
    -- 0.6.3 Logic
    -- Check if OpCode is of a conditional branch instruction, if true:
    --     - Check whether PC Next Address is equal to Instruction Address
    --     - If true:
    --          IF Flush = 0, Branch Address = Instruction Address
    --     - If false:
    --          IF Flush = 1, Branch Address = Instruction Address
    process (branch_enable)
    begin
        if branch_enable = '1' then
            if zero_flag = '1' then
                branch_adr_correct <= instr_adr;
                if (instr_adr = next_pc_adr) then
                    if_flush <= '0';
                else
                    if_flush <= '1';
                end if;
            else
                branch_adr_correct <= incr_pc_adr;
                if (incr_pc_adr = next_pc_adr) then
                    if_flush <= '0';
                else
                    if_flush <= '1';
                end if;
            end if;
            -----------I DON'T KNOW WHAT TO DO WITH THE HASHED ADDRESS------
            feedback_hashed_adr <= hashed_adr;
        else
            --as long as we are not involved...
            if_flush <= '0';
        end if;
    end process;
end architecture;