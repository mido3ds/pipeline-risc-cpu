library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity execute_stage is
    port (

        -- from main
        clk                                : in  std_logic;
        rst                                : in  std_logic;
        mem_stalling_bit                   : in  std_logic;
        hdu_stalling_bit                   : in std_logic;
        -- from HDU
        -- forwarded data ( from alu or memory)
        forwarded_data_1                   : in  std_logic_vector(31 downto 0);
        forwarded_data_2                   : in  std_logic_vector(31 downto 0);
        forwarded_data_3                   : in  std_logic_vector(31 downto 0);
        forwarded_data_4                   : in  std_logic_vector(31 downto 0);
        forwarded_data_5                   : in  std_logic_vector(31 downto 0);
        ccr_in                             : in  std_logic_vector(2  downto 0);
        -- alu operands selectors
        -- 000 : operand ( No Hazerd detected )
        -- 001 : forwarded data 1 ( from alu_1  )
        -- 010 : forwarded data 2 ( from alu_2)
        -- 011 : forwarded data 3 ( alu_1 from memory stage)
        -- 100 : forwarded data 4 (alu_2 from memory stage)
        -- 101 : forwarded data 5 ( memory )

        alu_op_1_selector                  : in  std_logic_vector(2  downto 0);
        alu_op_2_selector                  : in  std_logic_vector(2  downto 0);

        -- from d_x_buffer
        operand_1                          : in  std_logic_vector(31 downto 0);
        operand_2                          : in  std_logic_vector(31 downto 0);
        alu_operation                      : in  std_logic_vector(3  downto 0);

        destination_register_1_in          : in  std_logic_vector(3  downto 0);
        destination_register_2_in          : in  std_logic_vector(3  downto 0);


        opCode_in                          : in  std_logic_vector(6  downto 0);
        r_w_control_in                     : in  std_logic_vector(1  downto 0);
        int_bit_in                         : in  std_logic;
        hlt_in                             : in  std_logic;


        alu_output_1                       : out std_logic_vector(31 downto 0);
        alu_output_2                       : out std_logic_vector(31 downto 0);
        ccr_out                            : out std_logic_vector(2  downto 0);

        -- to be updated or no
        update_ccr                         : out std_logic;  -- if 0 keep the previous value , if 1 take the output ccr

        memory_address                     : out std_logic_vector(31 downto 0);
        memory_input                       : out std_logic_vector(31 downto 0);

        -- propagated signals
        opCode_out                         : out std_logic_vector(6  downto 0);

        destination_register_1_out         : out std_logic_vector(3  downto 0);
        destination_register_2_out         : out std_logic_vector(3  downto 0);


        r_w_control_out                    : out std_logic_vector(1  downto 0);
        interrupt_bit_out                  : out std_logic;
        hlt_out                            : out std_logic
    );
end entity;

architecture rtl of execute_stage is

    signal op_1                            : std_logic_vector(31 downto 0)    := (others => '0');
    signal op_2                            : std_logic_vector(31 downto 0)    := (others => '0');
    --signal operation                       : std_logic_vector(3  downto 0)    := (others => '0');
    signal opt_1                           : std_logic_vector(31 downto 0)    := (others => '0');
    signal opt_2                           : std_logic_vector(31 downto 0)    := (others => '0');
    signal ccr                             : std_logic_vector(2  downto 0)    := (others => '0');

