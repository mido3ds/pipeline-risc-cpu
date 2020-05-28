library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity m_w_buffer is
    port (
        clk               : in std_logic;
        in_aluout         : in std_logic_vector(32 - 1 downto 0);
        in_mem            : in std_logic_vector(32 - 1 downto 0);
        in_opcode         : in std_logic_vector(7 - 1 downto 0);
        in_destination_0  : in std_logic_vector(4 - 1 downto 0);
        in_destination_1  : in std_logic_vector(4 - 1 downto 0);
        in_dest_value_0   : in std_logic_vector(32 - 1 downto 0);
        in_dest_value_1   : in std_logic_vector(32 - 1 downto 0);
        in_hlt            : in std_logic;

        out_aluout        : out std_logic_vector(32 - 1 downto 0);
        out_mem           : out std_logic_vector(32 - 1 downto 0);
        out_opcode        : out std_logic_vector(7 - 1 downto 0);
        out_destination_0 : out std_logic_vector(4 - 1 downto 0);
        out_destination_1 : out std_logic_vector(4 - 1 downto 0);
        out_dest_value_0  : out std_logic_vector(32 - 1 downto 0);
        out_dest_value_1  : out std_logic_vector(32 - 1 downto 0);
        out_hlt           : out std_logic
    );
end entity;

architecture rtl of m_w_buffer is
    signal aluout        : std_logic_vector(32 - 1 downto 0);
    signal mem           : std_logic_vector(32 - 1 downto 0);
    signal opcode        : std_logic_vector(7 - 1 downto 0);
    signal destination_0 : std_logic_vector(4 - 1 downto 0);
    signal destination_1 : std_logic_vector(4 - 1 downto 0);
    signal dest_value_0  : std_logic_vector(32 - 1 downto 0);
    signal dest_value_1  : std_logic_vector(32 - 1 downto 0);
    signal hlt           : std_logic;
begin
    aluout        <= in_aluout;
    mem           <= in_mem;
    opcode        <= in_opcode;
    destination_0 <= in_destination_0;
    destination_1 <= in_destination_1;
    dest_value_0  <= in_dest_value_0;
    dest_value_1  <= in_dest_value_1;
    hlt           <= in_hlt;

    process (clk, aluout)
    begin
        if rising_edge(clk) then
            out_aluout        <= aluout;
            out_mem           <= mem;
            out_opcode        <= opcode;
            out_destination_0 <= destination_0;
            out_destination_1 <= destination_1;
            out_dest_value_0  <= dest_value_0;
            out_dest_value_1  <= dest_value_1;
            out_hlt           <= hlt;
        end if;
    end process;
end architecture;