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
    signal data : DataType;
begin
    process (clk, rd, wr, address, data_in, rst)
        -- vhdl cant cast 32bit (but instead 31bits) to integers
        variable safe_adr : std_logic_vector(30 downto 0) := (others => '0');
    begin
        if rst = '1' then
            for i in data'range loop
                data(i) <= "0000000000000000";
            end loop;
        else
            if address'length >= 32 then
                safe_adr := address(30 downto 0);
            else
                safe_adr(address'range) := address;
            end if;

            if unsigned(safe_adr) >= MEM_NUM_WORDS then
                report "address=" & to_str(to_int(safe_adr)) & " exceeds MEM_NUM_WORDS=" & to_str(MEM_NUM_WORDS) severity warning;
            else
                if rd = '1' then
                    data_out <= data(to_int(safe_adr));
                end if;

                if falling_edge(clk) and wr = '1' then
                    data(to_int(safe_adr)) <= data_in;
                end if;
            end if;
        end if;
    end process;
end architecture;