library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity decode_stage is
    port (

        clk                 : in std_logic;
        
        --------NOTE: ANY THING THAT WILL BE ADDED, ADD IT TO THE TOP
        --------------AND ADJUST THE LENGTHES ONLY..............

        --Ib 32 bits.......128:97
        --next address(proposed) 32......96:65
        --incremented pc 32...........64:33
        --hashed address 32......32:1
        --interrupt bit 1..........0
        ----------------------129 bits
        IF_ID_buffer        : in std_logic_vector(128 downto 0);
        

        --I don't know from where! but I need Zero_flag
        Zero_flag           : in std_logic;
        if_flush            : out std_logic;
        branch_adr          : out std_logic_vector(31 downto 0);
        feedback_hashed_adr : out std_logic_vector(3 downto 0);
        --alu_op......85:82.....done
        --op1 32......81:50....will_see 
        --op2 32......49:18....will_see
        --dst_reg_1 4.....17:14.......done
        --dst_reg_2 4...swap only.....13:10.....done
        --opcode 7......9:3............done
        --r/w controls 2......2:1......done
        --interrupt bit 1.......0......done
        ----------------------86 bits
        ID_EX_buffer        : out std_logic_vector(85 downto 0)
    );
end entity;

architecture rtl of decode_stage is

    control_unit_0 : entity work.control_unit
        port map(
            IB                => IF_ID_buffer(128 downto 97),

            ALUOp             => ID_EX_buffer (85 downto 82),
            Rsrc1_sel         => --register file
            Rsrc2_sel         => --register file
            Rdst1_sel         => ID_EX_buffer (17 downto 14),
            Rdst2_sel         => ID_EX_buffer (13 downto 10),

            Rsrc2_val         => --will_see
            Op2_sel           => --will_see
            Branch_IO         => --register file
            Branch_enable     => --branch predictor
            R_W_control       => ID_EX_buffer (2 downto 1),
            SP_extract        => --will_see
        );
begin

    --Bits that don't acquire processing:
    --OpCode
    --interrupt bit

    --interrupt
    ID_EX_buffer(0) <= IF_ID_buffer(0);
    
    --OpCode
    ID_EX_buffer(9 downto 3) <= IF_ID_buffer(128 downto 122);





end architecture;