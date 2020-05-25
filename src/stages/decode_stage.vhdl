library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity decode_stage is
    port (

        --inputs from main entity
        clk                     : in  std_logic;
        rst                     : in std_logic;

        mem_stalling_bit        : in  std_logic; -- signal from memory stage used in rti or interrupt operations
        in_zero_flag            : in  std_logic;
        in_port                 : in  std_logic_vector(31 downto 0);

        -- From F/D Buffer
        fdb_instr               : in  std_logic_vector(31 downto 0);
        fdb_next_adr            : in  std_logic_vector(31 downto 0);
        fdb_inc_pc              : in  std_logic_vector(31 downto 0);
        fdb_hashed_adr          : in  std_logic_vector(3  downto 0);
        fdb_interrupt           : in  std_logic;

        out_if_flush            : out std_logic;
        out_branch_adr_update   : out std_logic_vector(31 downto 0);
        out_feedback_hashed_adr : out std_logic_vector(3  downto 0);

        -- To D/X Buffer
        dxb_alu_op              : out std_logic_vector(3  downto 0);
        dxb_dest_0              : out std_logic_vector(3  downto 0);
        dxb_dest_1              : out std_logic_vector(3  downto 0);
        dxb_opcode              : out std_logic_vector(6  downto 0);
        dxb_r_w                 : out std_logic_vector(1  downto 0);
        dxb_interrupt           : out std_logic;

        -- To Register File
        rf_src0_adr             : out std_logic_vector(3  downto 0); -- SRC
        rf_src1_adr             : out std_logic_vector(3  downto 0);

        src2_value              : out std_logic_vector(31 downto 0);
        src2_value_selector     : out std_logic;
        hlt_out                 : out std_logic;
        rf_br_io_enbl           : out std_logic_vector(1  downto 0) -- STATE
    );
end entity;

architecture rtl of decode_stage is
    --signal branch_enable        : std_logic                      := '0';
    --signal rsrc2_val_signal     : std_logic_vector (31 downto 0) := (others => '0');
    --signal op2_sel_sig          : std_logic                      := '0';
    signal alu_op               : std_logic_vector(3 downto 0)   := (others => '0');
    signal r_w_control          : std_logic_vector(1  downto 0)  := (others => '0');
    signal dest_0               : std_logic_vector(3  downto 0)  := (others => '0');
    signal dest_1               : std_logic_vector(3  downto 0)  := (others => '0');
    signal src_0                : std_logic_vector(3  downto 0)  := (others => '0');
    signal src_1                : std_logic_vector(3  downto 0)  := (others => '0');
    signal src_2_val            : std_logic_vector(31 downto 0)  := (others => '0');
    signal src_2_val_enable     : std_logic                      := '0';
begin
    control_unit_0 : entity work.control_unit
        port map(
            ib                   => fdb_instr,
            in_port_value        => in_port,
            incremented_pc       => fdb_inc_pc,
            aluop                => alu_op,
            rsrc1_sel            => src_0,
            rsrc2_sel            => src_1,
            rdst1_sel            => dest_0,
            rdst2_sel            => dest_1,
            intr_bit             => fdb_interrupt,
            rsrc2_val            => src_2_val,
            op2_sel              => src_2_val_enable,
            branch_io            => rf_br_io_enbl,
            --branch_enable      => branch_enable,
            r_w_control          => r_w_control,
            hlt                  => hlt_out
        );

        process(mem_stalling_bit, rst, dest_0, dest_1, src_0, src_1, r_w_control, src_2_val_enable,  alu_op, src_2_val)
        begin
            if rst = '1' then
                dxb_alu_op              <= (others => '0');
                dxb_dest_0              <= "1111";
                dxb_dest_1              <= "1111";
                dxb_opcode              <= (others => '0');
                dxb_r_w                 <= (others => '0');
                dxb_interrupt           <= '0';
                rf_src0_adr             <= "1111";
                rf_src1_adr             <= "1111";
                src2_value              <= (others => '0');
                src2_value_selector     <= '0';
            elsif(mem_stalling_bit = '0') then
                dxb_interrupt                        <= fdb_interrupt;
                dxb_opcode                           <= fdb_instr(30 downto 24);
                dxb_alu_op                           <= alu_op;
                dxb_dest_0                           <= dest_0;
                dxb_dest_1                           <= dest_1;
                rf_src0_adr                          <= src_0;
                rf_src1_adr                          <= src_1;
                src2_value_selector                  <= src_2_val_enable;
                src2_value                           <= src_2_val;
                dxb_r_w                              <= r_w_control;
            end if;

        end process;
    --branch_address_0 : entity work.branch_adr
    --    port map(
    --        next_pc_adr         => fdb_next_adr,
    --        instr_adr           => rf_op0_value,
    --        incr_pc_adr         => fdb_inc_pc,
    --        hashed_adr          => fdb_hashed_adr,
    --        branch_enable       => branch_enable,

    --        zero_flag           => in_zero_flag,
    --        if_flush            => out_if_flush,
    --        branch_adr_correct  => out_branch_adr_update,
    --        feedback_hashed_adr => out_feedback_hashed_adr
    --    );

    --TODO
    --dxb_dest_value <= ???

    --- Bits that don't acquire processing:
    --interrupt
    --dxb_interrupt                        <= fdb_interrupt;
    --OpCode
    --dxb_opcode                           <= fdb_instr(31 downto 25);
    --First operand
    --dxb_operand0                         <= rf_op0_value;

    --decide the second operands to go to the ALU
    --with op2_sel_sig select dxb_operand1 <=
    --    rsrc2_val_signal when '1',
    --    rf_op1_value when others;

    --RESET register file
    --rf_rst <= fdb_reset;
end architecture;