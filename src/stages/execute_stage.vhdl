library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity execute_stage is
    port (

        -- from main
        clk                                : in  std_logic;
        mem_stalling_bit                   : in  std_logic;

        -- from HDU
        -- forwarded data ( from alu or memory)
        forwarded_data_1_1                   : in  std_logic_vector(31 downto 0);
        forwarded_data_1_2                   : in  std_logic_vector(31 downto 0);

        forwarded_data_2_1                   : in  std_logic_vector(31 downto 0);
        forwarded_data_2_2                   : in  std_logic_vector(31 downto 0);

        -- alu operands selectors
        -- 00 : operand ( No Hazerd detected )
        -- 01 : forwarded data 1 ( from alu  )
        -- 10 : forwarded data 2 ( from memory)

        alu_op_1_selector                  : in  std_logic_vector(1  downto 0);
        alu_op_2_selector                  : in  std_logic_vector(1  downto 0);

        -- from d_x_buffer
        operand_1                          : in  std_logic_vector(31 downto 0);
        operand_2                          : in  std_logic_vector(31 downto 0);

        alu_operation                      : in  std_logic_vector(3  downto 0);

        destination_register_1_in          : in  std_logic_vector(3  downto 0);
        destination_register_2_in          : in  std_logic_vector(3  downto 0);


        opCode_in                          : in  std_logic_vector(6  downto 0);
        r_w_control_in                     : in  std_logic_vector(1  downto 0);
        int_bit_in                         : in  std_logic;


        alu_output                         : out std_logic_vector(31 downto 0);
        ccr_out                            : out std_logic_vector(2  downto 0);

        -- to be updated or no
        update_ccr                         : out std_logic;                               -- if 0 keep the previous value , if 1 take the output ccr

        memory_address                     : out std_logic_vector(31 downto 0);
        memory_input                       : out std_logic_vector(31 downto 0);

        -- propagated signals
        opCode_out                         : out std_logic_vector(6  downto 0);

        destination_register_1_out         : out std_logic_vector(3  downto 0);
        destination_register_2_out         : out std_logic_vector(3  downto 0);

        destination_1_value_out            : out std_logic_vector(31 downto 0);
        destination_2_value_out            : out std_logic_vector(31 downto 0);

        r_w_control_out                    : out std_logic_vector(1  downto 0);
        interrupt_bit_out                  : out std_logic


    );
end entity;

architecture rtl of execute_stage is

    signal op_1                            : std_logic_vector(31 downto 0)    := (others => '0');
    signal op_2                            : std_logic_vector(31 downto 0)    := (others => '0');
    --signal operation                       : std_logic_vector(3  downto 0)    := (others => '0');
    signal opt                             : std_logic_vector(31 downto 0)    := (others => '0');
    signal ccr                             : std_logic_vector(2  downto 0)    := (others => '0');


begin

    U : entity work.alu(rtl)
    port map(
        op                                  => alu_operation,
        a                                   => op_1,
        b                                   => op_2,
        ccr                                 => ccr,
        c                                   => opt
    );

    process(clk , opt)
    begin

        -- works at rising edge and stalling disabled only

        if (rising_edge(clk) and mem_stalling_bit = '0') then

            destination_register_1_out      <= destination_register_1_in;
            destination_register_2_out      <= destination_register_2_in;

            r_w_control_out                 <= r_w_control_in;
            --destination_1_value_out         <= destination_1_value;
            --destination_2_value_out         <= destination_2_value;

            if (opCode_in(6 downto 3) = OPC_SWAP) then           -- swap case
                destination_1_value_out     <= operand_1;
                destination_2_value_out     <= operand_2;
            else
                destination_1_value_out     <= (others => '0');
                destination_2_value_out     <= (others => '0');
            end if;

            opCode_out                      <= opCode_in;
            interrupt_bit_out               <= int_bit_in;

            if (opCode_in(6 downto 0) = OPC_IN or opCode_in(6 downto 3) = OPC_LDM) then                    -- in case of IN or LDM no operation performed

                memory_address              <= (others => '0');
                memory_input                <= (others => '0');
                alu_output                  <= operand_2;
                ccr_out                     <= (others => '0');
                update_ccr                  <= '0';
                --operation                   <= ALUOP_NOP;
            elsif (opCode_in = OPC_LDD or opCode_in = OPC_STD ) then
                memory_address              <= operand_2;
                memory_input                <= operand_1;
                alu_output                  <= (others => '0');
                ccr_out                     <= (others => '0');
                update_ccr                  <= '0';
            else

                case( alu_op_1_selector ) is

                    when  "01"   =>
                        op_1                <= forwarded_data_1_1;
                    when  "10"   =>
                        op_1                <= forwarded_data_1_2;
                    --when "11"   =>
                    --    op_1                <= destination_2_value;
                    when  others =>   -- when 00
                        op_1                <= operand_1;
                end case ;

                case( alu_op_2_selector ) is
                    when  "01"   =>
                        op_2                <= forwarded_data_2_1;
                    when  "10"   =>
                        op_2                <= forwarded_data_2_2;
                    --when "11"   =>
                    --    op_2                <= destination_2_value;
                    when  others =>   -- when 00
                        op_2                <= operand_2;
                end case ;

                ccr_out                     <= ccr;
                alu_output                  <= opt;
                memory_input                <= operand_2;

                if (alu_operation = ALUOP_NOP or alu_operation = ALUOP_INC2 or alu_operation = ALUOP_DEC2) then
                    update_ccr              <= '0';
                else
                    update_ccr              <= '1';
                end if;

                if (opCode_in(6 downto 3) = OPC_POP or opCode_in = OPC_RET or opCode_in = OPC_RTI ) then
                    memory_address              <= opt;
                else
                    memory_address              <= operand_1;
                end if;

            end if;
        end if;

    end process;
end architecture;