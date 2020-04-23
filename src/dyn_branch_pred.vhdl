library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dyn_branch_pred is
    port (
        hashed_address : in std_logic_vector(3 downto 0);
        -- Taken or not to update FSM
        update         : in std_logic;
        opcode         : in std_logic_vector(3 downto 0);
        -- predict whether the branch taken or not
        taken          : out std_logic
    );
end entity;

architecture rtl of dyn_branch_pred is
begin
    -- 0.5.3 Logic
    -- Updates the FSM corresponding to the hashed address.
    -- Checks whether the OPCode is of a conditional branch instruction.
    -- Outputs the prediction bit (Taken or Not) accordingly.

    -- TODO: everything
    taken <= '1';
end architecture;