library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity execute_stage is
    port (

        clk                                : in  std_logic;
        stalling                           : in  std_logic;

        operand_1                          : in  std_logic_vector(31 downto 0);
        operand_2                          : in  std_logic_vector(31 downto 0);

        -- forwarded data ( from alu or memory)
        forwarded_data_1                   : in  std_logic_vector(31 downto 0);
        forwarded_data_2                   : in  std_logic_vector(31 downto 0);

        -- used in case of swapping , IN , LDM operations
        destination_1_value                : in  std_logic_vector(31 downto 0);
        destination_2_value                : in  std_logic_vector(31 downto 0);

        -- alu operands selectors
        -- 00 : operand ( No Hazerd detected )
        -- 01 : forwarded data ( from alu or memory stage )
        -- 10 : destination_1_value ( in case of swapping )

        alu_op_1_selector                  : in  std_logic_vector(1  downto 0);
        alu_op_2_selector                  : in  std_logic_vector(1  downto 0);

        alu_operation                      : in  std_logic_vector(3  downto 0);


        destination_register_1_in          : in  std_logic_vector(3  downto 0);
        destination_register_2_in          : in  std_logic_vector(3  downto 0);


        opCode_in                          : in  std_logic_vector(6  downto 0);

        int_bit_in                         : in  std_logic;

        -- to be updated or no
        ccr_in                             : in  std_logic_vector(2  downto 0);

        alu_output                         : out std_logic_vector(31 downto 0);
        ccr_out                            : out std_logic_vector(2  downto 0);

        memory_address                     : out std_logic_vector(31 downto 0);
        memory_input                       : out std_logic_vector(31 downto 0);

        -- propagated signals
        opCode_out                         : out std_logic_vector(6  downto 0);

        destination_register_1_out         : out std_logic_vector(3  downto 0);
        destination_register_2_out         : out std_logic_vector(3  downto 0);

        destination_1_value_out            : out std_logic_vector(31 downto 0);
        destination_2_value_out            : out std_logic_vector(31 downto 0);

        interrupt_bit_out                  : out std_logic


    );
end entity;

architecture rtl of execute_stage is

    signal op_1                            : std_logic_vector(31 downto 0)    := (others => '0');
    signal op_2                            : std_logic_vector(31 downto 0)    := (others => '0');
    signal operation                       : std_logic_vector(3  downto 0)    := (others => '0');
    signal opt                             : std_logic_vector(31 downto 0)    := (others => '0');
    signal ccr                             : std_logic_vector(2  downto 0)    := (others => '0');


begin

    U : entity work.alu(rtl)
    port map(
        op                                  => operation,
        a                                   => op_1,
        b                                   => op_2,
        ccr                                 => ccr,
        c                                   => opt
    );

    process(clk , opt)
    begin

        -- works at rising edge and stalling disabled only

        if (rising_edge(clk) and stalling = '0') then

            destination_register_1_out      <= destination_register_1_in;
            destination_register_2_out      <= destination_register_2_in;

            destination_1_value_out         <= destination_1_value;
            destination_2_value_out         <= destination_2_value;

            opCode_out                      <= opCode_in;
            interrupt_bit_out               <= int_bit_in;

            if (opCode_in = "1111000" or opCode_in(6 downto 3) = "1011") then                    -- in case of IN or LDM no operation performed

                memory_address              <= (others => '0');      -- don't care !
                memory_input                <= destination_1_value;
                alu_output                  <= destination_1_value;
                ccr_out                     <= ccr_in;
                operation                   <= ALUOP_NOP;
            else

                case( alu_op_1_selector ) is

                    when "01"   =>
                        op_1                <= forwarded_data_1;
                    when "10"   =>
                        op_1                <= destination_1_value;
                    when "11"   =>
                        op_1                <= destination_2_value;
                    when others =>   -- when 00
                        op_1                <= operand_1;
                end case ;

                case( alu_op_2_selector ) is
                    when "01"   =>
                        op_1                <= forwarded_data_2;
                    when "10"   =>
                        op_2                <= destination_1_value;
                    when "11"   =>
                        op_2                <= destination_2_value;
                    when others =>   -- when 00
                        op_2                <= operand_2;
                end case ;

                operation                   <= alu_operation;
                ccr_out                     <= ccr;
                alu_output                  <= opt;
                memory_input                <= operand_2;

                if (opCode_in(6 downto 3) = "1010" or opCode_in = "0000100" or opCode_in = "0000101" ) then
                    memory_address              <= opt;
                else
                    memory_address              <= operand_1;
                end if;

            end if;
        end if;

    end process;
end architecture;