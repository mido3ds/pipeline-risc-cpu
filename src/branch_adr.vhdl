library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity branch_adr is
    port (
        next_pc_adr : in std_logic_vector(31 downto 0);
        instr_adr   : in std_logic_vector(31 downto 0);
        incr_pc_adr : in std_logic_vector(31 downto 0);
        hashed_adr  : in std_logic_vector(3 downto 0);
        opcode      : in std_logic_vector(3 downto 0);

        if_flush    : out std_logic;
        branch_adr  : out std_logic_vector(31 downto 0)
        -- hashed_adr  : out std_logic_vector(3 downto 0) TODO: why is it repeated?
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
    process (next_pc_adr, instr_adr, incr_pc_adr, hashed_adr, opcode)
    begin
        if opcode_is_branch(opcode) then
            if_flush   <= to_std_logic(next_pc_adr /= instr_adr);
            branch_adr <= instr_adr;
        else
            -- TODO: ???
        end if;
    end process;
end architecture;