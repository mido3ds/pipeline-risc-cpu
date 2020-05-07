library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity execute_stage is
    port (
        clk                         : in std_logic;
        rst                         : in std_logic;

        -- choose the alu inputs from the alu selectors
        operand_1                   : in std_logic_vector(31 downto 0);
        operand_2                   : in std_logic_vector(31 downto 0);
        forwarded_data_1            : in std_logic_vector(31 downto 0);
        forwarded_data_2            : in std_logic_vector(31 downto 0);

        -- from hazerd detection unit
        alu_op_1_selector           : in std_logic;   -- if 1 take the forwarded
        alu_op_2_selector           : in std_logic;

        -- the selected operation
        alu_operation               : in std_logic_vector(3 downto 0);

        initial_mem_address         : in std_logic_vector(31 downto 0);
        destination_register_in     : in std_logic_vector(3  downto 0);
        opCode_in                   : in std_logic_vector(6  downto 0);
        int_bit_in                  : in std_logic;


        alu_output                  : out std_logic_vector(31 downto 0);
        ccr                         : out std_logic_vector(2  downto 0);
        memory_address              : out std_logic_vector(31 downto 0);
        opCode_out                  : out std_logic_vector(6  downto 0);
        mem_in                      : out std_logic_vector(31 downto 0);  -- out from operand 1
        destination_register_out    : out std_logic_vector(3  downto 0);
        int_bit_out                 : out std_logic
    );
end entity;

architecture rtl of execute_stage is
    signal alu_operand_1      : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_operand_2      : std_logic_vector(31 downto 0) := (others => '0');

begin

    opCode_out               <= opCode_in;
    mem_in                   <= operand_1;
    int_bit_out              <= int_bit_in;
    destination_register_out <= destination_register_in;

    alu_operand_1 <= forwarded_data_1 when alu_op_1_selector = '1' else operand_1;
    alu_operand_2 <= forwarded_data_2 when alu_op_2_selector = '1' else operand_2;

    operation: entity work.alu port map (
        op    => alu_operation,
        a     => alu_operand_1,
        b     => alu_operand_2,
        ccr   => ccr,
        c     => alu_output
    );

end architecture;