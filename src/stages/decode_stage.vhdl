library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity decode_stage is
    port (
        clk                 : in std_logic;

        -- From F/D Buffer
        fdb_instr           : in std_logic_vector(31 downto 0);
        fdb_next_adr        : in std_logic_vector(31 downto 0);
        fdb_inc_pc          : in std_logic_vector(31 downto 0);
        fdb_hashed_adr      : in std_logic_vector(3 downto 0);
        fdb_interrupt       : in std_logic;
        fdb_reset           : in std_logic;

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

        -- To D/X Buffer
        dxb_alu_op          : out std_logic_vector (3 downto 0);
        dxb_operand0        : out std_logic_vector(32 - 1 downto 0);
        dxb_operand1        : out std_logic_vector(32 - 1 downto 0);
        dxb_dest_0          : out std_logic_vector(4 - 1 downto 0);
        dxb_dest_1          : out std_logic_vector(4 - 1 downto 0);
        dxb_dest_value      : out std_logic_vector(32 - 1 downto 0);
        dxb_opcode          : out std_logic_vector(7 - 1 downto 0);
        dxb_r_w             : out std_logic_vector(1 downto 0);
        dxb_interrupt       : out std_logic;

        -- To/From Register File
        rf_src0_adr         : out std_logic_vector(3 downto 0); -- SRC
        rf_src1_adr         : out std_logic_vector(3 downto 0);
        rf_br_io_enbl       : out std_logic_vector(1 downto 0); -- STATE
        rf_op0_value        : in std_logic_vector(31 downto 0); -- OP
        rf_op1_value        : in std_logic_vector(31 downto 0);
        rf_rst              : out std_logic--will_see
    );
end entity;

architecture rtl of decode_stage is
    signal branch_enable_sig : std_logic                      := '0';
    signal Rsrc2_val_signal  : std_logic_vector (31 downto 0) := (others => '0');
    signal Op2_sel_sig       : std_logic                      := '0';
begin
    control_unit_0 : entity work.control_unit
        port map(
            IB            => fdb_instr,

            ALUOp         => dxb_alu_op,
            Rsrc1_sel     => rf_src0_adr,
            Rsrc2_sel     => rf_src1_adr,
            Rdst1_sel     => dxb_dest_0,
            Rdst2_sel     => dxb_dest_1,

            Rsrc2_val     => Rsrc2_val_signal,
            Op2_sel       => Op2_sel_sig,
            Branch_IO     => rf_br_io_enbl,
            Branch_enable => branch_enable_sig,
            R_W_control   => dxb_r_w
        );

    branch_address_0 : entity work.branch_adr
        port map(
            next_pc_adr         => fdb_next_adr,
            instr_adr           => rf_op0_value,
            incr_pc_adr         => fdb_inc_pc,
            hashed_adr          => fdb_hashed_adr,
            Branch_enable       => branch_enable_sig,

            zero_flag           => Zero_flag,
            if_flush            => if_flush,
            branch_adr_correct  => branch_adr_update,
            feedback_hashed_adr => feedback_hashed_adr
        );

    --- Bits that don't acquire processing:
    --interrupt
    dxb_interrupt                        <= fdb_interrupt;
    --OpCode
    dxb_opcode                           <= fdb_instr(31 downto 25);
    --First operand
    dxb_operand0                         <= rf_op0_value;

    --decide the second operands to go to the ALU
    with Op2_sel_sig select dxb_operand1 <=
        Rsrc2_val_signal when '1',
        rf_op1_value when others;

    --RESET register file
    rf_rst <= fdb_reset;
end architecture;