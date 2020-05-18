library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d_x_buffer is
    port (
        clk            : in std_logic;

        in_stall       : in std_logic;
        in_alu_op      : in std_logic_vector (3 downto 0);
        in_operand0    : in std_logic_vector(32 - 1 downto 0);
        in_operand1    : in std_logic_vector(32 - 1 downto 0);
        in_src2_value  : in std_logic_vector(32 - 1 downto 0);
        in_sel_src2    : in std_logic;
        in_dest_0      : in std_logic_vector(4 - 1 downto 0);
        in_dest_1      : in std_logic_vector(4 - 1 downto 0);
        --in_dest_value  : in std_logic_vector(32 - 1 downto 0);
        in_opcode      : in std_logic_vector(7 - 1 downto 0);
        in_r_w         : in std_logic_vector(1 downto 0);
        in_interrupt   : in std_logic;

        out_alu_op     : out std_logic_vector (3 downto 0);
        out_operand0   : out std_logic_vector(32 - 1 downto 0);
        out_operand1   : out std_logic_vector(32 - 1 downto 0);
        out_dest_0     : out std_logic_vector(4 - 1 downto 0);
        out_dest_1     : out std_logic_vector(4 - 1 downto 0);
        -- out_dest_value : out std_logic_vector(32 - 1 downto 0);
        out_opcode     : out std_logic_vector(7 - 1 downto 0);
        out_r_w        : out std_logic_vector(1 downto 0);
        out_interrupt  : out std_logic
    );
end entity;

architecture rtl of d_x_buffer is
    signal operand0      : std_logic_vector(32 - 1 downto 0);
    signal operand1      : std_logic_vector(32 - 1 downto 0);
    signal src2_value    : std_logic_vector(32 - 1 downto 0);
    signal destination_0 : std_logic_vector(4 - 1 downto 0);
    signal destination_1 : std_logic_vector(4 - 1 downto 0);
    --signal dest_value    : std_logic_vector(32 - 1 downto 0);
    signal opcode        : std_logic_vector(7 - 1 downto 0);
    signal r_w           : std_logic_vector(1 downto 0);
    signal interrupt     : std_logic;
    signal alu_op        : std_logic_vector(3 downto 0);
begin
    --process (in_stall, in_operand0, in_operand1, in_dest_0, in_dest_1, in_dest_value, in_opcode, in_r_w, in_interrupt)
    process (in_stall, in_operand0, in_operand1, in_dest_0, in_dest_1, in_opcode, in_r_w, in_interrupt)
    begin
        if in_stall = '0' then
            operand0      <= in_operand0;
            operand1      <= in_operand1;
            src2_value    <= in_src2_value;
            destination_0 <= in_dest_0;
            destination_1 <= in_dest_1;
            --dest_value    <= in_dest_value;
            opcode        <= in_opcode;
            r_w           <= in_r_w;
            interrupt     <= in_interrupt;
            alu_op        <= in_alu_op;
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            out_alu_op     <= alu_op;
            out_operand0   <= operand0;

            if in_sel_src2 = '1' then
                out_operand1 <= src2_value;
            else
            out_operand1   <= operand1;
            end if;

            out_dest_0     <= destination_0;
            out_dest_1     <= destination_1;
            --out_dest_value <= dest_value;
            out_opcode     <= opcode;
            out_r_w        <= r_w;
            out_interrupt  <= interrupt;
        end if;
    end process;
end architecture;