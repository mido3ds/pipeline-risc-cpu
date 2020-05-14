library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity instr_mem is
    generic (
        ADR_LENGTH : integer
    );

    port (
        -- wr: write to instr_mem through data_in
        -- rd: read from instr_mem to data_out
        clk, rd, wr : in std_logic;
        -- rst: async 0 parallel load to all latches
        rst         : in std_logic;
        data_in     : in std_logic_vector(MEM_WORD_LENGTH - 1 downto 0);
        address     : in std_logic_vector(ADR_LENGTH - 1 downto 0);
        data_out    : out std_logic_vector(MEM_WORD_LENGTH - 1 downto 0)
    );
end entity;

architecture rtl of instr_mem is
    type DataType is array(0 to MEM_NUM_WORDS - 1) of std_logic_vector(data_in'range);
    signal data : DataType := (
    --%REPLACE%--
    -- please don't remove the previous line; it could be replaced (by a script) 
    -- with the contents of ram before compiling the file
    others => "1110000000000000"
    );
begin
    process (clk, rd, wr, address, data_in, rst)
    begin
        if rst = '1' then
            for i in data'range loop
                data(i) <= "1110000000000000";
            end loop;
        else
            if rd = '1' then
                data_out <= data(to_int(address));
            end if;

            if falling_edge(clk) and wr = '1' then
                data(to_int(address)) <= data_in;
            end if;
        end if;
    end process;
end architecture;