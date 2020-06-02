library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity wb_stage is
    port (

        clk                         : in  std_logic;
        rst                         : in  std_logic;
        memory_output               : in  std_logic_vector(31 downto 0);
        alu_output_1                : in  std_logic_vector(31 downto 0);
        alu_output_2                : in  std_logic_vector(31 downto 0);
        destination_register_1      : in  std_logic_vector(3  downto 0);
        destination_register_2      : in  std_logic_vector(3  downto 0);

        opCode                      : in  std_logic_vector(6  downto 0);
        hlt_in                      : in  std_logic;

        dest_reg_1                  : out std_logic_vector(3  downto 0);
        dest_reg_2                  : out std_logic_vector(3  downto 0);

        dest_reg_1_value            : out std_logic_vector(31 downto 0);
        dest_reg_2_value            : out std_logic_vector(31 downto 0);
        hlt_out                     : out std_logic
    );
end entity;

architecture rtl of wb_stage is

begin

    process(rst, destination_register_1, destination_register_2, hlt_in, alu_output_1, alu_output_2)
    begin

        if rst = '1' then
            dest_reg_1       <= "1111";
            dest_reg_2       <= "1111";
            dest_reg_1_value <= (others => '0');
            dest_reg_2_value <= (others => '0');
            hlt_out          <= '0';
        else
            dest_reg_1           <= destination_register_1;
            dest_reg_2           <= destination_register_2;
            hlt_out              <= hlt_in;

            if opCode(6 downto 3) = "0001" then

                dest_reg_1_value     <= alu_output_1;
                dest_reg_2_value     <= alu_output_2;
            else
                dest_reg_1_value     <= alu_output_1;
                dest_reg_2_value     <= memory_output;
            end if;

        end if;
    end process;

end architecture;