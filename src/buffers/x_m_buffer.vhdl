library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity x_m_buffer is
    port (
        clk               : in std_logic;

        in_aluout         : in std_logic_vector(32 - 1 downto 0);
        in_mem_adr        : in std_logic_vector(32 - 1 downto 0);
        in_mem_inp        : in std_logic_vector(32 - 1 downto 0);
        in_opcode         : in std_logic_vector(7 - 1 downto 0);
        in_destination_0  : in std_logic_vector(4 - 1 downto 0);
        in_destination_1  : in std_logic_vector(4 - 1 downto 0);
        in_dest_value_0   : in std_logic_vector(32 - 1 downto 0);
        in_dest_value_1   : in std_logic_vector(32 - 1 downto 0);
        in_r_w            : in std_logic_vector(2 - 1 downto 0);
        in_interrupt      : in std_logic;

        out_mem_adr       : out std_logic_vector(32 - 1 downto 0);
        out_mem_inp       : out std_logic_vector(32 - 1 downto 0);
        out_aluout        : out std_logic_vector(32 - 1 downto 0);
        out_opcode        : out std_logic_vector(7 - 1 downto 0);
        out_destination_0 : out std_logic_vector(4 - 1 downto 0);
        out_destination_1 : out std_logic_vector(4 - 1 downto 0);
        out_dest_value_0  : out std_logic_vector(32 - 1 downto 0);
        out_dest_value_1  : out std_logic_vector(32 - 1 downto 0);
        out_r_w           : out std_logic_vector(2 - 1 downto 0);
        out_interrupt     : out std_logic
    );
end entity;

architecture rtl of x_m_buffer is
    signal aluout        : std_logic_vector(32 - 1 downto 0);
    signal mem           : std_logic_vector(32 - 1 downto 0);
    signal data          : std_logic_vector(32 - 1 downto 0);

    signal opcode        : std_logic_vector(7 - 1 downto 0);
    signal destination_0 : std_logic_vector(4 - 1 downto 0);
    signal destination_1 : std_logic_vector(4 - 1 downto 0);
    signal dest_value_0  : std_logic_vector(32 - 1 downto 0);
    signal dest_value_1  : std_logic_vector(32 - 1 downto 0);
    signal r_w           : std_logic_vector(2 - 1 downto 0);
    signal interrupt     : std_logic;
begin
    aluout        <= in_aluout;
    mem           <= in_mem_adr;
    data          <= in_mem_inp;
    opcode        <= in_opcode;
    destination_0 <= in_destination_0;
    destination_1 <= in_destination_1;
    dest_value_0  <= in_dest_value_0;
    dest_value_1  <= in_dest_value_1;
    r_w           <= in_r_w;
    interrupt     <= in_interrupt;

    process (clk)
    begin
        if rising_edge(clk) then
            out_aluout        <= aluout;
            out_mem_adr       <= mem;
            out_opcode        <= opcode;
            out_destination_0 <= destination_0;
            out_destination_1 <= destination_1;
            out_dest_value_0  <= dest_value_0;
            out_dest_value_1  <= dest_value_1;
            out_mem_inp       <= data;
            out_r_w           <= r_w;
            out_interrupt     <= interrupt;
        end if;
    end process;
end architecture;