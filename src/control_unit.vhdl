library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity control_unit is
    port (
        ib             : in  std_logic_vector(31 downto 0);
        in_port_value  : in  std_logic_vector(31 downto 0); -- the in port value to be used in case of IN operation
        incremented_pc : in  std_logic_vector(31 downto 0);
        intr_bit       : in  std_logic;

        aluop          : out std_logic_vector(3  downto 0);
        rsrc1_sel      : out std_logic_vector(3  downto 0);
        rsrc2_sel      : out std_logic_vector(3  downto 0);
        rdst1_sel      : out std_logic_vector(3  downto 0);
        rdst2_sel      : out std_logic_vector(3  downto 0);

        rsrc2_val      : out std_logic_vector(31 downto 0);
        op2_sel        : out std_logic;
        branch_io      : out std_logic_vector(1  downto 0);
        r_w_control    : out std_logic_vector(1  downto 0);
        hlt            : out std_logic
    );
end entity;

architecture rtl of control_unit is

    begin
        process(ib, intr_bit)
        begin
            if(intr_bit = '1') then

                aluop        <= ALUOP_NOP;
                rsrc1_sel    <= SP;
                rsrc2_sel    <= "1111";
                rdst1_sel    <= SP;
                rdst2_sel    <= "1111";
                rsrc2_val    <= incremented_pc;
                op2_sel      <= '1';
                branch_io    <= "00";
                r_w_control  <= "10";
                hlt          <= '0';
            else
                case( ib(31 downto 27) ) is
                    when "01111"     =>
                        hlt                          <= '0';
                        rsrc1_sel                    <= '0' & ib(23 downto 21);
                        rsrc2_sel                    <= "1111";
                        rdst2_sel                    <= "1111";
                        r_w_control                  <= "00";
                        case( ib(26 downto 24) ) is
                            when "000"    =>                 -- IN
                                aluop                        <= ALUOP_NOP;
                                rdst1_sel                    <= '0' & ib(23 downto 21);
                                rsrc2_val                    <= in_port_value;
                                op2_sel                      <= '1';
                                branch_io                    <= "00";

                            when "001"   =>                 -- NOT
                                aluop                        <= ALUOP_NOT;
                                rdst1_sel                    <= '0' & ib(23 downto 21);
                                rsrc2_val                    <= "00000000000000000000000000000000";
                                op2_sel                      <= '0';
                                branch_io                    <= "00";

                            when "010"   =>                 -- INC
                                aluop                        <= ALUOP_INC;
                                rdst1_sel                    <= '0' & ib(23 downto 21);
                                rsrc2_val                    <= "00000000000000000000000000000000";
                                op2_sel                      <= '0';
                                branch_io                    <= "00";

                            when "011"   =>                 -- DEC
                                aluop                        <= ALUOP_DEC;
                                rdst1_sel                    <= '0' & ib(23 downto 21);
                                rsrc2_val                    <= "00000000000000000000000000000000";
                                op2_sel                      <= '0';
                                branch_io                    <= "00";

                            when "100"   =>                 -- OUT
                                aluop                        <= ALUOP_NOP;
                                rdst1_sel                    <= "1001";
                                rsrc2_val                    <= "00000000000000000000000000000000";
                                op2_sel                      <= '0';
                                branch_io                    <= "00";

                            when others =>
                                aluop                        <= ALUOP_NOP;
                                rdst1_sel                    <= "1111";
                                rsrc2_val                    <= "00000000000000000000000000000000";
                                op2_sel                      <= '0';
                                branch_io                    <= "00";

                        end case ;
                    when "00000"     =>
                            hlt                              <= '0';
                            case( ib(26 downto 24) ) is

                                when "001"    =>               -- JZ
                                    aluop                      <= ALUOP_NOP;
                                    rsrc1_sel                  <= '0' & ib(23 downto 21);
                                    rsrc2_sel                  <= "1111";
                                    rdst1_sel                  <= "1111";
                                    rdst2_sel                  <= "1111";
                                    rsrc2_val                  <= "00000000000000000000000000000000";
                                    op2_sel                    <= '0';
                                    r_w_control                <= "00";
                                    branch_io                  <= "11";

                                when "010"   =>                -- JMP
                                    aluop                      <= ALUOP_NOP;
                                    rsrc1_sel                  <= "1111";
                                    rsrc2_sel                  <= "1111";
                                    rdst1_sel                  <= "1111";
                                    rdst2_sel                  <= "1111";
                                    rsrc2_val                  <= "00000000000000000000000000000000";
                                    op2_sel                    <= '0';
                                    r_w_control                <= "00";
                                    branch_io                  <= "00";

                                when "011"  =>                 -- CALL
                                    aluop                      <= ALUOP_DEC2;
                                    rsrc1_sel                  <= SP;
                                    rsrc2_sel                  <= "1111";
                                    rdst1_sel                  <= SP;
                                    rdst2_sel                  <= "1111";
                                    rsrc2_val                  <= incremented_pc;
                                    op2_sel                    <= '1';
                                    r_w_control                <= "10";
                                    branch_io                  <= "00";

                                when "100"   =>                -- RET
                                    aluop                      <= ALUOP_INC2;
                                    rsrc1_sel                  <= SP;
                                    rsrc2_sel                  <= "1111";
                                    rdst1_sel                  <= SP;
                                    rdst2_sel                  <= "1111";
                                    rsrc2_val                  <= "00000000000000000000000000000000";
                                    op2_sel                    <= '0';
                                    r_w_control                <= "01";
                                    branch_io                  <= "00";

                                when "101"   =>                -- RTI
                                    aluop                      <= ALUOP_INC2;
                                    rsrc1_sel                  <= SP;
                                    rsrc2_sel                  <= "1111";
                                    rdst1_sel                  <= SP;
                                    rdst2_sel                  <= "1111";
                                    rsrc2_val                  <= "00000000000000000000000000000000";
                                    op2_sel                    <= '0';
                                    r_w_control                <= "01";
                                    branch_io                  <= "00";

                                when others =>
                                    aluop                      <= ALUOP_NOP;
                                    rsrc1_sel                  <= "1111";
                                    rsrc2_sel                  <= "1111";
                                    rdst1_sel                  <= "1111";
                                    rdst2_sel                  <= "1111";
                                    rsrc2_val                  <= "00000000000000000000000000000000";
                                    op2_sel                    <= '0';
                                    r_w_control                <= "00";
                                    branch_io                  <= "00";

                            end case ;

                    when OPC_SWAP   =>
                        aluop                      <= ALUOP_SWAP;
                        rsrc1_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_sel                  <= '0' & ib(23 downto 21);
                        rdst1_sel                  <= '0' & ib(26 downto 24);
                        rdst2_sel                  <= '0' & ib(23 downto 21);
                        rsrc2_val                  <= "00000000000000000000000000000000";
                        op2_sel                    <= '0';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_ADD    =>
                        aluop                      <= ALUOP_ADD;
                        rsrc1_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_sel                  <= '0' & ib(23 downto 21);
                        rdst1_sel                  <= '0' & ib(20 downto 18);
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= "00000000000000000000000000000000";
                        op2_sel                    <= '0';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_SUB    =>
                        aluop                      <= ALUOP_SUB;
                        rsrc1_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_sel                  <= '0' & ib(23 downto 21);
                        rdst1_sel                  <= '0' & ib(20 downto 18);
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= "00000000000000000000000000000000";
                        op2_sel                    <= '0';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_AND    =>
                        aluop                      <= ALUOP_AND;
                        rsrc1_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_sel                  <= '0' & ib(23 downto 21);
                        rdst1_sel                  <= '0' & ib(20 downto 18);
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= "00000000000000000000000000000000";
                        op2_sel                    <= '0';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_OR     =>
                        aluop                      <= ALUOP_OR;
                        rsrc1_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_sel                  <= '0' & ib(23 downto 21);
                        rdst1_sel                  <= '0' & ib(20 downto 18);
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= "00000000000000000000000000000000";
                        op2_sel                    <= '0';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_SHL    =>
                        aluop                      <= ALUOP_SHL;
                        rsrc1_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_sel                  <= "1111";
                        rdst1_sel                  <= '0' & ib(26 downto 24);
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= ib(23) & ib(23) & ib(23) & ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23) &  ib(23 downto 8);
                        op2_sel                    <= '1';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_SHR    =>
                        aluop                      <= ALUOP_SHR;
                        rsrc1_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_sel                  <= "1111";
                        rdst1_sel                  <= '0' & ib(26 downto 24);
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= ib(23) & ib(23) & ib(23) & ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23) &  ib(23 downto 8);
                        op2_sel                    <= '1';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_IADD   =>
                        aluop                      <= ALUOP_ADD;
                        rsrc1_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_sel                  <= "1111";
                        rdst1_sel                  <= '0' & ib(23 downto 21);
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= ib(20) & ib(20) & ib(20) & ib(20)& ib(20)& ib(20)& ib(20)& ib(20)& ib(20)& ib(20)& ib(20)& ib(20)& ib(20)& ib(20)& ib(20)& ib(20) &  ib(20 downto 5);
                        op2_sel                    <= '1';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_PUSH   =>
                        aluop                      <= ALUOP_DEC2;
                        rsrc1_sel                  <= SP;
                        rsrc2_sel                  <= '0' & ib(26 downto 24);
                        rdst1_sel                  <= SP;
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= "00000000000000000000000000000000";
                        op2_sel                    <= '0';
                        r_w_control                <= "10";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_POP    =>

                        aluop                      <= ALUOP_INC2;
                        rsrc1_sel                  <= SP;
                        rsrc2_sel                  <= "1111";
                        rdst1_sel                  <= SP;
                        rdst2_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_val                  <= "00000000000000000000000000000000";
                        op2_sel                    <= '0';
                        r_w_control                <= "01";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_LDM    =>

                        aluop                      <= ALUOP_NOP;
                        rsrc1_sel                  <= "1111";
                        rsrc2_sel                  <= "1111";
                        rdst1_sel                  <= '0' & ib(26 downto 24);
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= ib(23) & ib(23) & ib(23) & ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23)& ib(23) &  ib(23 downto 8);
                        op2_sel                    <= '1';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_LDD    =>

                        aluop                      <= ALUOP_NOP;
                        rsrc1_sel                  <= "1111";
                        rsrc2_sel                  <= "1111";
                        rdst1_sel                  <= "1111";
                        rdst2_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_val                  <= X"000" & ib(23 downto 4);
                        op2_sel                    <= '1';
                        r_w_control                <= "01";
                        hlt                        <= '0';
                        branch_io                  <= "00";

                    when OPC_STD    =>

                        aluop                      <= ALUOP_NOP;
                        rsrc1_sel                  <= '0' & ib(26 downto 24);
                        rsrc2_sel                  <= "1111";
                        rdst1_sel                  <= "1111";
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= X"000" & ib(23 downto 4);
                        op2_sel                    <= '1';
                        r_w_control                <= "10";
                        hlt                        <= '0';
                        branch_io                  <= "00";
                    when "01110"    =>
                        aluop                      <= ALUOP_NOP;
                        rsrc1_sel                  <= "1111";
                        rsrc2_sel                  <= "1111";
                        rdst1_sel                  <= "1111";
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= "00000000000000000000000000000000";
                        op2_sel                    <= '0';
                        r_w_control                <= "00";
                        hlt                        <= '1';
                        branch_io                  <= "00";

                    when others     =>
                        aluop                      <= ALUOP_NOP;
                        rsrc1_sel                  <= "1111";
                        rsrc2_sel                  <= "1111";
                        rdst1_sel                  <= "1111";
                        rdst2_sel                  <= "1111";
                        rsrc2_val                  <= "00000000000000000000000000000000";
                        op2_sel                    <= '0';
                        r_w_control                <= "00";
                        hlt                        <= '0';
                        branch_io                  <= "00";
                end case ;
            end if;
        end process;
    -----------------------------------------------------------------------------------------------------------------------------
end architecture;