library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity fetch_stage is
    port (
        clk                       : in std_logic;
        rst                       : in std_logic;
        interrupt                 : in std_logic;
        if_flush                  : in std_logic;
        stall                     : in std_logic;
        parallel_load_pc_selector : in std_logic;
        loaded_pc_value           : in std_logic_vector(31 downto 0);
        branch_address            : in std_logic_vector(31 downto 0);
        in_hashed_address         : in std_logic_vector(3 downto 0);
        int_bit                   : out std_logic;
        inst_length_bit           : out std_logic; -- 16 or 32 bits
        instruction_bits          : out std_logic_vector(31 downto 0);
        predicted_address         : out std_logic_vector(31 downto 0);
        out_hashed_address        : out std_logic_vector(3 downto 0);
        current_pc_value          : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of fetch_stage is
    signal pc           : std_logic_vector(31 downto 0);
    signal len_bit      : std_logic := '0'; 
    signal mem_rd       : std_logic := '1';
    signal mem_wr       : std_logic := '0';
    signal mem_data_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal mem_data_out : std_logic_vector(15 downto 0) := (others => '0');

begin

    inst_mem : entity work.ram(rtl) generic map (NUM_WORDS => 256, WORD_LENGTH => 16, ADR_LENGTH => 32)
    port map(
        clk      => clk,
        rd       => mem_rd,
        wr       => mem_wr,
        rst      => rst,
        data_in  => mem_data_in,
        address  => pc,
        data_out => mem_data_out
    );
    
    process (clk, rst)
    begin
        if rst = '1' then
            null;
        elsif falling_edge(clk) then
            -- decide PC next address
            if if_flush = '1' then
                pc <= (others => '0'); -- to be corrected
            elsif parallel_load_pc_selector = '1' then
                pc <= (others => '0'); -- to be corrected
            elsif rst = '1' then
                pc <= (others => '0'); -- to be corrected
            elsif mem_data_out(14 downto 8) = OPC_CALL then
                pc <= (others => '0'); -- to be corrected
            elsif (stall = '1' or interrupt = '1') then
                pc <= (others => '0'); -- to be corrected
            else
                pc <= std_logic_vector(unsigned(pc) + 1);
            end if;
            -- decide whether the instruction is 32 or 64 bits
            if mem_data_out(0) = '1' then
                inst_length_bit <= '1';
                len_bit <= '1';
            else
                inst_length_bit <= '0';
                len_bit <= '0';
            end if;
            -- instruction output
            if len_bit = '0' then
                instruction_bits(31 downto 16) <= mem_data_out;
                instruction_bits(15 downto 0) <= (others => '0');
            else
                instruction_bits(15 downto 0) <= mem_data_out;
            end if;
        end if;
    end process;
end architecture;