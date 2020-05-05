library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity hdu is
    port (
        opcode_decode                       : in std_logic_vector(3 downto 0);
        opcode_execute                      : in std_logic_vector(3 downto 0);
        opcode_memory                       : in std_logic_vector(3 downto 0);
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
begin
    
end architecture;