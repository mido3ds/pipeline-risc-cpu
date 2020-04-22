library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_mem is
    port (
        clk, rd, wr, rst : in std_logic;
        data_in          : in std_logic_vector(32 - 1 downto 0);
        address          : in std_logic_vector(32 - 1 downto 0);
        data_out         : out std_logic_vector(32 - 1 downto 0)
    );
end entity;

architecture rtl of data_mem is
    constant WORD_LENGTH : integer := 16;
    constant ADR_LENGTH  : integer := 10;
    constant NUM_WORDS   : integer := 1024;

    signal ram_even_adr  : std_logic_vector(ADR_LENGTH - 1 downto 0);
    signal ram_odd_adr   : std_logic_vector(ADR_LENGTH - 1 downto 0);
begin
    -- ram for even addresses
    ram_even_adr <= address(9 downto 0);

    ram_even : entity work.ram
        generic map(WORD_LENGTH => WORD_LENGTH, ADR_LENGTH => ADR_LENGTH, NUM_WORDS => NUM_WORDS)
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
    ram_odd_adr <= std_logic_vector(unsigned(address(9 downto 0)) + 1);

    ram_odd : entity work.ram
        generic map(WORD_LENGTH => WORD_LENGTH, ADR_LENGTH => ADR_LENGTH, NUM_WORDS => NUM_WORDS)
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