begin

    U : entity work.alu(rtl)
    port map(
        op                                  => alu_operation,
        a                                   => op_1,
        b                                   => op_2,
        ccr_in                              => ccr_in,
        ccr                                 => ccr,
        c                                   => opt_1,
        c_2                                 => opt_2
    );
    process(clk , ccr_in, opt_1, opt_2, rst, operand_1, operand_2, forwarded_data_1, forwarded_data_2, forwarded_data_3, alu_operation, opCode_in, hlt_in)
    begin
        if rst = '1' then
            alu_output_1                       <= (others => '0');
            alu_output_2                       <= (others => '0');
            ccr_out                            <= (others => '0');
            update_ccr                         <= '0';
            memory_address                     <= (others => '0');
            memory_input                       <= (others => '0');
            opCode_out                         <= (others => '0');
            destination_register_1_out         <= "1111";
            destination_register_2_out         <= "1111";
            r_w_control_out                    <= (others => '0');
            interrupt_bit_out                  <= '0';
            hlt_out                            <= '0';
        elsif (mem_stalling_bit = '0' and hdu_stalling_bit = '0') then
            -- works at rising edge and stalling disabled only

            destination_register_1_out      <= destination_register_1_in;
            destination_register_2_out      <= destination_register_2_in;

            r_w_control_out                 <= r_w_control_in;
            hlt_out                         <= hlt_in;
            --destination_1_value_out         <= destination_1_value;
            --destination_2_value_out         <= destination_2_value;

            opCode_out                      <= opCode_in;
            interrupt_bit_out               <= int_bit_in;

            if (opCode_in(6 downto 0) = "1111000" or opCode_in(6 downto 3) = "1011" ) then  -- in case of IN or LDM no operation performed

                memory_address              <= (others => '0');
                memory_input                <= (others => '0');
                alu_output_1                <= operand_2;
                alu_output_2                <= (others => '0');
                ccr_out                     <= (others => '0');
                update_ccr                  <= '0';
                --operation                   <= ALUOP_NOP;
            elsif (opCode_in(6 downto 3) = "1100" or opCode_in(6 downto 3) = "1101" ) then
                memory_address              <= operand_2;
                memory_input                <= operand_1;
                alu_output_1                <= (others => '0');
                alu_output_2                <= (others => '0');
                ccr_out                     <= (others => '0');
                update_ccr                  <= '0';
            elsif (opCode_in(6 downto 0) = "1111100") then
                case( alu_op_1_selector ) is

                    when "000"    =>
                        alu_output_1                <= operand_1;
                    when  "001"   =>
                        alu_output_1                <= forwarded_data_1;
                    when  "010"   =>
                        alu_output_1                <= forwarded_data_2;
                    when "011"    =>
                        alu_output_1                <= forwarded_data_3;
                    when "100"    =>
                        alu_output_1                <= forwarded_data_4;
                    when "101"    =>
                        alu_output_1                <= forwarded_data_5;
                    when  others =>
                        null;
                end case ;
            else

                case( alu_op_1_selector ) is

                    when "000"    =>
                        op_1                <= operand_1;
                    when  "001"   =>
                        op_1                <= forwarded_data_1;
                    when  "010"   =>
                        op_1                <= forwarded_data_2;
                    when "011"    =>
                        op_1                <= forwarded_data_3;
                    when "100"    =>
                        op_1                <= forwarded_data_4;
                    when "101"    =>
                        op_1                <= forwarded_data_5;
                    when  others =>
                        null;
                end case ;

                case( alu_op_2_selector ) is
                    when  "000"   =>
                        op_2                <= operand_2;
                    when  "001"   =>
                        op_2                <= forwarded_data_1;
                    when  "010"   =>
                        op_2                <= forwarded_data_2;
                    when "011"    =>
                        op_2                <= forwarded_data_3;
                    when "100"    =>
                        op_2                <= forwarded_data_4;
                    when "101"    =>
                        op_2                <= forwarded_data_5;
                    when  others =>
                        null;
                end case ;

                ccr_out                     <= ccr;
                alu_output_1                <= opt_1;
                alu_output_2                <= opt_2;
                memory_input                <= op_2;

                if (alu_operation = ALUOP_NOP or alu_operation = ALUOP_INC2 or alu_operation = ALUOP_DEC2 or alu_operation = ALUOP_SWAP) then
                    update_ccr              <= '0';
                else
                    update_ccr              <= '1';
                end if;

                if (opCode_in(6 downto 3) = "1010" or opCode_in = "0000100" or opCode_in = "0000101" ) then
                    memory_address              <= opt_1;
                else
                    memory_address              <= op_1;
                end if;

            end if;
        end if;
    end process;
end architecture;