library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity memory_stage is
    port (

        clk                                : in  std_logic;
        memory_in                          : in  std_logic_vector(31 downto 0);
        memory_address                     : in  std_logic_vector(31 downto 0);
        r_w_control                        : in  std_logic_vector(1  downto 0);
        ccr_in                             : in  std_logic_vector(2  downto 0);
        -- passed to wb stage
        alu_result                         : in  std_logic_vector(31 downto 0);
        destination_register_1_in          : in  std_logic_vector(3  downto 0);
        destination_register_2_in          : in  std_logic_vector(3  downto 0);

        destination_1_value                : in  std_logic_vector(31 downto 0);
        destination_2_value                : in  std_logic_vector(31 downto 0);
        opCode_in                          : in  std_logic_vector(6  downto 0);

        stalling                           : in  std_logic;

        -- used for pc navigator
        int_bit_in                         : in  std_logic;


        --stack_pointer               : out std_logic_vector(31 downto 0);
        memory_out                         : out std_logic_vector(31 downto 0);
        alu_output                         : out std_logic_vector(31 downto 0);
        opCode_out                         : out std_logic_vector(6  downto 0);
        destination_register_1_out         : out std_logic_vector(3  downto 0);
        destination_register_2_out         : out std_logic_vector(3  downto 0);

        destination_1_value_out            : out std_logic_vector(31 downto 0);
        destination_2_value_out            : out std_logic_vector(31 downto 0);


        ccr_out                            : out std_logic_vector(2  downto 0);

        pc_selector                        : out std_logic;
        stalling_enable                    : out std_logic
    );
end entity;

architecture rtl of memory_stage is

    signal pc_nav_enable                   : std_logic                        := '0';
    signal sp                              : std_logic_vector(31 downto 0)    := (others => '0');
    signal input_data                      : std_logic_vector(31 downto 0)    := (others => '0');
    signal output_data                     : std_logic_vector(31 downto 0)    := (others => '0');
    signal address                         : std_logic_vector(31 downto 0)    := (others => '0');

begin

    data_mem : entity work.data_mem(rtl)
    generic map(
        ADR_LENGTH                             => 32
    )
    port map(
        clk                                    => clk,
        rd                                     => r_w_control(0),
        wr                                     => r_w_control(1),
        rst                                    => '0',
        data_in                                => input_data,
        address                                => address,
        data_out                               => output_data
    );

    pc_nav: entity work.pc_navigator(rtl)
    port map(
        clk                                    => clk,
        opCode_in                              => opCode_in,
        int_bit_in                             => int_bit_in,
        enable                                 => pc_nav_enable,
        address                                => memory_address,
        stalling                               => stalling,
        stack_pointer                          => sp,
        pc_selector                            => pc_selector,
        stalling_enable                        => stalling_enable

    );

    alu_output                                 <= sp when stalling = '1' else alu_result;

    process(clk)
    begin
        if rising_edge(clk) then
            if stalling = '1' then      --we get the ccr only
                pc_nav_enable                  <= '1';
                address                        <= sp;
                input_data                     <= memory_in;

                if (opCode_in = "0000101") then         -- loading ccr from stack
                    ccr_out                    <= output_data(2 downto 0);
                end if;

            else

                -- normal situation
                opCode_out                     <= opCode_in;
                destination_register_1_out     <= destination_register_1_in;
                destination_register_2_out     <= destination_register_2_in;
                ccr_out                        <= ccr_in;

                destination_1_value_out        <= destination_1_value;
                destination_2_value_out        <= destination_2_value;

                address                        <= memory_address;
                memory_out                     <= output_data;

                -- check the operation to output the stack pointer
                -- interrupt or return from interrupt situation

                if int_bit_in = '1' then
                    pc_nav_enable              <= '1';
                    input_data                 <= "00000000000000000000000000000" & ccr_in;        --store ccr first then store pc !

                elsif (opCode_in = "0000101" or opCode_in = "0000100") then                     -- opcode of rti or ret operations activate pc navigator
                    pc_nav_enable              <= '1';
                    input_data                 <= memory_in;
                else
                    pc_nav_enable              <= '0';
                    input_data                 <= memory_in;
                end if;

            end if;
        end if;

    end process;
end architecture;