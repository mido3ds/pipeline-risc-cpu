library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity pc_control is
    port (
        if_flush                  : in std_logic;
        stall                     : in std_logic;
        rst                       : in std_logic;
        interrupt                 : in std_logic;
        opcode                    : in std_logic_vector(6 downto 0);
        parallel_load_pc_selector : in std_logic;
        pc_mux_selectors          : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of pc_control is
begin
    pc_mux_selectors <= "001" when if_flush = '1' else
        "010" when rst = '1' else
        "011" when stall = '1' else
        "100" when (interrupt = '1' or opcode = OPC_RET or opcode = OPC_RTI) else
        "101" when parallel_load_pc_selector = '1' else
        "000";
end architecture;