library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity memory_stage is
    port (

        clk                                : in  std_logic;
        rst                                : in  std_logic;
        memory_in                          : in  std_logic_vector(31 downto 0);
        memory_address                     : in  std_logic_vector(31 downto 0);
        r_w_control                        : in  std_logic_vector(1  downto 0);
        ccr_in                             : in  std_logic_vector(2  downto 0);
        -- passed to wb stage
        alu_result_1                       : in  std_logic_vector(31 downto 0);
        alu_result_2                       : in  std_logic_vector(31 downto 0);
        destination_register_1_in          : in  std_logic_vector(3  downto 0);
        destination_register_2_in          : in  std_logic_vector(3  downto 0);

        opCode_in                          : in  std_logic_vector(6  downto 0);
        hlt_in                             : in  std_logic;

        -- used for pc navigator
        int_bit_in                         : in  std_logic;


        memory_out                         : out std_logic_vector(31 downto 0);
        alu_output_1                       : out std_logic_vector(31 downto 0);
        alu_output_2                       : out std_logic_vector(31 downto 0);
        opCode_out                         : out std_logic_vector(6  downto 0);
        destination_register_1_out         : out std_logic_vector(3  downto 0);
        destination_register_2_out         : out std_logic_vector(3  downto 0);

        hlt_out                            : out std_logic;


        ccr_out                            : out std_logic_vector(2  downto 0);
        ccr_out_selector                   : out std_logic;

        pc_selector                        : out std_logic;

        -- testing signals

        -- '1' if testbench is taking control now of the memory and regs
        tb_controls                  : in std_logic;

        -- to mem
        tb_mem_rd                    : in std_logic;
        tb_mem_wr                    : in std_logic;
        tb_is_stack                  : in std_logic;
        tb_mem_data_in               : in std_logic_vector(31 downto 0);
        tb_mem_adr                   : in std_logic_vector(31 downto 0);
        -- from mem
        tb_mem_data_out              : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of memory_stage is

    signal input_data                      : std_logic_vector(31 downto 0)    := (others => '0');
    signal output_data                     : std_logic_vector(31 downto 0)    := (others => '0');
    signal address                         : std_logic_vector(31 downto 0)    := (others => '0');
    signal is_stack                        : std_logic                        := '0';

    --> data_mem
    signal dm_rd        : std_logic;
    signal dm_wr        : std_logic;
    signal dm_data_in   : std_logic_vector(31 downto 0);
    signal dm_adr       : std_logic_vector(31 downto 0);
    signal dm_is_stack  : std_logic;
begin

    data_mem : entity work.data_mem(rtl)
    generic map(
        ADR_LENGTH                             => 32
    )
    port map(
        clk                                    => clk,
        rd                                     => dm_rd,
        wr                                     => dm_wr,
        rst                                    => '0',
        is_stack                               => dm_is_stack,
        data_in                                => dm_data_in,
        address                                => dm_adr,
        data_out                               => output_data
    );
    --IN
    dm_rd           <= tb_mem_rd when tb_controls = '1' else r_w_control(0);
    dm_wr           <= tb_mem_wr when tb_controls = '1' else r_w_control(1);
    dm_is_stack     <= tb_is_stack when tb_controls = '1' else is_stack;
    dm_data_in      <= tb_mem_data_in when tb_controls = '1' else input_data;
    dm_adr          <= tb_mem_adr when tb_controls = '1' else address;
    --OUT
    tb_mem_data_out <= output_data;


    process(clk,rst, alu_result_1, alu_result_2, input_data, output_data, address, hlt_in )
    begin
        if rst = '1' then
            memory_out                         <= (others => '0');
            alu_output_1                       <= (others => '0');
            alu_output_2                       <= (others => '0');
            opCode_out                         <= (others => '0');
            destination_register_1_out         <= "1111";
            destination_register_2_out         <= "1111";
            ccr_out                            <= (others => '0');
            ccr_out_selector                   <= '0';
            pc_selector                        <= '0';
            hlt_out                            <= '0';
            is_stack                           <= '0';
        else
            -- set data memory write/read direction
            if (opCode_in = "0000011" or opCode_in = "0000100" or opCode_in = "0000101" or opCode_in(6 downto 3) = "1001" or opCode_in(6 downto 3) = "1010" or int_bit_in = '1') then
                -- CALL, RET, RTI, PUSH, POP & INTERRUPT
                is_stack <= '1';
            else
                is_stack <= '0';
            end if;

            alu_output_1                   <= alu_result_1;
            alu_output_2                   <= alu_result_2;
            opCode_out                     <= opCode_in;
            destination_register_1_out     <= destination_register_1_in;
            destination_register_2_out     <= destination_register_2_in;

            address                        <= memory_address;
            hlt_out                        <= hlt_in;
            if int_bit_in = '1' then
                pc_selector                <= '0';
                input_data                 <= ccr_in & memory_in(28 downto 0);
                ccr_out                    <= ccr_in;
                ccr_out_selector           <= '0';
            elsif (opCode_in = "0000100" or opCode_in = "0000101") then -- opcode of rti or ret operations activate pc navigator
                input_data                 <= memory_in;
                pc_selector                    <= '1';
                if (opCode_in = "0000101") then
                    memory_out                     <= "000" & output_data(28 downto 0);
                    ccr_out                        <= output_data(31 downto 29);
                    ccr_out_selector               <= '1';
                else
                    memory_out                 <= output_data;
                    ccr_out                    <= ccr_in;
                    ccr_out_selector           <= '0';
                end if;
            else
                pc_selector                <= '0';
                input_data                 <= memory_in;
                ccr_out                    <= ccr_in;
                ccr_out_selector           <= '0';
                memory_out                     <= output_data;
            end if;

        end if;

    end process;
end architecture;