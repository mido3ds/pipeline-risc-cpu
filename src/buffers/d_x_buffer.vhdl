library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d_x_buffer is
    port (
        clk, stall      : in std_logic;
        in_operand0     : in std_logic_vector(32 - 1 downto 0);
        in_operand1     : in std_logic_vector(32 - 1 downto 0);
        in_destination  : in std_logic_vector(4 - 1 downto 0);
        in_opcode       : in std_logic_vector(7 - 1 downto 0);
        in_r_w          : in std_logic_vector(1 downto 0);
        in_interrupt    : in std_logic;

        out_operand0    : out std_logic_vector(32 - 1 downto 0);
        out_operand1    : out std_logic_vector(32 - 1 downto 0);
        out_destination : out std_logic_vector(4 - 1 downto 0);
        out_opcode      : out std_logic_vector(7 - 1 downto 0);
        out_r_w         : out std_logic_vector(1 downto 0);
        out_interrupt   : out std_logic;
        out_values      : out std_logic_vector(32 - 1 downto 0) -- TODO
    );
end entity;

architecture rtl of d_x_buffer is
    signal operand0    : std_logic_vector(32 - 1 downto 0);
    signal operand1    : std_logic_vector(32 - 1 downto 0);
    signal destination : std_logic_vector(4 - 1 downto 0);
    signal opcode      : std_logic_vector(7 - 1 downto 0);
    signal r_w         : std_logic_vector(1 downto 0);
    signal interrupt   : std_logic;
begin
    process (stall, in_operand0, in_operand1, in_destination, in_opcode, in_r_w, in_interrupt)
    begin
        if stall = '0' then
            operand0    <= in_operand0;
            operand1    <= in_operand1;
            destination <= in_destination;
            opcode      <= in_opcode;
            r_w         <= in_r_w;
            interrupt   <= in_interrupt;
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            out_operand0    <= operand0;
            out_operand1    <= operand1;
            out_destination <= destination;
            out_opcode      <= opcode;
            out_r_w         <= r_w;
            out_interrupt   <= interrupt;
        end if;
    end process;
end architecture;