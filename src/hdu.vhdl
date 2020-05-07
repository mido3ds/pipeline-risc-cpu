library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity hdu is
    port (
        opcode_decode                       : in std_logic_vector(6 downto 0);
        opcode_execute                      : in std_logic_vector(6 downto 0);
        opcode_memory                       : in std_logic_vector(6 downto 0);
        decode_src_reg_1                    : in std_logic_vector(3 downto 0);
        decode_src_reg_2                    : in std_logic_vector(3 downto 0);
        exe_dst_reg                         : in std_logic_vector(3 downto 0);
        mem_dst_reg                         : in std_logic_vector(3 downto 0);
        ALU_selction                        : out std_logic;
        operand_1_select                    : out std_logic_vector(1 downto 0);
        operand_2_select                    : out std_logic_vector(1 downto 0);
        Stall_signal                        : out std_logic
    );
end entity;

--MAIN LOGIC:

--does opcode_decode need a RSC? DO WE READ
--      NOP/POP/LDM/LDD/RET/RTI/IN...don't
--      SRC_HAZARD = 1

--IF SRC_HAZARD = 0...no hazards..out zeros

--does opcode_execute WB? DO WE WRITE
--      JZ/JMP/CALL/RET/RTI/PUSH/STD/OUT...don't
--      DST1_HAZARD = 1

--does opcode_memory WB? DO WE WRITE
--      JZ/JMP/CALL/RET/RTI/PUSH/STD/OUT...don't
--      DST2_HAZARD = 1

--does decode_src_reg_1 == exe_dst_reg--->EQ1 = 1
--does decode_src_reg_1 == mem_dst_reg--->EQ2 = 1
--does decode_src_reg_2 == exe_dst_reg--->EQ3 = 1
--does decode_src_reg_2 == mem_dst_reg--->EQ4 = 1

--if all the previous are TRUE.. SRC_HAZARD && DST1_HAZARD && DST2_HAZARD


--check for Load use case..
--if opcode_execute is LDD/POP and EQ1 or EQ3
--Raise STALL

--if no stall...
--detect EQ1,2,3,4 and send op_selectors and alu_Selectors accordingly...



architecture rtl of hdu is

--This function returns 1 if the OPCODE sent will NOT cause a Data hazards
    function source_hazard( OPCODE : std_logic_vector(6 downto 0))
                            return std_logic is
        begin

            if (    OPCODE              = "0000000" --nop
                or  OPCODE(6 downto 3)  = "1010" --pop
                or  OPCODE(6 downto 3)  = "1011" --ldm
                or  OPCODE(6 downto 3)  = "1100" --ldd
                or  OPCODE              = "0000100" --ret
                or  OPCODE              = "0000101" --rti
                or  OPCODE              = "1111000" --in
                ) then
                    return '1';
                else
                    return '0';
            end if;
        end function;

--these instructions JZ/JMP/CALL/RET/RTI/PUSH/STD/OUT will not cause data dependency at the destination part
    function destination_hazard( OPCODE : std_logic_vector(6 downto 0))
                            return std_logic is
        begin

            if (    OPCODE              = "0000001" --JZ
                or  OPCODE              = "0000010" --JMP
                or  OPCODE              = "0000011" --CALL
                or  OPCODE(6 downto 3)  = "1001"    --PUSH
                or  OPCODE              = "0000100" --ret
                or  OPCODE              = "0000101" --rti
                or  OPCODE(6 downto 3)  = "1101"    --STD
                or  OPCODE              = "1111100" --OUT
                ) then
                    return '1';
                else
                    return '0';
            end if;
        end function;

--is this opcode a Load or Pop instructions?
    function load_or_pop( OPCODE : std_logic_vector(6 downto 0))
                            return std_logic is
        begin

            if (    OPCODE(6 downto 3)  = "1100" --LDD
                or  OPCODE(6 downto 3)  = "1010" --POP
                ) then
                    return '1';
                else
                    return '0';
            end if;
        end function;

--are these two registers equal ?
function are_equal(     reg1 : std_logic_vector(3 downto 0);
                        reg2 : std_logic_vector(3 downto 0))
                            return std_logic is
        begin
            if ( reg1 = reg2 ) then
                    return '1';
                else
                    return '0';
            end if;
        end function;
begin
    
    

end architecture;