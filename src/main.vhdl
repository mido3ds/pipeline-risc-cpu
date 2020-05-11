library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
    port (
        clk, rst, interrupt : in std_logic;
        in_value            : in std_logic_vector(31 downto 0);
        out_value           : out std_logic_vector(31 downto 0)

        -- testing signals
        --TODO
    );
end entity;

architecture rtl of main is
    --> fetch_stage
    signal fsi_if_flush                  : std_logic;
    signal fsi_stall                     : std_logic;
    signal fsi_parallel_load_pc_selector : std_logic;
    signal fsi_loaded_pc_value           : std_logic_vector(31 downto 0);
    signal fsi_branch_address            : std_logic_vector(31 downto 0);
    signal fsi_hashed_address            : std_logic_vector(3 downto 0);

    -- fetch_stage --> f_d_buffer
    signal fs_fdb_interrupt              : std_logic;
    signal fs_fdb_inst_length_bit        : std_logic; -- 16 or 32 bits, TODO: input to f_d_buffer??
    signal fs_fdb_instruction_bits       : std_logic_vector(31 downto 0);
    signal fs_fdb_predicted_address      : std_logic_vector(31 downto 0);
    signal fs_fdb_hashed_address         : std_logic_vector(3 downto 0);
    signal fs_fdb_inc_pc                 : std_logic_vector(31 downto 0);

    -- f_d_buffer --> decode_stage
    signal fdb_ds_instr                  : std_logic_vector(31 downto 0);
    signal fdb_ds_next_adr               : std_logic_vector(31 downto 0);
    signal fdb_ds_inc_pc                 : std_logic_vector(31 downto 0);
    signal fdb_ds_hashed_adr             : std_logic_vector(3 downto 0);
    signal fdb_ds_interrupt              : std_logic;
    signal fdb_ds_reset                  : std_logic;

    -- decode_stage --> d_x_buffer
    signal ds_dxb_alu_op                 : std_logic_vector (3 downto 0);
    signal ds_dxb_operand0               : std_logic_vector(32 - 1 downto 0);
    signal ds_dxb_operand1               : std_logic_vector(32 - 1 downto 0);
    signal ds_dxb_dest_0                 : std_logic_vector(4 - 1 downto 0);
    signal ds_dxb_dest_1                 : std_logic_vector(4 - 1 downto 0);
    signal ds_dxb_dest_value             : std_logic_vector(32 - 1 downto 0);
    signal ds_dxb_opcode                 : std_logic_vector(7 - 1 downto 0);
    signal ds_dxb_r_w                    : std_logic_vector(1 downto 0);
    signal ds_dxb_interrupt              : std_logic;

    -- decode_stage --> reg_file
    signal ds_rf_src0_adr                : std_logic_vector(3 downto 0);
    signal ds_rf_src1_adr                : std_logic_vector(3 downto 0);
    signal ds_rf_br_io_enbl              : std_logic_vector(1 downto 0);
    signal ds_rf_rst                     : std_logic;

    -- reg_file --> decode_stage
    signal rf_ds_op0_value               : std_logic_vector(31 downto 0);
    signal rf_ds_op1_value               : std_logic_vector(31 downto 0);
begin
    fetch_stage : entity work.fetch_stage
        port map(
            --IN
            clk                          => clk,
            rst                          => rst,

            in_interrupt                 => interrupt,
            in_if_flush                  => fsi_if_flush,
            in_stall                     => fsi_stall,
            in_parallel_load_pc_selector => fsi_parallel_load_pc_selector,
            in_loaded_pc_value           => fsi_loaded_pc_value,
            in_branch_address            => fsi_branch_address,
            in_hashed_address            => fsi_hashed_address,
            --OUT
            out_interrupt                => fs_fdb_interrupt,
            out_inst_length_bit          => fs_fdb_inst_length_bit,
            out_instruction_bits         => fs_fdb_instruction_bits,
            out_predicted_address        => fs_fdb_predicted_address,
            out_hashed_address           => fs_fdb_hashed_address,
            out_inc_pc                   => fs_fdb_inc_pc
        );

    f_d_buffer : entity work.f_d_buffer
        port map(
            --IN
            clk            => clk,

            in_flush       => fsi_if_flush,
            in_stall       => fsi_stall,
            in_instr       => fs_fdb_instruction_bits,
            in_next_adr    => fs_fdb_predicted_address,
            in_inc_pc      => fs_fdb_inc_pc,
            in_hashed_adr  => fs_fdb_hashed_address,
            in_interrupt   => fs_fdb_interrupt,
            in_reset       => rst,
            --OUT
            out_instr      => fdb_ds_instr,
            out_next_adr   => fdb_ds_next_adr,
            out_inc_pc     => fdb_ds_inc_pc,
            out_hashed_adr => fdb_ds_hashed_adr,
            out_interrupt  => fdb_ds_interrupt,
            out_reset      => fdb_ds_reset
        );

    decode_stage : entity work.decode_stage
        port map(
            --IN
            clk                     => clk,

            in_zero_flag            => 'U', --TODO

            fdb_instr               => fdb_ds_instr,
            fdb_next_adr            => fdb_ds_next_adr,
            fdb_inc_pc              => fdb_ds_inc_pc,
            fdb_hashed_adr          => fdb_ds_hashed_adr,
            fdb_interrupt           => fdb_ds_interrupt,
            fdb_reset               => fdb_ds_reset,

            rf_op0_value            => rf_ds_op0_value,
            rf_op1_value            => rf_ds_op1_value,
            --OUT
            out_if_flush            => fsi_if_flush,
            out_branch_adr_update   => fsi_branch_address,
            out_feedback_hashed_adr => fsi_hashed_address,

            dxb_alu_op              => ds_dxb_alu_op,
            dxb_operand0            => ds_dxb_operand0,
            dxb_operand1            => ds_dxb_operand1,
            dxb_dest_0              => ds_dxb_dest_0,
            dxb_dest_1              => ds_dxb_dest_1,
            dxb_dest_value          => ds_dxb_dest_value,
            dxb_opcode              => ds_dxb_opcode,
            dxb_r_w                 => ds_dxb_r_w,
            dxb_interrupt           => ds_dxb_interrupt,

            rf_src0_adr             => ds_rf_src0_adr,
            rf_src1_adr             => ds_rf_src1_adr,
            rf_br_io_enbl           => ds_rf_br_io_enbl,
            rf_rst                  => ds_rf_rst
        );

    --TODO: reg_file
    --TODO: d_x_buffer
    --TODO: execute_stage
    --TODO: x_m_buffer
    --TODO: mem_stage
    --TODO: m_w_buffer
    --TODO: wb_stage
end architecture;