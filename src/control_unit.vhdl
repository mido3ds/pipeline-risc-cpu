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

        process
        begin
            case( ib(30 downto 27) ) is
                when "1111"     =>
                    rsrc1_sel                    <= '0' & ib(23 downto 21);
                    rsrc2_sel                    <= "1111";
                    rdst2_sel                    <= "1111";
                    r_w_control                  <= "00";
                    case( ib(26 downto 24) ) is
                        when OPC_IN    =>                 -- IN
                            aluop                        <= ALUOP_NOP;
                            rdst1_sel                    <= '0' & ib(23 downto 21);
                            rsrc2_val                    <= in_port_value;
                            op2_sel                      <= '1';

                        when OPC_NOT   =>                 -- NOT
                            aluop                        <= ALUOP_NOT;
                            rdst1_sel                    <= '0' & ib(23 downto 21);
                            rsrc2_val                    <= "00000000000000000000000000000000";
                            op2_sel                      <= '0';

                        when OPC_INC   =>                 -- INC
                            aluop                        <= ALUOP_INC;
                            rdst1_sel                    <= '0' & ib(23 downto 21);
                            rsrc2_val                    <= "00000000000000000000000000000000";
                            op2_sel                      <= '0';

                        when OPC_DEC   =>                 -- DEC
                            aluop                        <= ALUOP_DEC;
                            rdst1_sel                    <= '0' & ib(23 downto 21);
                            rsrc2_val                    <= "00000000000000000000000000000000";
                            op2_sel                      <= '0';

                        when OPC_OUT   =>                 -- OUT
                            aluop                        <= ALUOP_NOP;
                            rdst1_sel                    <= "1110";
                            rsrc2_val                    <= "00000000000000000000000000000000";
                            op2_sel                      <= '0';

                        when others =>
                            aluop                        <= ALUOP_NOP;
                            rdst1_sel                    <= "1111";
                            rsrc2_val                    <= "00000000000000000000000000000000";
                            op2_sel                      <= '0';

                    end case ;
                when "0000"     =>
                        case( ib(26 downto 24) ) is

                            when OPC_JZ    =>
                                --null;           -- TODO
                                aluop                      <= ALUOP_NOP;
                                rsrc1_sel                  <= "1111";
                                rsrc2_sel                  <= "1111";
                                rdst1_sel                  <= "1111";
                                rdst2_sel                  <= "1111";
                                rsrc2_val                  <= "00000000000000000000000000000000";
                                op2_sel                    <= '0';
                                r_w_control                <= "00";

                            when OPC_JMP   =>

                                --null;          --TODO
                                aluop                      <= ALUOP_NOP;
                                rsrc1_sel                  <= "1111";
                                rsrc2_sel                  <= "1111";
                                rdst1_sel                  <= "1111";
                                rdst2_sel                  <= "1111";
                                rsrc2_val                  <= "00000000000000000000000000000000";
                                op2_sel                    <= '0';
                                r_w_control                <= "00";

                            when OPC_CALL  =>

                                aluop                      <= ALUOP_DEC2;
                                rsrc1_sel                  <= SP;
                                rsrc2_sel                  <= "1111";
                                rdst1_sel                  <= SP;
                                rdst2_sel                  <= "1111";
                                rsrc2_val                  <= incremented_pc;
                                op2_sel                    <= '1';
                                r_w_control                <= "10";

                            when OPC_RET   =>

                                aluop                      <= ALUOP_INC2;
                                rsrc1_sel                  <= SP;
                                rsrc2_sel                  <= "1111";
                                rdst1_sel                  <= SP;
                                rdst2_sel                  <= "1111";
                                rsrc2_val                  <= "00000000000000000000000000000000";
                                op2_sel                    <= '0';
                                r_w_control                <= "01";

                            when OPC_RTI   =>

                                aluop                      <= ALUOP_INC2;
                                rsrc1_sel                  <= SP;
                                rsrc2_sel                  <= "1111";
                                rdst1_sel                  <= SP;
                                rdst2_sel                  <= "1111";
                                rsrc2_val                  <= "00000000000000000000000000000000";
                                op2_sel                    <= '0';
                                r_w_control                <= "01";

                            when others =>

                                aluop                      <= ALUOP_NOP;
                                rsrc1_sel                  <= "1111";
                                rsrc2_sel                  <= "1111";
                                rdst1_sel                  <= "1111";
                                rdst2_sel                  <= "1111";
                                rsrc2_val                  <= "00000000000000000000000000000000";
                                op2_sel                    <= '0';
                                r_w_control                <= "00";

                        end case ;

                when OPC_SWAP   =>
                    aluop                      <= ALUOP_NOP;
                    rsrc1_sel                  <= '0' & ib(26 downto 24);
                    rsrc2_sel                  <= '0' & ib(23 downto 21);
                    rdst1_sel                  <= '0' & ib(26 downto 24);
                    rdst2_sel                  <= '0' & ib(23 downto 21);
                    rsrc2_val                  <= "00000000000000000000000000000000";
                    op2_sel                    <= '0';
                    r_w_control                <= "00";

                when OPC_ADD    =>
                    aluop                      <= ALUOP_ADD;
                    rsrc1_sel                  <= '0' & ib(26 downto 24);
                    rsrc2_sel                  <= '0' & ib(23 downto 21);
                    rdst1_sel                  <= '0' & ib(20 downto 18);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= "00000000000000000000000000000000";
                    op2_sel                    <= '0';
                    r_w_control                <= "00";

                when OPC_SUB    =>
                    aluop                      <= ALUOP_SUB;
                    rsrc1_sel                  <= '0' & ib(26 downto 24);
                    rsrc2_sel                  <= '0' & ib(23 downto 21);
                    rdst1_sel                  <= '0' & ib(20 downto 18);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= "00000000000000000000000000000000";
                    op2_sel                    <= '0';
                    r_w_control                <= "00";

                when OPC_AND    =>
                    aluop                      <= ALUOP_AND;
                    rsrc1_sel                  <= '0' & ib(26 downto 24);
                    rsrc2_sel                  <= '0' & ib(23 downto 21);
                    rdst1_sel                  <= '0' & ib(20 downto 18);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= "00000000000000000000000000000000";
                    op2_sel                    <= '0';
                    r_w_control                <= "00";

                when OPC_OR     =>
                    aluop                      <= ALUOP_OR;
                    rsrc1_sel                  <= '0' & ib(26 downto 24);
                    rsrc2_sel                  <= '0' & ib(23 downto 21);
                    rdst1_sel                  <= '0' & ib(20 downto 18);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= "00000000000000000000000000000000";
                    op2_sel                    <= '0';
                    r_w_control                <= "00";

                when OPC_SHL    =>
                    aluop                      <= ALUOP_SHL;
                    rsrc1_sel                  <= '0' & ib(26 downto 24);
                    rsrc2_sel                  <= "1111";
                    rdst1_sel                  <= '0' & ib(26 downto 24);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= sign_extend(ib(23 downto 8));
                    op2_sel                    <= '1';
                    r_w_control                <= "00";

                when OPC_SHR    =>
                    aluop                      <= ALUOP_SHR;
                    rsrc1_sel                  <= '0' & ib(26 downto 24);
                    rsrc2_sel                  <= "1111";
                    rdst1_sel                  <= '0' & ib(26 downto 24);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= sign_extend(ib(23 downto 8));
                    op2_sel                    <= '1';
                    r_w_control                <= "00";

                when OPC_IADD   =>
                    aluop                      <= ALUOP_ADD;
                    rsrc1_sel                  <= '0' & ib(26 downto 24);
                    rsrc2_sel                  <= "1111";
                    rdst1_sel                  <= '0' & ib(23 downto 21);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= sign_extend(ib(20 downto 5));
                    op2_sel                    <= '1';
                    r_w_control                <= "00";

                when OPC_PUSH   =>
                    aluop                      <= ALUOP_DEC2;
                    rsrc1_sel                  <= SP;
                    rsrc2_sel                  <= '0' & ib(26 downto 24);
                    rdst1_sel                  <= SP;
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= "00000000000000000000000000000000";
                    op2_sel                    <= '0';
                    r_w_control                <= "10";

                when OPC_POP    =>

                    aluop                      <= ALUOP_INC2;
                    rsrc1_sel                  <= SP;
                    rsrc2_sel                  <= "1111";
                    rdst1_sel                  <= '0' & ib(26 downto 24);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= "00000000000000000000000000000000";
                    op2_sel                    <= '0';
                    r_w_control                <= "01";

                when OPC_LDM    =>

                    aluop                      <= ALUOP_NOP;
                    rsrc1_sel                  <= "1111";
                    rsrc2_sel                  <= "1111";
                    rdst1_sel                  <= '0' & ib(26 downto 24);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= sign_extend(ib(23 downto 8));
                    op2_sel                    <= '1';
                    r_w_control                <= "00";

                when OPC_LDD    =>

                    aluop                      <= ALUOP_NOP;
                    rsrc1_sel                  <= "1111";
                    rsrc2_sel                  <= "1111";
                    rdst1_sel                  <= '0' & ib(26 downto 24);
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= X"000" & ib(23 downto 4);
                    op2_sel                    <= '1';
                    r_w_control                <= "01";

                when OPC_STD    =>

                    aluop                      <= ALUOP_NOP;
                    rsrc1_sel                  <= "1111";
                    rsrc2_sel                  <= '0' & ib(26 downto 24);
                    rdst1_sel                  <= "1111";
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= X"000" & ib(23 downto 4);
                    op2_sel                    <= '1';
                    r_w_control                <= "10";

                when others     =>
                    aluop                      <= ALUOP_NOP;
                    rsrc1_sel                  <= "1111";
                    rsrc2_sel                  <= "1111";
                    rdst1_sel                  <= "1111";
                    rdst2_sel                  <= "1111";
                    rsrc2_val                  <= "00000000000000000000000000000000";
                    op2_sel                    <= '0';
                    r_w_control                <= "00";
            end case ;
        end process;

    --base conditions
    --OpCode is simple..
    --OpCode <= ib(31 downto 25);
    hlt <= '1' when ib(31 downto 0) = "01110000000000000000000000000000" else '0';
    -----------------------------------------------------------------------------------------------------------------------------
end architecture;