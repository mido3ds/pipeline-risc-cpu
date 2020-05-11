library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity control_unit is
    port (
        ib            : in std_logic_vector(31 downto 0);
        --interrupt           : in std_logic;
        --reset               : in std_logic;

        --OpCode              : out std_logic_vector(6 downto 0);
        aluop         : out std_logic_vector(3 downto 0);
        rsrc1_sel     : out std_logic_vector(3 downto 0);
        rsrc2_sel     : out std_logic_vector(3 downto 0);
        rdst1_sel     : out std_logic_vector(3 downto 0);
        rdst2_sel     : out std_logic_vector(3 downto 0);
        --don't forget the sign extend ya evram!
        rsrc2_val     : out std_logic_vector(31 downto 0);
        op2_sel       : out std_logic;
        branch_io     : out std_logic_vector(1 downto 0);
        branch_enable : out std_logic;
        r_w_control   : out std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of control_unit is
    --sign extend function
    function sign_extend(value : std_logic_vector(15 downto 0)) return std_logic_vector is
        variable return_this       : std_logic_vector(31 downto 0);
    begin
        if (value(15) = '0') then
            return_this(31 downto 16) := X"0000";
            return_this(15 downto 0)  := value;
            return return_this;
        else
            return_this(31 downto 16) := X"FFFF";
            return_this(15 downto 0)  := value;
            return return_this;
        end if;
    end function;
begin
    --base conditions
    --OpCode is simple..
    --OpCode <= ib(31 downto 25);

    --rdst2_sel
    with ib(31 downto 28) select rdst2_sel <=
    '0' & ib(27 downto 25) when "0001", --swap
    "1111" when others;

    --aluop selection
    with ib(31 downto 25) select aluop <=
    "0111" when "1111001", --not
    "0001" when "1111010", --inc
    "0010" when "1111011", --dec
    "0000" when "1111100", --out
    "0000" when "1111000", --in
    "1011" when "0000011", --call
    "1010" when "0000100", --ret
    "1100" when "0000101", --rti
    "0000" when "0000010", --jmp
    "0000" when "0000001", --jz
    "0111" when "0000000", --nop
    "0000" when others;

    with ib(31 downto 28) select aluop <=
    "0000" when "0001", --swap
    "0011" when "0010", --add
    "0100" when "0011", --sub
    "0101" when "0100", --and
    "0110" when "0101", --or
    "1000" when "0110", --shl
    "1001" when "0111", --shr
    "0011" when "1000", --iadd
    "1011" when "1001", --push
    "1010" when "1010", --pop
    "0000" when "1011", --ldm
    "0000" when "1100", --ldd
    "0000" when "1101", --std
    "0000" when others;

    --Rsrc1 selection
    with ib(31 downto 25) select rsrc1_sel <=
    '0' & ib(24 downto 22) when "1111001", --not
    '0' & ib(24 downto 22) when "1111010", --inc
    '0' & ib(24 downto 22) when "1111011", --dec
    '0' & ib(24 downto 22) when "1111100", --out
    '0' & ib(24 downto 22) when "1111000", --in
    "1111" when "0000011",                 --call
    "1111" when "0000100",                 --ret
    "1111" when "0000101",                 --rti
    '0' & ib(27 downto 25) when "0000010", --jmp
    '0' & ib(27 downto 25) when "0000001", --jz
    "1111" when "0000000",                 --nop
    "1111" when others;

    with ib(31 downto 28) select rsrc1_sel <=
    '0' & ib(27 downto 25) when "0001", --swap
    '0' & ib(27 downto 25) when "0010", --add
    '0' & ib(27 downto 25) when "0011", --sub
    '0' & ib(27 downto 25) when "0100", --and
    '0' & ib(27 downto 25) when "0101", --or
    '0' & ib(27 downto 25) when "0110", --shl
    '0' & ib(27 downto 25) when "0111", --shr
    '0' & ib(27 downto 25) when "1000", --iadd
    '0' & ib(27 downto 25) when "1001", --push
    "1111" when "1010",                 --pop
    "1111" when "1011",                 --ldm
    --'0' & ib(27 downto 25) when "1100", --ldd
    "1111" when "1100",                 --ldd
    "1111" when "1101",                 --std
    "1111" when others;

    --Rsrc2 selection
    with ib(31 downto 28) select rsrc2_sel <=
    '0' & ib(24 downto 22) when "0010", --add
    '0' & ib(24 downto 22) when "0011", --sub
    '0' & ib(24 downto 22) when "0100", --and
    '0' & ib(24 downto 22) when "0101", --or
    '0' & ib(24 downto 22) when "0001", --swap
    "1000" when "1001",                 --push
    "1000" when "1010",                 --pop
    "1111" when others;

    with ib(31 downto 25) select rsrc2_sel <=
    "1000" when "0000011", --call
    "1000" when "0000100", --ret
    "1000" when "0000101", --rti
    "1111" when others;

    --rdst1_sel
    with ib(31 downto 25) select rdst1_sel <=
    '0' & ib(24 downto 22) when "1111001", --not
    '0' & ib(24 downto 22) when "1111010", --inc
    '0' & ib(24 downto 22) when "1111011", --dec
    '0' & ib(24 downto 22) when "1111100", --out
    '0' & ib(24 downto 22) when "1111000", --in
    '0' & ib(27 downto 25) when "0000011", --call

    "1111" when others;

    with ib(31 downto 28) select rdst1_sel <=
    '0' & ib(21 downto 19) when "0010", --add
    '0' & ib(21 downto 19) when "0011", --sub
    '0' & ib(21 downto 19) when "0100", --and
    '0' & ib(21 downto 19) when "0101", --or
    '0' & ib(24 downto 22) when "1000", --iadd
    '0' & ib(27 downto 25) when "0110", --shl
    '0' & ib(27 downto 25) when "0111", --shr
    '0' & ib(27 downto 25) when "1011", --ldm
    --"1111" when "1100", --ldd
    '0' & ib(27 downto 25) when "1100", --ldd
    '0' & ib(27 downto 25) when "1101", --std
    "1111" when "1001",                 --push
    '0' & ib(27 downto 25) when "1010", --pop
    '0' & ib(24 downto 22) when "0001", --swap

    "1111" when others;

    with ib(31 downto 28) select rsrc2_val <=
    --IMM
    sign_extend(ib(15 downto 0)) when "1000", --iadd
    sign_extend(ib(15 downto 0)) when "0110", --shl
    sign_extend(ib(15 downto 0)) when "0111", --shr
    sign_extend(ib(15 downto 0)) when "1011", --ldm
    --EA
    X"000" & ib(19 downto 0) when "1100",     --ldd
    X"000" & ib(19 downto 0) when "1101",     --std

    X"00000000" when others;

    --which output to expect, the reg_file or our ea/imm
    with ib(31 downto 28) select op2_sel <=
    '1' when "1000", --iadd
    '1' when "0110", --shl
    '1' when "0111", --shr
    '1' when "1011", --ldm
    '1' when "1100", --ldd
    '1' when "1101", --std
    '0' when others;

    with ib(31 downto 25) select branch_io <=
    "01" when "1111100", --out
    "10" when "1111000", --in
    "11" when "0000010", --jmp
    "11" when "0000001", --jz
    "00" when others;
    with ib(31 downto 25) select branch_enable <=
    '1' when "0000001", --jz
    '0' when others;

    with ib(31 downto 25) select r_w_control <=
    "11" when "0000011", --call
    "10" when "0000100", --ret
    "10" when "0000101", --rti
    "00" when others;

    with ib(31 downto 28) select r_w_control <=
    "11" when "1011", --ldm
    "10" when "1100", --ldd
    "11" when "1101", --std
    "11" when "1001", --push
    "10" when "1010", --pop
    "00" when others;
end architecture;