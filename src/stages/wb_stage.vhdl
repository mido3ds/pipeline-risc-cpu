library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity wb_stage is
    port (

        clk                         : in  std_logic;
        rst                         : in  std_logic;
        memory_output               : in  std_logic_vector(31 downto 0);
        alu_output                  : in  std_logic_vector(31 downto 0);
        destination_register_1      : in  std_logic_vector(3  downto 0);
        destination_register_2      : in  std_logic_vector(3  downto 0);

        -- for swap case
        destination_reg_1_val       : in  std_logic_vector(31 downto 0);
        destination_reg_2_val       : in  std_logic_vector(31 downto 0);

        opCode                      : in  std_logic_vector(6  downto 0);

        --int_bit_in                  : in  std_logic;

        dest_reg_1                  : out std_logic_vector(3  downto 0);
        dest_reg_2                  : out std_logic_vector(3  downto 0);

        dest_reg_1_value            : out std_logic_vector(31 downto 0);
        dest_reg_2_value            : out std_logic_vector(31 downto 0)

    );
end entity;

architecture rtl of wb_stage is

begin

    process(clk, rst)
    begin
        
        dest_reg_1           <= destination_register_1;
        dest_reg_2           <= destination_register_2;
        
        if rst = '1' then
            dest_reg_1       <= "1111";
            dest_reg_2       <= "1111";
            dest_reg_1_value <= (others => '0');
            dest_reg_2_value <= (others => '0');
        elsif (rising_edge(clk)) then
            -- works in the first half of the clock cycle

            if opCode(6 downto 3) = "0001" then

                dest_reg_1_value     <= destination_reg_2_val;
                dest_reg_2_value     <= destination_reg_1_val;
            else
                dest_reg_1_value     <= alu_output;
                dest_reg_2_value     <= memory_output;
            end if;

        end if;
    end process;

end architecture;