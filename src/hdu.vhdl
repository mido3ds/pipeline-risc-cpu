library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity hdu is
    port (
        rst              : in std_logic;

        opcode_memory    : in std_logic_vector(6 downto 0);
        opcode_wb        : in std_logic_vector(6 downto 0);
        decode_src_reg_1 : in std_logic_vector(3 downto 0);
        decode_src_reg_2 : in std_logic_vector(3 downto 0);
        exe_dst_reg_1    : in std_logic_vector(3 downto 0);
        exe_dst_reg_2    : in std_logic_vector(3 downto 0);
        mem_dst_reg_1    : in std_logic_vector(3 downto 0);
        mem_dst_reg_2    : in std_logic_vector(3 downto 0);

        operand_1_select : out std_logic_vector(2 downto 0);
        operand_2_select : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of hdu is
    begin
    process( opcode_memory,opcode_wb, decode_src_reg_1, decode_src_reg_2, exe_dst_reg_1, exe_dst_reg_2 , mem_dst_reg_1,mem_dst_reg_2)
    begin
        if rst = '1' then
            operand_1_select <= (others => '0');
            operand_2_select <= (others => '0');
        else
        -- first check the out from execute stage
            if (decode_src_reg_1 = "1111") then
                operand_1_select         <= "000";
            else
                if (decode_src_reg_1 = exe_dst_reg_2 and (opcode_memory(6 downto 3) = "1100" or opcode_memory(6 downto 3) = "1010" )) then
                    operand_1_select               <= "101";                       -- destination in case of LDD or POP (memory out)
                elsif(decode_src_reg_1 = exe_dst_reg_1 and (opcode_memory(6 downto 3) = "1010" or opcode_memory(6 downto 3) = "1001" or opcode_memory(6 downto 0) = "0000011" or opcode_memory(6 downto 0) = "0000100") ) then
                    operand_1_select               <= "001";                       -- SP ( in case of pop, push, call, RET)
                elsif (decode_src_reg_1 = exe_dst_reg_1 or decode_src_reg_1 = exe_dst_reg_2) then
                    if (opcode_memory(6 downto 3) = "0001") then                   -- operation in case of swap
                        if(decode_src_reg_1 = exe_dst_reg_1) then                  -- if operand one select out_1 else select out_2
                            operand_1_select  <= "001";
                        else
                            operand_1_select  <= "010";
                        end if;
                    -- normal operations affected by out_1
                    elsif (opcode_memory(6 downto 3) = "1111" or opcode_memory(6 downto 3) = "0010" or opcode_memory(6 downto 3) = "0011" or opcode_memory(6 downto 3) = "0100"
                    or opcode_memory(6 downto 3) = "0101" or opcode_memory(6 downto 3) = "0110" or opcode_memory(6 downto 3) = "0111" or opcode_memory(6 downto 3) = "1000"
                    or opcode_memory(6 downto 3) = "1011") then
                        operand_1_select     <= "001";
                    else
                        operand_1_select     <= "000";
                    end if;
                    -- second check the out from memory stage
                else

                    if (decode_src_reg_1 = mem_dst_reg_2 and ( opcode_wb(6 downto 3) = "1010" or opcode_wb(6 downto 3) = "1100")) then
                        operand_1_select       <= "101";    -- take memory out from pop or LDD operations
                    elsif (decode_src_reg_1 = mem_dst_reg_1 and (opcode_wb(6 downto 3) = "1010" or opcode_wb(6 downto 3) = "1001" or opcode_wb(6 downto 0) = "0000011" or opcode_wb(6 downto 0) = "0000100")) then
                        operand_1_select     <= "011";
                    elsif (decode_src_reg_1 = mem_dst_reg_1 or decode_src_reg_1 = mem_dst_reg_2) then
                        --check normal operations
                        if(opcode_wb(6 downto 3) = "0001") then
                            if (decode_src_reg_1 = mem_dst_reg_1) then
                                operand_1_select     <= "011";
                            else
                                operand_1_select     <= "100";
                            end if;
                        elsif (opcode_wb(6 downto 3) = "1111" or opcode_wb(6 downto 3) = "0010" or opcode_wb(6 downto 3) = "0011" or opcode_wb(6 downto 3) = "0100"
                        or opcode_wb(6 downto 3) = "0101" or opcode_wb(6 downto 3) = "0110" or opcode_wb(6 downto 3) = "0111" or opcode_wb(6 downto 3) = "1000"
                        or opcode_wb(6 downto 3) = "1011") then
                            operand_1_select     <= "011";
                        end if;
                    else
                        operand_1_select       <= "000";
                    end if;
                end if;
            end if;

        -- first check the out from execute stage
            if (decode_src_reg_2 = "1111") then
                operand_2_select         <= "000";
            else
                if (decode_src_reg_2 = exe_dst_reg_2 and (opcode_memory(6 downto 3) = "1100" or opcode_memory(6 downto 3) = "1010" )) then
                    operand_2_select               <= "101";                       -- destination in case of LDD or POP (memory out)
                elsif(decode_src_reg_2 = exe_dst_reg_1 and (opcode_memory(6 downto 3) = "1010" or opcode_memory(6 downto 3) = "1001" or opcode_memory(6 downto 0) = "0000011" or opcode_memory(6 downto 0) = "0000100") ) then
                    operand_2_select               <= "001";                       -- SP ( in case of pop, push, call, RET)
                elsif (decode_src_reg_2 = exe_dst_reg_1 or decode_src_reg_2 = exe_dst_reg_2) then
                    if (opcode_memory(6 downto 3) = "0001") then                   -- operation in case of swap
                        if(decode_src_reg_2 = exe_dst_reg_1) then                  -- if operand one select out_1 else select out_2
                            operand_2_select  <= "001";
                        else
                            operand_2_select  <= "010";
                        end if;
                    -- normal operations affected by out_1
                    elsif (opcode_memory(6 downto 3) = "1111" or opcode_memory(6 downto 3) = "0010" or opcode_memory(6 downto 3) = "0011" or opcode_memory(6 downto 3) = "0100" 
                    or opcode_memory(6 downto 3) = "0101" or opcode_memory(6 downto 3) = "0110" or opcode_memory(6 downto 3) = "0111" or opcode_memory(6 downto 3) = "1000" 
                    or opcode_memory(6 downto 3) = "1011") then
                        operand_2_select     <= "001";
                    else
                        operand_2_select     <= "000";
                    end if;
                    -- second check the out from memory stage
                else

                    if (decode_src_reg_2 = mem_dst_reg_2 and ( opcode_wb(6 downto 3) = "1010" or opcode_wb(6 downto 3) = "1100")) then
                        operand_2_select            <= "101";    -- take memory out from pop or LDD operations
                    elsif (decode_src_reg_2 = mem_dst_reg_1 and (opcode_wb(6 downto 3) = "1010" or opcode_wb(6 downto 3) = "1001" or opcode_wb(6 downto 0) = "0000011" or opcode_wb(6 downto 0) = "0000100")) then
                        operand_2_select            <= "011";
                    elsif (decode_src_reg_2 = mem_dst_reg_1 or decode_src_reg_2 = mem_dst_reg_2) then
                        --check normal operations
                        if(opcode_wb(6 downto 3) = "0001") then
                            if (decode_src_reg_2 = mem_dst_reg_1) then
                                operand_2_select     <= "011";
                            else
                                operand_2_select     <= "100";
                            end if;
                        elsif (opcode_wb(6 downto 3) = "1111" or opcode_wb(6 downto 3) = "0010" or opcode_wb(6 downto 3) = "0011" or opcode_wb(6 downto 3) = "0100"
                        or opcode_wb(6 downto 3) = "0101" or opcode_wb(6 downto 3) = "0110" or opcode_wb(6 downto 3) = "0111" or opcode_wb(6 downto 3) = "1000"
                        or opcode_wb(6 downto 3) = "1011") then
                            operand_2_select         <= "011";
                        else
                            operand_2_select         <= "000";
                        end if;
                    else
                        operand_2_select         <= "000";

                    end if;
                end if;
            end if;
        end if; -- for reset
    end process;
end architecture;