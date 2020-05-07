library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity decode_stage is
    port (
        clk                 : in std_logic;

        --------NOTE: ANY THING THAT WILL BE ADDED, ADD IT TO THE TOP
        --------------AND ADJUST THE LENGTHES ONLY..............
        --reset bit....133
        --hashed_address 4 bits....:132:129

        --Ib 32 bits.......128:97
        --next address(proposed) 32......96:65
        --incremented pc 32...........64:33
        --hashed address 32......32:1
        --interrupt bit 1..........0
        ----------------------134 bits
        IF_ID_buffer        : in std_logic_vector(133 downto 0);

        --I don't know from where! but I need Zero_flag
        Zero_flag           : in std_logic;
        if_flush            : out std_logic;
        branch_adr_update   : out std_logic_vector(31 downto 0);
        feedback_hashed_adr : out std_logic_vector(3 downto 0);

        alu_op              : in std_logic_vector (3 downto 0);
        in_operand0         : in std_logic_vector(32 - 1 downto 0);
        in_operand1         : in std_logic_vector(32 - 1 downto 0);
        in_destination_0    : in std_logic_vector(4 - 1 downto 0);
        in_destination_1    : in std_logic_vector(4 - 1 downto 0);
        in_opcode           : in std_logic_vector(7 - 1 downto 0);
        in_r_w              : in std_logic_vector(1 downto 0);
        in_interrupt        : in std_logic;

        --alu_op......85:82.....done
        --op1 32......81:50....will_see 
        --op2 32......49:18....will_see....done
        --dst_reg_1 4.....17:14.......done
        --dst_reg_2 4...swap only.....13:10.....done
        --opcode 7......9:3............done
        --r/w controls 2......2:1......done
        --interrupt bit 1.......0......done
        ----------------------86 bits
        ID_EX_buffer        : out std_logic_vector(85 downto 0);

        --Register File Signals
        src0_adr            : out std_logic_vector(3 downto 0); -- SRC
        src1_adr            : out std_logic_vector(3 downto 0);
        br_io_enbl          : out std_logic_vector(1 downto 0); -- STATE
        op0_value           : in std_logic_vector(31 downto 0); -- OP
        op1_value           : in std_logic_vector(31 downto 0);
        rst                 : out std_logic--will_see
    );
end entity;

architecture rtl of decode_stage is
    --SIGNALS:
    signal branch_enable_sig : std_logic                      := '0';
    signal Rsrc2_val_signal  : std_logic_vector (31 downto 0) := (others => '0');
    signal Op2_sel_sig       : std_logic                      := '0';
begin
    control_unit_0 : entity work.control_unit
        port map(
            IB            => IF_ID_buffer(128 downto 97),

            ALUOp         => ID_EX_buffer (85 downto 82),
            Rsrc1_sel     => src0_adr,
            Rsrc2_sel     => src1_adr,
            Rdst1_sel     => ID_EX_buffer (17 downto 14),
            Rdst2_sel     => ID_EX_buffer (13 downto 10),

            Rsrc2_val     => Rsrc2_val_signal,
            Op2_sel       => Op2_sel_sig,
            Branch_IO     => br_io_enbl,
            Branch_enable => branch_enable_sig, --signal branch_enable
            R_W_control   => ID_EX_buffer (2 downto 1)
        );

    branch_address_0 : entity work.branch_adr
        port map(
            next_pc_adr         => IF_ID_buffer(96 downto 65),
            instr_adr           => op0_value,
            incr_pc_adr         => IF_ID_buffer(64 downto 33),
            hashed_adr          => IF_ID_buffer(132 downto 129),
            Branch_enable       => branch_enable_sig,

            zero_flag           => Zero_flag,
            if_flush            => if_flush,
            branch_adr_correct  => branch_adr_update,
            feedback_hashed_adr => feedback_hashed_adr
        );

    --Bits that don't acquire processing:
    --OpCode
    --interrupt bit

    --interrupt
    ID_EX_buffer(0)                                    <= IF_ID_buffer(0);

    --OpCode
    ID_EX_buffer(9 downto 3)                           <= IF_ID_buffer(128 downto 122);

    --First operand
    ID_EX_buffer(81 downto 50)                         <= op0_value;

    --decide the second operands to go to the ALU
    with Op2_sel_sig select ID_EX_buffer(49 downto 18) <=
        Rsrc2_val_signal when '1',
        op1_value when others;

    --RESET register file
    rst <= IF_ID_buffer(133);
end architecture;