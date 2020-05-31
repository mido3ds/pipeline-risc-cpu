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
        opcode_wb        : in std_logic_vector(6 downto 0);
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

architecture rtl of hdu is
    begin
    process(opcode_execute, opcode_memory,opcode_wb, decode_src_reg_1, decode_src_reg_2, exe_dst_reg_1, exe_dst_reg_2 ,mem_dst_reg_2)
    begin
        if rst = '1' then
            operand_1_select <= (others => '0');
            operand_2_select <= (others => '0');
            stall_signal                 <= '0';
        else
            if (decode_src_reg_1 = "1111") then
                operand_1_select         <= "000";
            elsif (decode_src_reg_1 = exe_dst_reg_2 and opcode_memory(6 downto 3) = "1100") then
                operand_1_select               <= "101";
            elsif(decode_src_reg_1 = exe_dst_reg_2 and opcode_memory(6 downto 3) = "1010") then
                operand_1_select               <= "101";
            elsif (decode_src_reg_1 = exe_dst_reg_1 or decode_src_reg_1 = exe_dst_reg_2) then
                if (opcode_memory(6 downto 3) = "0001") then
                    if(decode_src_reg_1 = exe_dst_reg_1) then
                        operand_1_select  <= "001";
                    else
                        operand_1_select  <= "010";
                    end if;
                elsif (opcode_execute(6 downto 3) = "1111" or opcode_execute(6 downto 3) = "0010" or opcode_execute(6 downto 3) = "0011" or opcode_execute(6 downto 3) = "0100" 
                or opcode_execute(6 downto 3) = "0101" or opcode_execute(6 downto 3) = "0110" or opcode_execute(6 downto 3) = "0111" or opcode_execute(6 downto 3) = "1000" 
                or opcode_execute(6 downto 0) = "0000100" or opcode_execute(6 downto 0) = "0000011" or opcode_execute(6 downto 3) = "1010" or opcode_execute( 6 downto 3) = "1001") then
                    operand_1_select     <= "001";
                elsif (opcode_execute(6 downto 3) = "0001") then
                    if(decode_src_reg_1 = exe_dst_reg_1) then
                        operand_1_select  <= "001";
                    else
                        operand_1_select  <= "010";
                    end if;
                end if;

            else
                    -- here check if in memory or not
                if (decode_src_reg_1 = mem_dst_reg_2 and opcode_wb(6 downto 3) = "1010") then
                    operand_1_select       <= "101";
                elsif (decode_src_reg_1 = mem_dst_reg_1 or decode_src_reg_1 = mem_dst_reg_2) then
                    -- check to take alu out or memory out
                    if (opcode_wb(6 downto 3) = "1111" or opcode_wb(6 downto 3) = "0010" or opcode_wb(6 downto 3) = "0011" or opcode_wb(6 downto 3) = "0100"
                    or opcode_wb(6 downto 3) = "0101" or opcode_wb(6 downto 3) = "0110" or opcode_wb(6 downto 3) = "0111" or opcode_wb(6 downto 3) = "1000"
                    or opcode_wb(6 downto 0) = "0000100" or opcode_wb(6 downto 0) = "0000011" or opcode_wb( 6 downto 3) = "1001" ) then
                        operand_1_select     <= "011";
                    elsif (opcode_wb(6 downto 3) = "0001") then
                        if (decode_src_reg_1 = mem_dst_reg_1) then
                            operand_1_select     <= "011";
                        else
                            operand_1_select     <= "100";
                        end if;
                    elsif (opcode_wb(6 downto 3) = "1100") then
                        operand_1_select     <= "101";
                    end if;
                else
                    operand_1_select       <= "000";
                end if;
            end if;

            if (decode_src_reg_2 = "1111") then
                operand_2_select       <= "000";
            elsif (decode_src_reg_2 = exe_dst_reg_2 and opcode_memory(6 downto 3) = "1100" ) then
                operand_2_select     <= "101";
            elsif (decode_src_reg_2 = exe_dst_reg_2 and opcode_memory(6 downto 3) = "1010") then
                operand_2_select     <= "101";
            elsif (decode_src_reg_2 = exe_dst_reg_1 or decode_src_reg_2 = exe_dst_reg_2) then
                if(opcode_memory(6 downto 3) = "0001") then
                    if (decode_src_reg_2 = exe_dst_reg_1) then
                        operand_2_select  <= "001";
                    else
                        operand_2_select  <= "010";
                    end if;
                elsif (opcode_execute(6 downto 3) = "1111" or opcode_execute(6 downto 3) = "0010" or opcode_execute(6 downto 3) = "0011" or opcode_execute(6 downto 3) = "0100"
                or opcode_execute(6 downto 3) = "0101" or opcode_execute(6 downto 3) = "0110" or opcode_execute(6 downto 3) = "0111" or opcode_execute(6 downto 3) = "1000" 
                or opcode_execute(6 downto 0) = "0000100" or opcode_execute(6 downto 0) = "0000011" or opcode_execute(6 downto 3) = "1010" or opcode_execute( 6 downto 3) = "1001") then
                    operand_2_select     <= "001";
                elsif(opcode_execute(6 downto 3) = "0001") then
                    if (decode_src_reg_2 = exe_dst_reg_1) then
                        operand_2_select  <= "001";
                    else
                        operand_2_select  <= "010";
                    end if;
                end if;

            else
                -- here check if in memory or not
                if (decode_src_reg_2 = mem_dst_reg_2 and  opcode_wb(6 downto 3) = "1010" ) then
                    operand_2_select          <= "101";
                elsif (decode_src_reg_2 = mem_dst_reg_1 or decode_src_reg_2 = mem_dst_reg_2) then
                    if (opcode_wb(6 downto 3) = "1111" or opcode_wb(6 downto 3) = "0010" or opcode_wb(6 downto 3) = "0011" or opcode_wb(6 downto 3) = "0100"
                    or opcode_wb(6 downto 3) = "0101" or opcode_wb(6 downto 3) = "0110" or opcode_wb(6 downto 3) = "0111" or opcode_wb(6 downto 3) = "1000"
                    or opcode_wb(6 downto 0) = "0000100" or opcode_wb(6 downto 0) = "0000011" or opcode_wb( 6 downto 3) = "1001" or opcode_wb(6 downto 3) = "1011") then
                        operand_2_select       <= "011";
                    elsif (opcode_wb(6 downto 3) = "0001") then
                        if (decode_src_reg_2 = mem_dst_reg_1) then
                            operand_2_select     <= "011";
                        else
                            operand_2_select     <= "100";
                        end if;
                    elsif (opcode_wb(6 downto 3) = "1100") then
                        operand_2_select     <= "101";
                    end if;
                    -- check to take alu out or memory out
                else
                    operand_2_select       <= "000";
                end if;
            end if;
            stall_signal                 <= '0';
        end if;
    end process;
end architecture;