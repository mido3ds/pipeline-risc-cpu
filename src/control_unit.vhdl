library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity control_unit is
    port (
        IB            : in std_logic_vector(31 downto 0);
        --interrupt           : in std_logic;
        --reset               : in std_logic;

        --OpCode              : out std_logic_vector(6 downto 0);
        ALUOp         : out std_logic_vector(3 downto 0);
        Rsrc1_sel     : out std_logic_vector(3 downto 0);
        Rsrc2_sel     : out std_logic_vector(3 downto 0);
        Rdst1_sel     : out std_logic_vector(3 downto 0);
        Rdst2_sel     : out std_logic_vector(3 downto 0);
        --don't forget the sign extend ya evram!
        Rsrc2_val     : out std_logic_vector(31 downto 0);
        Op2_sel       : out std_logic;
        Branch_IO     : out std_logic_vector(1 downto 0);
        Branch_enable : out std_logic;
        R_W_control   : out std_logic_vector(1 downto 0)
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
    --OpCode <= IB(31 downto 25);

    --Rdst2_sel
    with IB(31 downto 28) select Rdst2_sel <=
    '0' & IB(27 downto 25) when "0001", --swap
    "1111" when others;

    --ALUOp selection
    with IB(31 downto 25) select ALUOp <=
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

    with IB(31 downto 28) select ALUOp <=
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
    with IB(31 downto 25) select Rsrc1_sel <=
    '0' & IB(24 downto 22) when "1111001", --not
    '0' & IB(24 downto 22) when "1111010", --inc
    '0' & IB(24 downto 22) when "1111011", --dec
    '0' & IB(24 downto 22) when "1111100", --out
    '0' & IB(24 downto 22) when "1111000", --in
    "1111" when "0000011",                 --call
    "1111" when "0000100",                 --ret
    "1111" when "0000101",                 --rti
    '0' & IB(27 downto 25) when "0000010", --jmp
    '0' & IB(27 downto 25) when "0000001", --jz
    "1111" when "0000000",                 --nop
    "1111" when others;

    with IB(31 downto 28) select Rsrc1_sel <=
    '0' & IB(27 downto 25) when "0001", --swap
    '0' & IB(27 downto 25) when "0010", --add
    '0' & IB(27 downto 25) when "0011", --sub
    '0' & IB(27 downto 25) when "0100", --and
    '0' & IB(27 downto 25) when "0101", --or
    '0' & IB(27 downto 25) when "0110", --shl
    '0' & IB(27 downto 25) when "0111", --shr
    '0' & IB(27 downto 25) when "1000", --iadd
    '0' & IB(27 downto 25) when "1001", --push
    "1111" when "1010",                 --pop
    "1111" when "1011",                 --ldm
    --'0' & IB(27 downto 25) when "1100", --ldd
    "1111" when "1100",                 --ldd
    "1111" when "1101",                 --std
    "1111" when others;

    --Rsrc2 selection
    with IB(31 downto 28) select Rsrc2_sel <=
    '0' & IB(24 downto 22) when "0010", --add
    '0' & IB(24 downto 22) when "0011", --sub
    '0' & IB(24 downto 22) when "0100", --and
    '0' & IB(24 downto 22) when "0101", --or
    '0' & IB(24 downto 22) when "0001", --swap
    "1000" when "1001",                 --push
    "1000" when "1010",                 --pop
    "1111" when others;

    with IB(31 downto 25) select Rsrc2_sel <=
    "1000" when "0000011", --call
    "1000" when "0000100", --ret
    "1000" when "0000101", --rti
    "1111" when others;

    --Rdst1_sel
    with IB(31 downto 25) select Rdst1_sel <=
    '0' & IB(24 downto 22) when "1111001", --not
    '0' & IB(24 downto 22) when "1111010", --inc
    '0' & IB(24 downto 22) when "1111011", --dec
    '0' & IB(24 downto 22) when "1111100", --out
    '0' & IB(24 downto 22) when "1111000", --in
    '0' & IB(27 downto 25) when "0000011", --call

    "1111" when others;

    with IB(31 downto 28) select Rdst1_sel <=
    '0' & IB(21 downto 19) when "0010", --add
    '0' & IB(21 downto 19) when "0011", --sub
    '0' & IB(21 downto 19) when "0100", --and
    '0' & IB(21 downto 19) when "0101", --or
    '0' & IB(24 downto 22) when "1000", --iadd
    '0' & IB(27 downto 25) when "0110", --shl
    '0' & IB(27 downto 25) when "0111", --shr
    '0' & IB(27 downto 25) when "1011", --ldm
    --"1111" when "1100", --ldd
    '0' & IB(27 downto 25) when "1100", --ldd
    '0' & IB(27 downto 25) when "1101", --std
    "1111" when "1001",                 --push
    '0' & IB(27 downto 25) when "1010", --pop
    '0' & IB(24 downto 22) when "0001", --swap

    "1111" when others;

    with IB(31 downto 28) select Rsrc2_val <=
    --IMM
    sign_extend(IB(15 downto 0)) when "1000", --iadd
    sign_extend(IB(15 downto 0)) when "0110", --shl
    sign_extend(IB(15 downto 0)) when "0111", --shr
    sign_extend(IB(15 downto 0)) when "1011", --ldm
    --EA
    X"000" & IB(19 downto 0) when "1100",     --ldd
    X"000" & IB(19 downto 0) when "1101",     --std

    X"00000000" when others;

    --which output to expect, the reg_file or our ea/imm
    with IB(31 downto 28) select Op2_sel <=
    '1' when "1000", --iadd
    '1' when "0110", --shl
    '1' when "0111", --shr
    '1' when "1011", --ldm
    '1' when "1100", --ldd
    '1' when "1101", --std
    '0' when others;

    with IB(31 downto 25) select Branch_IO <=
    "01" when "1111100", --out
    "10" when "1111000", --in
    "11" when "0000010", --jmp
    "11" when "0000001", --jz
    "00" when others;
    with IB(31 downto 25) select Branch_enable <=
    '1' when "0000001", --jz
    '0' when others;

    with IB(31 downto 25) select R_W_control <=
    "11" when "0000011", --call
    "10" when "0000100", --ret
    "10" when "0000101", --rti
    "00" when others;

    with IB(31 downto 28) select R_W_control <=
    "11" when "1011", --ldm
    "10" when "1100", --ldd
    "11" when "1101", --std
    "11" when "1001", --push
    "10" when "1010", --pop
    "00" when others;
end architecture;