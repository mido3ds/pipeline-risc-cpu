library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity fetch_stage is
    port (
        clk                          : in std_logic;
        rst                          : in std_logic;

        in_interrupt                 : in std_logic;
        in_if_flush                  : in std_logic;
        in_stall                     : in std_logic;
        in_parallel_load_pc_selector : in std_logic;
        in_loaded_pc_value           : in std_logic_vector(31 downto 0);
        in_branch_address            : in std_logic_vector(31 downto 0);
        in_hashed_address            : in std_logic_vector(3 downto 0);

        out_interrupt                : out std_logic;
        out_instruction_bits         : out std_logic_vector(31 downto 0);
        out_predicted_address        : out std_logic_vector(31 downto 0);
        out_hashed_address           : out std_logic_vector(3 downto 0);
        out_inc_pc                   : out std_logic_vector(31 downto 0);

        -- testing signals

        -- '1' if testbench is taking control now of the memory and regs
        tb_controls                  : in std_logic;

        -- to mem
        tb_mem_rd                    : in std_logic;
        tb_mem_wr                    : in std_logic;
        tb_mem_data_in               : in std_logic_vector(15 downto 0);
        tb_mem_adr                   : in std_logic_vector(31 downto 0);
        -- from mem
        tb_mem_data_out              : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of fetch_stage is
    signal pc           : std_logic_vector(31 downto 0);
    signal len_bit      : std_logic                     := '0';
    signal mem_rd       : std_logic                     := '1';
    signal mem_wr       : std_logic                     := '0';
    signal mem_data_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal mem_data_out : std_logic_vector(15 downto 0) := (others => '0');
    signal inst_store   : std_logic_vector(15 downto 0) := (others => '0');

    --> inst_mem
    signal im_rd        : std_logic;
    signal im_wr        : std_logic;
    signal im_data_in   : std_logic_vector(mem_data_in'range);
    signal im_adr       : std_logic_vector(pc'range);
begin
    inst_mem : entity work.instr_mem(rtl)
        generic map(ADR_LENGTH => 32)
        port map(
            clk      => clk,
            rd       => im_rd,
            wr       => im_wr,
            rst      => rst,
            data_in  => im_data_in,
            address  => im_adr,
            data_out => mem_data_out
        );
    --IN
    im_rd           <= tb_mem_rd when tb_controls = '1' else mem_rd;
    im_wr           <= tb_mem_wr when tb_controls = '1' else mem_wr;
    im_data_in      <= tb_mem_data_in when tb_controls = '1' else mem_data_in;
    im_adr          <= tb_mem_adr when tb_controls = '1' else pc;
    --OUT
    tb_mem_data_out <= mem_data_out;

    out_inc_pc      <= to_vec(to_int(pc) + 1, out_inc_pc'length);

    -- TODO
    --out_interrupt <= ???

    -- TODO
    --out_predicted_address <= ???

    -- TODO
    --out_hashed_address <= ???

    process (clk, rst)
    begin
        if rst = '1' then
            pc           <= (31 => '0', 30 => '0', others => '1');
            mem_data_in  <= (others => '1');
            mem_data_out <= (others => '1');
            len_bit      <= '0';
            mem_rd       <= '1';
            mem_wr       <= '0';
        elsif falling_edge(clk) then
            -- decide PC next address
            if in_if_flush = '1' then
                pc <= (others => '0'); -- to be corrected
            elsif in_parallel_load_pc_selector = '1' then
                pc <= (others => '0'); -- to be corrected
            elsif rst = '1' then
                pc <= (others => '0'); -- to be corrected
            elsif mem_data_out(14 downto 8) = OPC_CALL then
                pc <= (others => '0'); -- to be corrected
            elsif (in_stall = '1' or in_interrupt = '1') then
                pc <= (others => '0'); -- to be corrected
            else
                pc <= std_logic_vector(unsigned(pc) + 1);
            end if;  
            -- instruction output
            -- decide whether the instruction is 16 or 32 bits
            if len_bit = '0' and mem_data_out(15) = '0' then
                out_instruction_bits(31 downto 16) <= mem_data_out;
                out_instruction_bits(15 downto 0)  <= (others => '0');
            elsif len_bit = '0' and mem_data_out(15) = '1' then
                out_instruction_bits <= (others => '0'); -- output NOP
                inst_store <= mem_data_out;
                len_bit <= '1';
            else
                out_instruction_bits(31 downto 16) <= inst_store;
                out_instruction_bits(15 downto 0) <= mem_data_out;
                len_bit <= '0';
            end if;
        end if;
    end process;
end architecture;