library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity control_unit is
    port (
        ib            : in  std_logic_vector(31 downto 0);
        in_port_value : in  std_logic_vector(31 downto 0);                  -- the in port value to be used in case of IN operation
        incremented_pc: in  std_logic_vector(31 downto 0);
        intr_bit      : in  std_logic;
        --interrupt           : in std_logic;
        --reset               : in std_logic;

        --OpCode              : out std_logic_vector(6 downto 0);
        aluop         : out std_logic_vector(3  downto 0);
        rsrc1_sel     : out std_logic_vector(3  downto 0);
        rsrc2_sel     : out std_logic_vector(3  downto 0);
        rdst1_sel     : out std_logic_vector(3  downto 0);
        rdst2_sel     : out std_logic_vector(3  downto 0);
        --don't forget the sign extend ya evram!
        rsrc2_val     : out std_logic_vector(31 downto 0);
        op2_sel       : out std_logic;
        --branch_io     : out std_logic_vector(1  downto 0);
        --branch_enable : out std_logic;
        r_w_control   : out std_logic_vector(1  downto 0);
        hlt           : out std_logic
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
    hlt <= '1' when ib(31 downto 25) = OPC_END else '0';
    --aluop selection
    with ib(31 downto 25) select aluop <=
    ALUOP_NOT  when OPC_NOT, --not
    ALUOP_INC  when OPC_INC, --inc
    ALUOP_DEC  when OPC_DEC, --dec
    --"0000"   when "1111100", --out
    --"0000"   when "1111000", --in
    ALUOP_DEC2 when OPC_CALL, --call
    ALUOP_INC2 when OPC_RET, --ret
    ALUOP_INC2 when OPC_RTI, --rti
    --"0000" when "0000010", --jmp
    --"0000" when "0000001", --jz
    --"0111" when "0000000", --nop
    ALUOP_NOP when others;

    with ib(31 downto 28) select aluop <=
    --"0000" when "0001", --swap
    ALUOP_ADD  when OPC_ADD, --add
    ALUOP_SUB  when OPC_SUB, --sub
    ALUOP_AND  when OPC_AND, --and
    ALUOP_OR   when OPC_OR, --or
    ALUOP_SHL  when OPC_SHL, --shl
    ALUOP_SHR  when OPC_SHR, --shr
    ALUOP_ADD  when OPC_IADD, --iadd
    ALUOP_DEC2 when OPC_PUSH, --push
    ALUOP_INC2 when OPC_POP, --pop
    --"0000" when "1011", --ldm
    --"0000" when "1100", --ldd
    --"0000" when "1101", --std
    ALUOP_NOP when others;

    -----------------------------------------------------------------------------------------------------------------------------
    --Rsrc1 selection
    with ib(31 downto 25) select rsrc1_sel <=
    '0' & ib(24 downto 22) when OPC_NOT, --not
    '0' & ib(24 downto 22) when OPC_INC, --inc
    '0' & ib(24 downto 22) when OPC_DEC, --dec
    '0' & ib(24 downto 22) when OPC_OUT, --out
    --'0' & ib(24 downto 22) when "1111000", --in              -- no need for that
    SP                     when OPC_CALL, --call            -- must be sp
    SP                     when OPC_RET, --ret             -- mut be sp
    SP                     when OPC_RTI, --rti             -- must be sp
    '0' & ib(27 downto 25) when OPC_JMP, --jmp             -- no need for that ?
    '0' & ib(27 downto 25) when OPC_JZ, --jz              -- no need for that ?
    --"1111"                 when OPC_NOP,                 --nop
    "1111"                 when others;

    with ib(31 downto 28) select rsrc1_sel <=
    '0' & ib(27 downto 25) when OPC_SWAP, --swap
    '0' & ib(27 downto 25) when OPC_ADD,  --add
    '0' & ib(27 downto 25) when OPC_SUB,  --sub
    '0' & ib(27 downto 25) when OPC_AND,  --and
    '0' & ib(27 downto 25) when OPC_OR,   --or
    '0' & ib(27 downto 25) when OPC_SHL,  --shl
    '0' & ib(27 downto 25) when OPC_SHR,  --shr
    '0' & ib(27 downto 25) when OPC_IADD, --iadd
    SP                     when OPC_PUSH, --push               -- source must be sp :\
    SP                     when OPC_POP,  --pop                -- source must be sp :\
    --"1111"                 when "1011", --ldm
    --'0' & ib(27 downto 25) when "1100", --ldd
    --"1111"                 when "1100", --ldd
    '0' & ib(27 downto 25) when OPC_STD, --std
    "1111"                 when others;

    --Rsrc2 selection
    with ib(31 downto 28) select rsrc2_sel <=
    '0' & ib(24 downto 22) when OPC_ADD,  --add
    '0' & ib(24 downto 22) when OPC_SUB,  --sub
    '0' & ib(24 downto 22) when OPC_AND,  --and
    '0' & ib(24 downto 22) when OPC_OR,   --or
    '0' & ib(24 downto 22) when OPC_SWAP, --swap
    '0' & ib(27 downto 25) when OPC_PUSH, --push
    --'0' & ib(27 downto 25) when OPC_STD,  -- std
    --"1000" when "1010",                 --pop                -- don't care
    "1111"                 when others;

    ------------------------------------------------------------------------------------------------------------------------------
    --rdst1_sel
    with ib(31 downto 25) select rdst1_sel <=
    '0' & ib(24 downto 22) when OPC_NOT, --not
    '0' & ib(24 downto 22) when OPC_INC, --inc
    '0' & ib(24 downto 22) when OPC_DEC, --dec
    "1110"                 when OPC_OUT, --out             -- so main out the src_1_value on out port signal
    '0' & ib(24 downto 22) when OPC_IN,  --in
    SP                     when OPC_CALL, --call            -- destination must be sp
    "1111"                 when others;

    with ib(31 downto 28) select rdst1_sel <=
    '0' & ib(21 downto 19) when OPC_ADD,  --add
    '0' & ib(21 downto 19) when OPC_SUB,  --sub
    '0' & ib(21 downto 19) when OPC_AND,  --and
    '0' & ib(21 downto 19) when OPC_OR,   --or
    '0' & ib(24 downto 22) when OPC_IADD, --iadd
    '0' & ib(27 downto 25) when OPC_SHL,  --shl
    '0' & ib(27 downto 25) when OPC_SHR,  --shr
    '0' & ib(27 downto 25) when OPC_LDM,  --ldm
    --"1111" when "1100", --ldd
    --'0' & ib(27 downto 25) when "1100", --ldd                 -- must be 1111
    SP                     when OPC_PUSH, --push                -- destination must be sp
    SP                     when OPC_POP,  --pop                 -- destination must be sp
    '0' & ib(27 downto 25) when OPC_SWAP, --swap                -- destination must be the source

    "1111"                 when others;

    --rdst2_sel
    with ib(31 downto 28) select rdst2_sel <=
    '0' & ib(24 downto 22) when OPC_SWAP, --swap                -- destination must be the destination
    '0' & ib(27 downto 25) when OPC_LDD,  -- LDD                -- memory operation out on dest_2 operation
    '0' & ib(27 downto 25) when OPC_POP,  -- pop                -- second destination must be the destination
    "1111"                 when others;

    -----------------------------------------------------------------------------------------------------------------

    with ib(31 downto 28) select rsrc2_val <=
    --IMM
    sign_extend(ib(21 downto 6)) when OPC_IADD, --iadd
    sign_extend(ib(24 downto 9)) when OPC_SHL, --shl
    sign_extend(ib(24 downto 9)) when OPC_SHR, --shr
    sign_extend(ib(24 downto 9)) when OPC_LDM, --ldm
    --EA
    X"000" & ib(24 downto 5)     when OPC_LDD,     --ldd
    X"000" & ib(24 downto 5)     when OPC_STD,     --std

    X"00000000"                  when others;

    -- in case of in operation
    with ib(31 downto 25) select rsrc2_val <=
    in_port_value                when OPC_IN,
    incremented_pc               when OPC_CALL,
    X"00000000"                  when others;

    --which output to expect, the reg_file or our ea/imm
    with ib(31 downto 28) select op2_sel <=
    '1' when OPC_IADD, --iadd
    '1' when OPC_SHL, --shl
    '1' when OPC_SHR, --shr
    '1' when OPC_LDM, --ldm
    '1' when OPC_LDD, --ldd
    '1' when OPC_STD, --std
    '0' when others;

    with ib(31 downto 25) select op2_sel <=
    '1' when OPC_CALL,
    '1' when OPC_IN,
    '0' when others;

    op2_sel                              <= '1' when intr_bit = '1' else '0';
    rsrc2_val                            <= incremented_pc when intr_bit = '1' else X"00000000" ;
  --  with ib(31 downto 25) select branch_io <=
  --  "01" when "1111100", --out
  --  "10" when "1111000", --in
  --  "11" when "0000010", --jmp
  --  "11" when "0000001", --jz
  --  "00" when others;
  --  with ib(31 downto 25) select branch_enable <=
  --  '1' when "0000001", --jz
  --  '0' when others;

    -- what 11 stands for ?  00 : NO OP , 01: read , 10 : write

    with ib(31 downto 25) select r_w_control <=
    "10" when OPC_CALL, --call
    "01" when OPC_RET,  --ret
    "01" when OPC_RTI,  --rti
    "00" when others;

    with ib(31 downto 28) select r_w_control <=
    --"11" when "1011", --ldm
    "01" when OPC_LDD,  --ldd
    "10" when OPC_STD,  --std
    "10" when OPC_PUSH, --push
    "01" when OPC_POP,  --pop
    "00" when others;
end architecture;