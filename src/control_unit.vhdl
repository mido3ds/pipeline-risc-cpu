library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity control_unit is
    port (
        
        IB                  : in std_logic_vector(31 downto 0);

        OpCode              : out std_logic_vector(6 downto 0);
        ALUOp               : out std_logic_vector(3 downto 0);
        Rsrc1_sel           : out std_logic_vector(3 downto 0);
        Rsrc2_sel           : out std_logic_vector(3 downto 0);
        Rdst1_sel           : out std_logic_vector(3 downto 0);
        Rdst2_sel           : out std_logic_vector(3 downto 0);
        --don't forget the sign extend ya evram!
        Rsrc2_val           : out std_logic_vector(31 downto 0);
        Op2_sel             : out std_logic;
        Branch_IO           : out std_logic_vector(1 downto 0);
        Branch_enable       : out std_logic;
        R_W_control         : out std_logic_vector(1 downto 0)
    );
end entity;

--MAIN LOGIC:




architecture rtl of control_unit is
    --sign extend function
    function sign_extend( value : std_logic_vector(15 downto 0))
                            return std_logic_vector is
        variable return_this : std_logic_vector(31 downto 0);
        begin

            if ( value(15)  = '0') then
                return_this(31 downto 16) := X"0000";
                return_this(15 downto 0) := value;
                return  return_this;
            else
                return_this(31 downto 16) := X"FFFF";
                return_this(15 downto 0) := value;
                return  return_this;
            end if;
        end function;
    --variable opcode : std_logic_vector(6 downto 0) := IB(31 downto 25);
begin
    
    Rsrc2_val <= sign_extend(IB(15 downto 0));

end architecture;