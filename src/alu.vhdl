library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity alu is
    port (
        -- TODO: assumed no clk
        op   : in std_logic_vector(3 downto 0);
        a, b : in std_logic_vector(31 downto 0);
        ccr  : out std_logic_vector(2 downto 0);
        c    : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of alu is
begin
    process (a, b, op)
        variable a2, b2 : unsigned(32 downto 0);
        variable c2     : unsigned(32 downto 0);
        variable c3     : std_logic_vector(c2'range);
    begin
        if op /= ALUOP_NOP then
            a2 := resize(unsigned(a), 33);
            b2 := resize(unsigned(b), 33);
            c2 := to_unsigned(0, c2'length);

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
                when ALUOP_AND => c2 := a2 and b2;
                when ALUOP_OR  => c2  := a2 or b2;
                when ALUOP_NOT => c2 := not a2;
                when ALUOP_SHL =>
                    c2 := shift_left(a2, to_int(b2));
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_SHR =>
                    c2 := shift_right(a2, to_int(b2));
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_INC2 =>
                    c2 := b2 + 1;
                    ccr(CCR_CARRY) <= c2(32);
                when ALUOP_DEC2 =>
                    c2 := b2 - 1;
                    ccr(CCR_CARRY) <= c2(32);
                when others => report "invalid op = " & to_str(op) severity warning;
            end case;

            c3 := std_logic_vector(c2);

            ccr(CCR_ZERO) <= to_std_logic(c3(31 downto 0) = to_vec(0, 32));
            ccr(CCR_NEG)  <= c2(31);

            c             <= c3(31 downto 0);
        end if;
    end process;
end architecture;