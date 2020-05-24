library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dyn_branch_pred is
    port (
        -- Reset
        rst             : in std_logic;

        -- Update predictor hash table
        prev_hashed_adr : in std_logic_vector(3 downto 0);
        -- taken or not to update FSM
        update          : in std_logic;
        -- update enable
        enable          : in std_logic;

        -- Get prediction
        cur_hashed_adr  : in std_logic_vector(3 downto 0);
        -- predict whether the branch taken or not
        taken           : out std_logic
    );
end entity;

architecture rtl of dyn_branch_pred is
begin
    -- 0.5.3 Logic
    -- Updates the FSM corresponding to the hashed address.
    -- Checks whether the OPCode is of a conditional branch instruction.
    -- Outputs the prediction bit (Taken or Not) accordingly.

    -- TODO: everything
    taken <= '0';
end architecture;