library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity hdu is
    port (
        rst              : in std_logic;

        opcode_decode    : in std_logic_vector(6 downto 0);
        opcode_execute   : in std_logic_vector(6 downto 0);
        opcode_memory    : in std_logic_vector(6 downto 0);
        decode_src_reg_1 : in std_logic_vector(3 downto 0);
        decode_src_reg_2 : in std_logic_vector(3 downto 0);
        exe_dst_reg_1    : in std_logic_vector(3 downto 0);
        exe_dst_reg_2    : in std_logic_vector(3 downto 0);
        mem_dst_reg_1    : in std_logic_vector(3 downto 0);
        mem_dst_reg_2    : in std_logic_vector(3 downto 0);
        --ALU_selction                        : out std_logic;
        operand_1_select : out std_logic_vector(2 downto 0);
        operand_2_select : out std_logic_vector(2 downto 0);
        Stall_signal     : out std_logic
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
    signal stall_1  : std_logic := '0';
    signal stall_2  : std_logic := '0';
    begin
    process(opcode_execute, opcode_memory, decode_src_reg_1, decode_src_reg_2, exe_dst_reg_1, exe_dst_reg_2 ,mem_dst_reg_2, stall_1, stall_2)
    begin
        if (decode_src_reg_1 = "1111") then
            operand_1_select         <= "000";
            stall_1    <= '0';
        elsif (decode_src_reg_1 = exe_dst_reg_1 or decode_src_reg_1 = exe_dst_reg_2) then
            if (opcode_memory(6 downto 3) = "1100") then
                operand_1_select     <= "000";
                stall_1    <= '1';
            else
                if (opcode_execute(6 downto 3) = "1111" or opcode_execute(6 downto 3) = "0010" or opcode_execute(6 downto 3) = "0011" or opcode_execute(6 downto 3) = "0100" or opcode_execute(6 downto 3) = "0101" or opcode_execute(6 downto 3) = "0110" or opcode_execute(6 downto 3) = "0111" or opcode_execute(6 downto 3) = "1000") then
                    operand_1_select     <= "001";
                    stall_1    <= '0';
                elsif (opcode_execute(6 downto 3) = "0001") then
                    stall_1    <= '0';
                    if(decode_src_reg_1 = exe_dst_reg_1) then
                        operand_1_select  <= "001";
                    else
                        operand_1_select  <= "010";
                    end if;
                end if;
            end if;
        else
                -- here check if in memory or not
            if (decode_src_reg_1 = mem_dst_reg_1 or decode_src_reg_1 = mem_dst_reg_2) then
                -- check to take alu out or memory out
                if (opcode_memory(6 downto 3) = "1111" or opcode_memory(6 downto 3) = "0010" or opcode_memory(6 downto 3) = "0011" or opcode_memory(6 downto 3) = "0100"
                or opcode_memory(6 downto 3) = "0101" or opcode_memory(6 downto 3) = "0110" or opcode_memory(6 downto 3) = "0111" or opcode_memory(6 downto 3) = "1000") then
                    operand_1_select     <= "011";
                    stall_1    <= '0';
                elsif (opcode_memory(6 downto 3) = "0001") then
                    stall_1    <= '0';
                    if (decode_src_reg_1 = mem_dst_reg_1) then
                        operand_1_select     <= "011";
                    else
                        operand_1_select     <= "100";
                    end if;
                elsif (opcode_memory(6 downto 3) = "1100") then
                    operand_1_select     <= "101";
                    stall_1           <= '0';
                end if;
            else
                operand_1_select       <= "000";
                stall_1                <= '0';
            end if;
        end if;

        if (decode_src_reg_2 = "1111") then
            operand_2_select       <= "000";
            stall_2                <= '0';
        elsif (decode_src_reg_2 = exe_dst_reg_1 or decode_src_reg_2 = exe_dst_reg_2) then

            if (opcode_memory(6 downto 3) = "1100") then
                operand_2_select     <= "000";
                stall_2                <= '1';
            elsif (opcode_execute(6 downto 3) = "1111" or opcode_execute(6 downto 3) = "0010" or opcode_execute(6 downto 3) = "0011" or opcode_execute(6 downto 3) = "0100"
            or opcode_execute(6 downto 3) = "0101" or opcode_execute(6 downto 3) = "0110" or opcode_execute(6 downto 3) = "0111" or opcode_execute(6 downto 3) = "1000") then
                operand_2_select     <= "001";
                stall_2                <= '0';
            elsif(opcode_execute(6 downto 3) = "0001") then
                stall_2               <= '0';
                if (decode_src_reg_2 = exe_dst_reg_1) then
                    operand_2_select  <= "001";
                else
                    operand_2_select  <= "010";
                end if;
            end if;

        else
            -- here check if in memory or not
            if (decode_src_reg_2 = mem_dst_reg_1 or decode_src_reg_2 = mem_dst_reg_2) then
                if (opcode_memory(6 downto 3) = "1111" or opcode_memory(6 downto 3) = "0010" or opcode_memory(6 downto 3) = "0011" or opcode_memory(6 downto 3) = "0100"
                or opcode_memory(6 downto 3) = "0101" or opcode_memory(6 downto 3) = "0110" or opcode_memory(6 downto 3) = "0111" or opcode_memory(6 downto 3) = "1000") then
                    operand_2_select       <= "011";
                    stall_2                <= '0';
                elsif (opcode_memory(6 downto 3) = "0001") then
                    stall_2                <= '0';
                    if (decode_src_reg_2 = mem_dst_reg_1) then
                        operand_2_select     <= "011";
                    else
                        operand_2_select     <= "100";
                    end if;
                elsif (opcode_memory(6 downto 3) = "1100") then         -- memory operation here need stalling :)
                    stall_2                <= '0';
                    operand_2_select     <= "101";
                end if;
                -- check to take alu out or memory out
            else
                operand_2_select       <= "000";
                stall_2                <= '0';
            end if;
        end if;
        stall_signal    <= (stall_1 or stall_2);
    end process;
end architecture;