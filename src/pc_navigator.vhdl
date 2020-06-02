library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity pc_navigator is
    port (

        clk                         : in  std_logic;
        int_bit_in                  : in  std_logic;
        enable                      : in  std_logic;
        opCode_in                   : in  std_logic_vector(6  downto 0);
        pc_selector                 : out std_logic
    );
end entity;

architecture rtl of pc_navigator is

begin

    process(clk)
    begin

        if rising_edge(clk) then

            if enable = '1' then

                if int_bit_in = '1' then                  -- pc store so don't active the pc selector
                    pc_selector                <= '0';

                elsif opCode_in = "0000101" then          -- rti operation so activate the pc selector and stalling enable bits
                    pc_selector                <= '1';
                elsif opCode_in = "0000100" then
                    pc_selector                <= '1';
                end if;
                    -- check depending on the opcode to enable stalling bit or no
            else
                pc_selector                    <= '0';
            end if;

        end if;

    end process;

end architecture;