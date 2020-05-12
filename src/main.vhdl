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
    -- hdu --> fetch_stage,f_d_buffer,d_x_buffer
    signal hdu_stall                     : std_logic;

    --> fetch_stage
    signal fsi_if_flush                  : std_logic;
    signal fsi_parallel_load_pc_selector : std_logic;
    signal fsi_loaded_pc_value           : std_logic_vector(31 downto 0);
    signal fsi_branch_address            : std_logic_vector(31 downto 0);
    signal fsi_hashed_address            : std_logic_vector(3 downto 0);

    -- fetch_stage --> f_d_buffer
    signal fs_fdb_interrupt              : std_logic;
    signal fs_fdb_inst_length_bit        : std_logic;
    signal fs_fdb_instruction_bits       : std_logic_vector(31 downto 0);
    signal fs_fdb_predicted_address      : std_logic_vector(31 downto 0);
    signal fs_fdb_hashed_address         : std_logic_vector(3 downto 0);
    signal fs_fdb_inc_pc                 : std_logic_vector(31 downto 0);

    -- f_d_buffer --> decode_stage
    signal fdb_ds_instr                  : std_logic_vector(31 downto 0);
    signal fdb_ds_inst_length_bit        : std_logic;
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

    -- d_x_buffer --> execute_stage
    signal dxb_xs_alu_op                 : std_logic_vector (3 downto 0);
    signal dxb_xs_operand0               : std_logic_vector(32 - 1 downto 0);
    signal dxb_xs_operand1               : std_logic_vector(32 - 1 downto 0);
    signal dxb_xs_dest_0                 : std_logic_vector(4 - 1 downto 0);
    signal dxb_xs_dest_1                 : std_logic_vector(4 - 1 downto 0);
    signal dxb_xs_dest_value             : std_logic_vector(32 - 1 downto 0);
    signal dxb_xs_opcode                 : std_logic_vector(7 - 1 downto 0);
    signal dxb_xs_r_w                    : std_logic_vector(1 downto 0);
    signal dxb_xs_interrupt              : std_logic;
begin
    fetch_stage : entity work.fetch_stage
        port map(
            --IN
            clk                          => clk,
            rst                          => rst,

            in_interrupt                 => interrupt,
            in_if_flush                  => fsi_if_flush,
            in_stall                     => hdu_stall,
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
            clk             => clk,

            in_flush        => fsi_if_flush,
            in_stall        => hdu_stall,
            in_instr        => fs_fdb_instruction_bits,
            in_inst_length  => fs_fdb_inst_length_bit,
            in_next_adr     => fs_fdb_predicted_address,
            in_inc_pc       => fs_fdb_inc_pc,
            in_hashed_adr   => fs_fdb_hashed_address,
            in_interrupt    => fs_fdb_interrupt,
            in_reset        => rst,
            --OUT
            out_instr       => fdb_ds_instr,
            out_inst_length => fdb_ds_inst_length_bit,
            out_next_adr    => fdb_ds_next_adr,
            out_inc_pc      => fdb_ds_inc_pc,
            out_hashed_adr  => fdb_ds_hashed_adr,
            out_interrupt   => fdb_ds_interrupt,
            out_reset       => fdb_ds_reset
        );

    decode_stage : entity work.decode_stage
        port map(
            --IN
            clk                     => clk,

            in_zero_flag            => 'U', --TODO: from execute_stage

            fdb_instr               => fdb_ds_instr,
            fdb_next_adr            => fdb_ds_next_adr,
            fdb_inc_pc              => fdb_ds_inc_pc,
            fdb_hashed_adr          => fdb_ds_hashed_adr,
            fdb_interrupt           => fdb_ds_interrupt,
            fdb_reset               => fdb_ds_reset,
            fdb_inst_length         => fdb_ds_inst_length_bit,

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
    -- reg_file : entity work.reg_file
    --     port map(
    --         --IN
    --         clk         => clk,
    --         rst         => ds_rf_rst,

    --         -- dst0_adr    => ?????, --TODO
    --         -- dst1_adr    => ?????, --TODO
    --         src0_adr    => ds_rf_src0_adr,
    --         src1_adr    => ds_rf_src1_adr,
    --         -- fetch_adr   => ?????, --TODO

    --         -- wb0_value   => ?????, --TODO
    --         -- wb1_value   => ?????, --TODO

    --         -- in_value    => ?????, --TODO

    --         br_io_enbl  => ds_rf_br_io_enbl,
    --         --OUT
    --         op0_value   => rf_ds_op0_value,
    --         op1_value   => rf_ds_op1_value,

    --         -- fetch_value => ?????, --TODO
    --         -- instr_adr   => ?????, --TODO

    --         -- out_value   => ????? --TODO
    --     );

    d_x_buffer : entity work.d_x_buffer
        port map(
            --IN
            clk            => clk,

            in_stall       => hdu_stall,
            in_alu_op      => ds_dxb_alu_op,
            in_operand0    => ds_dxb_operand0,
            in_operand1    => ds_dxb_operand1,
            in_dest_0      => ds_dxb_dest_0,
            in_dest_1      => ds_dxb_dest_1,
            in_dest_value  => ds_dxb_dest_value,
            in_opcode      => ds_dxb_opcode,
            in_r_w         => ds_dxb_r_w,
            in_interrupt   => ds_dxb_interrupt,
            -- OUT
            out_alu_op     => dxb_xs_alu_op,
            out_operand0   => dxb_xs_operand0,
            out_operand1   => dxb_xs_operand1,
            out_dest_0     => dxb_xs_dest_0,
            out_dest_1     => dxb_xs_dest_1,
            out_dest_value => dxb_xs_dest_value,
            out_opcode     => dxb_xs_opcode,
            out_r_w        => dxb_xs_r_w,
            out_interrupt  => dxb_xs_interrupt
        );

    --TODO: execute_stage
    --TODO: x_m_buffer
    --TODO: mem_stage
    --TODO: m_w_buffer
    --TODO: wb_stage
end architecture;