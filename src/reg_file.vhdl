library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity reg_file is
    port (
        dst0_adr    : in std_logic_vector(3 downto 0); -- DST
        dst1_adr    : in std_logic_vector(3 downto 0);
        src0_adr    : in std_logic_vector(3 downto 0); -- SRC
        src1_adr    : in std_logic_vector(3 downto 0);
        fetch_adr   : in std_logic_vector(3 downto 0);  -- FETCH

        wb0_value   : in std_logic_vector(31 downto 0); -- WB
        wb1_value   : in std_logic_vector(31 downto 0);

        in_value    : in std_logic_vector(31 downto 0); -- IO

        rst         : in std_logic;
        clk         : in std_logic;

        -- TODO: what to do in nop state?
        -- asume it's writing 
        br_io_nop   : in std_logic_vector(1 downto 0);   -- STATE

        op0_value   : out std_logic_vector(31 downto 0); -- OP
        op1_value   : out std_logic_vector(31 downto 0);

        fetch_value : out std_logic_vector(31 downto 0);
        instr_adr   : out std_logic_vector(31 downto 0);

        out_value   : out std_logic_vector(31 downto 0) -- IO
    );
end entity;

architecture rtl of reg_file is
    -- why don't i put them in an array? because arrays don't appear in ghdl signals dump.
    signal r0, r1, r2, r3, r4, r5, r6, r7, sp, pc : std_logic_vector(31 downto 0);

    -- TODO: what is the address of the IO?
    -- assume it is dst0_adr
    alias io_adr is dst0_adr;
begin
    process (rst)
        procedure out_reg(adr : std_logic_vector(3 downto 0); signal o : out std_logic_vector(31 downto 0)) is
        begin
            case adr is
                when x"0"   => o <= r0;
                when x"1"   => o <= r1;
                when x"2"   => o <= r2;
                when x"3"   => o <= r3;
                when x"4"   => o <= r4;
                when x"5"   => o <= r5;
                when x"6"   => o <= r6;
                when x"7"   => o <= r7;
                when x"8"   => o <= sp;
                when x"9"   => o <= pc;
                when others => report "invalid adr" severity warning;
            end case;
        end procedure;

        procedure in_reg(adr : std_logic_vector(3 downto 0); constant i : std_logic_vector(31 downto 0)) is
        begin
            case adr is
                when x"0"   => r0 <= i;
                when x"1"   => r1 <= i;
                when x"2"   => r2 <= i;
                when x"3"   => r3 <= i;
                when x"4"   => r4 <= i;
                when x"5"   => r5 <= i;
                when x"6"   => r6 <= i;
                when x"7"   => r7 <= i;
                when x"8"   => sp <= i;
                when x"9"   => pc <= i;
                when others => report "invalid adr" severity warning;
            end case;
        end procedure;
    begin
        if rst = '1' then
            for i in 0 to 9 loop
                in_reg(to_vec(i, 4), to_vec(0, 32));
            end loop;
        elsif rising_edge(clk) then
            -- out
            out_reg(src0_adr, op0_value);
            out_reg(src1_adr, op1_value);
            out_reg(fetch_adr, fetch_value);

            case br_io_nop is
                when "00" =>
                    -- BRANCH
                    -- TODO: what to do in branch? output the whole pc?
                    instr_adr <= pc;
                when "01" =>
                    -- IO
                    out_reg(io_adr, out_value);
                when others =>
                    -- NOP
                    -- TODO: what to do in nop?
                    null;
            end case;
        elsif falling_edge(clk) then
            -- in
            in_reg(dst0_adr, wb0_value);
            in_reg(dst1_adr, wb1_value);

            case br_io_nop is
                when "00" =>
                    -- BRANCH
                    -- TODO: what to do in branch?
                when "01" =>
                    -- IO
                    in_reg(io_adr, in_value);
                when others =>
                    -- NOP
                    -- TODO: what to do in nop?
                    null;
            end case;
        end if;
    end process;
end architecture;