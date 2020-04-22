library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common is
    -- opcodes
    constant OPC_RET              : std_logic_vector(6 downto 0) := "0000100";
    constant OPC_RTI              : std_logic_vector(6 downto 0) := "0000101";

    function opcode_is_branch(opc : std_logic_vector) return boolean;

    function to_vec(i : integer; size : integer          := 16) return std_logic_vector;
    function to_vec(i : std_logic; size : integer        := 16) return std_logic_vector;
    function to_vec(i : std_logic_vector; size : integer := 16) return std_logic_vector;
    function u_to_vec(i : unsigned; size : integer       := 16) return std_logic_vector;

    function to_std_logic(i       : integer) return std_logic;
    function to_std_logic(i       : boolean) return std_logic;

    function to_int(i             : std_logic_vector) return integer;
    function to_int(i             : unsigned) return integer;
    function to_int(i             : std_logic) return integer;

    function to_str(a             : std_logic_vector) return string;
    function to_str(a             : unsigned) return string;
    function to_str(a             : integer) return string;
    function to_str(a             : std_logic) return string;

    function flip(v               : std_logic_vector) return std_logic_vector;
    function multiply2(i          : std_logic_vector) return std_logic_vector;
end package;

package body common is
    function opcode_is_branch(opc : std_logic_vector) return boolean is
    begin
        if opc'length < 4 then
            return false;
        end if;

        return opc(opc'left downto opc'left - 4 + 1) = "0000";
    end function;

    function to_vec(i : integer; size : integer := 16) return std_logic_vector is
        variable tmp : unsigned(size - 1 downto 0);
    begin
        if i < 0 then
            tmp := to_unsigned(-i, size);
            tmp := not tmp;
            tmp := tmp + 1;
        else
            tmp := to_unsigned(i, size);
        end if;

        return std_logic_vector(tmp);
    end function;

    function to_vec(i : std_logic; size : integer := 16) return std_logic_vector is
        variable v : std_logic_vector(size - 1 downto 0);
    begin
        v := (others => i);
        return v;
    end function;

    function to_vec(i : std_logic_vector; size : integer := 16) return std_logic_vector is
        variable v : std_logic_vector(size - 1 downto 0)     := i;
    begin
        return v;
    end function;

    function u_to_vec(i : unsigned; size : integer := 16) return std_logic_vector is
    begin
        return std_logic_vector(i);
    end function;

    function to_str(a : std_logic_vector) return string is
        variable b        : string (1 to a'length) := (others => NUL);
        variable stri     : integer                := 1;
    begin
        for i in a'range loop
            b(stri) := std_logic'image(a((i)))(2);
            stri    := stri + 1;
        end loop;

        return b;
    end function;

    function to_str(a : unsigned) return string is
    begin
        return to_str(std_logic_vector(a));
    end function;

    function to_str(a : integer) return string is
    begin
        return integer'image(a);
    end function;

    function to_str(a : std_logic) return string is
    begin
        return std_logic'image(a);
    end function;

    function to_int(i : std_logic_vector) return integer is
    begin
        return to_integer(unsigned(i));
    end function;

    function to_int(i : std_logic) return integer is
    begin
        if i = '0' then
            return 0;
        end if;

        return 1;
    end function;

    function to_int(i : unsigned) return integer is
    begin
        return to_integer(i);
    end function;

    function flip (v  : std_logic_vector) return std_logic_vector is
        alias rev_range_v : std_logic_vector(v'reverse_range) is v;
        variable rev_v    : std_logic_vector(v'range);
    begin
        for i in rev_range_v'range loop
            rev_v(i) := rev_range_v(i);
        end loop;

        return rev_v;
    end;

    function to_std_logic(i : integer) return std_logic is
    begin
        if i = 1 then
            return '1';
        end if;

        return '0';
    end function;

    function to_std_logic(i : boolean) return std_logic is
    begin
        if i then
            return '1';
        end if;

        return '0';
    end function;

    function multiply2(i : std_logic_vector) return std_logic_vector is
    begin
        return std_logic_vector(shift_left(unsigned(i), 1));
    end function;
end package body;