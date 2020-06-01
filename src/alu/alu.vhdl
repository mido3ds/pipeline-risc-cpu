library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity alu is
    port (
        op     : in  std_logic_vector(3  downto 0);
        a      : in  std_logic_vector(31 downto 0);
        b      : in  std_logic_vector(31 downto 0);
        ccr_in : in  std_logic_vector(2  downto 0);
        ccr    : out std_logic_vector(2  downto 0);
        c      : out std_logic_vector(31 downto 0);
        c_2    : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of alu is
begin
    process (a, b, op, ccr_in)
        variable a2, b2 : unsigned(32 downto 0);
        variable c2     : unsigned(32 downto 0);
        variable c2_2   : unsigned(32 downto 0);
        variable c3     : std_logic_vector(c2'range);
        variable c4     : std_logic_vector(c2_2'range);
    begin
        if op /= ALUOP_NOP then
            a2   := resize(unsigned(a), 33);
            b2   := resize(unsigned(b), 33);
            c2   := to_unsigned(0, c2'length);
            c2_2 := to_unsigned(0, c2_2'length);
            case op is
                when ALUOP_INC =>
                    c2 := a2 + 1;
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_DEC =>
                    c2 := a2 - 1;
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_ADD =>
                    c2 := a2 + b2;
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_SUB =>
                    c2 := a2 - b2;
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_AND => c2 := a2 and b2; ccr(CCR_CARRY) <= ccr_in(CCR_CARRY);
                when ALUOP_OR  => c2  := a2 or b2; ccr(CCR_CARRY) <= ccr_in(CCR_CARRY);
                when ALUOP_NOT => c2 := not a2;    ccr(CCR_CARRY) <= ccr_in(CCR_CARRY);
                when ALUOP_SHL =>
                    c2 := shift_left(a2, to_int(b2));
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_SHR =>
                    c2 := shift_right(a2, to_int(b2));
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_INC2 =>
                    c2 := a2 + 2;
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_DEC2 =>
                    c2 := a2 - 2;
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_SWAP =>
                    c2   := b2;
                    c2_2 := a2;
                when others => null;
            end case;

            c3 := std_logic_vector(c2);
            c4 := std_logic_vector(c2_2);

            if ( c3(31 downto 0) = "00000000000000000000000000000000") then
                ccr(CCR_ZERO) <= '1';
            else
                ccr(CCR_ZERO) <= '0';
            end if;
            if (c3(31) = '1') then
                ccr(CCR_NEG) <= '1';
            else
                ccr(CCR_NEG) <= '0';
            end if;
            --ccr(1)  <= c2(31);

            c             <= c3(31 downto 0);
            c_2           <= c4(31 downto 0);
        end if;
    end process;
end architecture;