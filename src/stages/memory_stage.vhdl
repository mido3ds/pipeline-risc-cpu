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
        alu_result                         : in  std_logic_vector(31 downto 0);
        destination_register_1_in          : in  std_logic_vector(3  downto 0);
        destination_register_2_in          : in  std_logic_vector(3  downto 0);

        destination_1_value                : in  std_logic_vector(31 downto 0);
        destination_2_value                : in  std_logic_vector(31 downto 0);
        opCode_in                          : in  std_logic_vector(6  downto 0);
        hlt_in                             : in  std_logic;

        -- used for pc navigator
        int_bit_in                         : in  std_logic;


        memory_out                         : out std_logic_vector(31 downto 0);
        alu_output                         : out std_logic_vector(31 downto 0);
        opCode_out                         : out std_logic_vector(6  downto 0);
        destination_register_1_out         : out std_logic_vector(3  downto 0);
        destination_register_2_out         : out std_logic_vector(3  downto 0);

        destination_1_value_out            : out std_logic_vector(31 downto 0);
        destination_2_value_out            : out std_logic_vector(31 downto 0);
        hlt_out                            : out std_logic;


        ccr_out                            : out std_logic_vector(2  downto 0);
        ccr_out_selector                   : out std_logic;

        pc_selector                        : out std_logic;
        stalling_enable                    : out std_logic;

        -- testing signals

        -- '1' if testbench is taking control now of the memory and regs
        tb_controls                  : in std_logic;

        -- to mem
        tb_mem_rd                    : in std_logic;
        tb_mem_wr                    : in std_logic;
        tb_mem_data_in               : in std_logic_vector(31 downto 0);
        tb_mem_adr                   : in std_logic_vector(31 downto 0);
        -- from mem
        tb_mem_data_out              : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of memory_stage is

    signal pc_nav_enable                   : std_logic                        := '0';
    signal sp                              : std_logic_vector(31 downto 0)    := (others => '0');
    signal input_data                      : std_logic_vector(31 downto 0)    := (others => '0');
    signal output_data                     : std_logic_vector(31 downto 0)    := (others => '0');
    signal address                         : std_logic_vector(31 downto 0)    := (others => '0');
    signal stalling_in                     : std_logic                        := '0';
    signal stalling_out                    : std_logic                        := '0';

    signal pc_sel                          : std_logic                        := '0';
    --> data_mem
    signal dm_rd        : std_logic;
    signal dm_wr        : std_logic;
    signal dm_data_in   : std_logic_vector(31 downto 0);
    signal dm_adr       : std_logic_vector(31 downto 0);
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
        data_in                                => dm_data_in,
        address                                => dm_adr,
        data_out                               => output_data
    );
    --IN
    dm_rd           <= tb_mem_rd when tb_controls = '1' else r_w_control(0);
    dm_wr           <= tb_mem_wr when tb_controls = '1' else r_w_control(1);
    dm_data_in      <= tb_mem_data_in when tb_controls = '1' else input_data;
    dm_adr          <= tb_mem_adr when tb_controls = '1' else address;
    --OUT
    tb_mem_data_out <= output_data;

    pc_nav: entity work.pc_navigator(rtl)
    port map(
        clk                                    => clk,
        opCode_in                              => opCode_in,
        int_bit_in                             => int_bit_in,
        enable                                 => pc_nav_enable,
        address                                => memory_address,
        stalling                               => stalling_in,
        stack_pointer                          => sp,
        pc_selector                            => pc_sel,
        stalling_enable                        => stalling_out

    );


    process(clk,rst, pc_sel, alu_result, pc_nav_enable, sp, input_data, output_data, address, hlt_in )
    begin
        if rst = '1' then
            memory_out                         <= (others => '0');
            alu_output                         <= (others => '0');
            opCode_out                         <= (others => '0');
            destination_register_1_out         <= "1111";
            destination_register_2_out         <= "1111";
            destination_1_value_out            <= (others => '0');
            destination_2_value_out            <= (others => '0');
            ccr_out                            <= (others => '0');
            ccr_out_selector                   <= '0';
            pc_selector                        <= '0';
            stalling_enable                    <= '0';
            hlt_out                            <= '0';
        else

            if (pc_sel = '1') then
                pc_selector                    <= pc_sel;
            else
                pc_selector                   <= pc_sel;
            end if;

            if stalling_in = '1' then      --we get the ccr only
                pc_nav_enable                  <= '1';
                address                        <= sp;
                input_data                     <= memory_in;
                alu_output                     <= sp;

                if (opCode_in = OPC_RTI) then         -- loading ccr from stack
                    ccr_out                    <= output_data(2 downto 0);
                    ccr_out_selector           <= '1';

                end if;
                stalling_in                    <= '0';
            else

                alu_output                     <= alu_result;
                stalling_in                    <= stalling_out;
                -- normal situation
                opCode_out                     <= opCode_in;
                destination_register_1_out     <= destination_register_1_in;
                destination_register_2_out     <= destination_register_2_in;
                ccr_out                        <= ccr_in;
                ccr_out_selector               <= '0';
                destination_1_value_out        <= destination_1_value;
                destination_2_value_out        <= destination_2_value;

                address                        <= memory_address;
                memory_out                     <= output_data;
                hlt_out                        <= hlt_in;

                -- check the operation to output the stack pointer
                -- interrupt or return from interrupt situation

                if int_bit_in = '1' then
                    pc_nav_enable              <= '1';
                    input_data                 <= "00000000000000000000000000000" & ccr_in;        --store ccr first then store pc !

                elsif (opCode_in = "000100" or opCode_in = "000101") then                     -- opcode of rti or ret operations activate pc navigator
                    pc_nav_enable              <= '1';
                    input_data                 <= memory_in;
                else
                    pc_nav_enable              <= '0';
                    input_data                 <= memory_in;
                end if;

            end if;
            stalling_enable                    <= stalling_in;
        end if;

    end process;
end architecture;