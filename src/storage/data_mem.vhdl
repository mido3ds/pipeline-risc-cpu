library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity data_mem is
    generic (
        ADR_LENGTH : integer
    );

    port (
        clk, rd, wr, rst : in std_logic;
        is_stack         : in std_logic;
        data_in          : in std_logic_vector(32 - 1 downto 0);
        address          : in std_logic_vector(ADR_LENGTH - 1 downto 0);
        data_out         : out std_logic_vector(32 - 1 downto 0)
    );
end entity;

architecture rtl of data_mem is
    constant WORD_LENGTH : integer := 16;
    signal ram_even_adr  : std_logic_vector(ADR_LENGTH - 1 downto 0);
    signal ram_odd_adr   : std_logic_vector(ADR_LENGTH - 1 downto 0);
begin
    -- ram for even addresses
    ram_even_adr <= address;

    ram_even : entity work.ram
        generic map(WORD_LENGTH => WORD_LENGTH, ADR_LENGTH => ADR_LENGTH, NUM_WORDS => MEM_NUM_WORDS)
        port map(
            rd       => rd,
            wr       => wr,
            rst      => rst,
            address  => ram_even_adr,
            clk      => clk,
            data_in  => data_in(31 downto 16),
            data_out => data_out(31 downto 16)
        );

    -- ram for odd addresses
    ram_odd_adr <= std_logic_vector(unsigned(address) + 1) when is_stack = '0' else std_logic_vector(unsigned(address) - 1);

    ram_odd : entity work.ram
        generic map(WORD_LENGTH => WORD_LENGTH, ADR_LENGTH => ADR_LENGTH, NUM_WORDS => MEM_NUM_WORDS)
        port map(
            rd       => rd,
            wr       => wr,
            rst      => rst,
            address  => ram_odd_adr,
            clk      => clk,
            data_in  => data_in(15 downto 0),
            data_out => data_out(15 downto 0)
        );

    -- assert process
    process (address)
    begin
        assert unsigned(address) mod 2 = 0 report "address input is odd, this violates design" severity warning;
    end process;
end architecture;