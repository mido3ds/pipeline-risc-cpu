library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity main is
    port (
        clk, rst, interrupt : in std_logic;
        in_value            : in std_logic_vector(31 downto 0);
        out_value           : out std_logic_vector(31 downto 0);

        -- testing signals

        -- '1' if testbench is taking control now of the memory and regs
        tb_controls         : in std_logic;

        -- to reg_file
        tb_rf_src0_adr      : in std_logic_vector(3 downto 0);
        tb_rf_dst0_adr      : in std_logic_vector(3 downto 0);
        tb_rf_dst0_value    : in std_logic_vector(31 downto 0);
        -- from reg_file
        rf_tb_dst0_value    : out std_logic_vector(31 downto 0);

        -- to instr_mem
        tb_im_rd            : in std_logic;
        tb_im_wr            : in std_logic;
        tb_im_data_in       : in std_logic_vector(15 downto 0);
        tb_im_adr           : in std_logic_vector(31 downto 0);
        -- from instr_mem
        tb_im_data_out      : out std_logic_vector(15 downto 0)

        --TODO: data_mem and ccr
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
    signal fdb_ds_inc_pc                 : std_logic_vector(31 downto 0);
    signal fdb_ds_interrupt              : std_logic;

    -- decode_stage --> d_x_buffer
    signal ds_dxb_alu_op                 : std_logic_vector (3 downto 0);
    signal ds_dxb_operand0               : std_logic_vector(32 - 1 downto 0); -- TODO: where its input?
    signal ds_dxb_operand1               : std_logic_vector(32 - 1 downto 0); -- TODO: where its input?
    signal ds_dxb_dest_0                 : std_logic_vector(4 - 1 downto 0);
    signal ds_dxb_dest_1                 : std_logic_vector(4 - 1 downto 0);
    signal ds_dxb_opcode                 : std_logic_vector(7 - 1 downto 0);
    signal ds_dxb_r_w                    : std_logic_vector(1 downto 0);
    signal ds_dxb_interrupt              : std_logic;
    signal ds_dxb_src2_value             : std_logic_vector(32 - 1 downto 0);
    signal ds_dxb_src2_sel               : std_logic;

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

    --> reg_file
    signal rf_dst0_adr                   : std_logic_vector(3 downto 0);
    signal rf_dst1_adr                   : std_logic_vector(3 downto 0);
    signal rf_src0_adr                   : std_logic_vector(3 downto 0);
    signal rf_src1_adr                   : std_logic_vector(3 downto 0);
    signal rf_wb0_value                  : std_logic_vector(31 downto 0);
    signal rf_br_io_enbl                 : std_logic_vector(1 downto 0);
    signal rf_rst                        : std_logic;
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
            out_inc_pc                   => fs_fdb_inc_pc,

            -- testing
            tb_controls                  => tb_controls,
            tb_mem_rd                    => tb_im_rd,
            tb_mem_wr                    => tb_im_wr,
            tb_mem_data_in               => tb_im_data_in,
            tb_mem_adr                   => tb_im_adr,
            tb_mem_data_out              => tb_im_data_out
        );

    f_d_buffer : entity work.f_d_buffer
        port map(
            --IN
            clk             => clk,

            in_flush        => fsi_if_flush,
            in_instr        => fs_fdb_instruction_bits,
            in_inc_pc       => fs_fdb_inc_pc,
            in_interrupt    => fs_fdb_interrupt,
            --OUT
            out_instr       => fdb_ds_instr,
            out_inc_pc      => fdb_ds_inc_pc,
            out_interrupt   => fdb_ds_interrupt
        );

    decode_stage : entity work.decode_stage
        port map(
            --IN
            -- in_zero_flag            => ????, --TODO: from execute_stage.ccr_out(CCR_ZERO)

            fdb_instr               => fdb_ds_instr,
            fdb_inc_pc              => fdb_ds_inc_pc,
            fdb_interrupt           => fdb_ds_interrupt,
            -- mem_stalling_bit     => ????, -- TODO from memory_stage.stalling_enable
            in_port                 => in_value,

            --OUT
            dxb_alu_op              => ds_dxb_alu_op,
            dxb_dest_0              => ds_dxb_dest_0,
            dxb_dest_1              => ds_dxb_dest_1,
            dxb_opcode              => ds_dxb_opcode,
            dxb_r_w                 => ds_dxb_r_w,
            dxb_interrupt           => ds_dxb_interrupt,

            rf_src0_adr             => ds_rf_src0_adr,
            rf_src1_adr             => ds_rf_src1_adr,

            src2_value              => ds_dxb_src2_value,
            src2_value_selector     => ds_dxb_src2_sel
        );

    --TODO: reg_file
    -- reg_file : entity work.reg_file
    --     port map(
    --         --IN
    --         clk         => clk,
    --         rst         => rf_rst,

    --         dst0_adr    => rf_dst0_adr,
    --         dst1_adr    => rf_dst1_adr,
    --         src0_adr    => rf_src0_adr,
    --         src1_adr    => rf_src1_adr,
    --         -- fetch_adr   => ?????, --TODO

    --         wb0_value   => rf_wb0_value,
    --         -- wb1_value   => ?????, --TODO

    --         in_value    => in_value,

    --         br_io_enbl  => rf_br_io_enbl,
    --         --OUT
    --         op0_value   => rf_ds_op0_value,
    --         op1_value   => rf_ds_op1_value,

    --         -- fetch_value => ?????, --TODO
    --         -- instr_adr   => ?????, --TODO

    --         out_value   => out_value
    --     );
    --IN
    rf_rst           <= rst or ds_rf_rst;
    -- rf_dst0_adr <= tb_rf_dst0_adr when tb_controls = '1' else ????; --TODO
    -- rf_dst1_adr <= (others => '1') when tb_controls = '1' else ????; --TODO
    rf_src0_adr      <= tb_rf_src0_adr when tb_controls = '1' else ds_rf_src0_adr;
    rf_src1_adr      <= (others => '1') when tb_controls = '1' else ds_rf_src1_adr;
    -- rf_wb0_value     <= tb_rf_dst0_value when tb_controls = '1' else ????; --TODO
    rf_br_io_enbl    <= "00" when tb_controls = '1' else ds_rf_br_io_enbl;
    --OUT
    rf_tb_dst0_value <= rf_ds_op0_value;

    d_x_buffer : entity work.d_x_buffer
        port map(
            --IN
            clk            => clk,

            in_stall       => hdu_stall,
            in_alu_op      => ds_dxb_alu_op,
            in_operand0    => ds_dxb_operand0,
            in_operand1    => ds_dxb_operand1,
            in_src2_value  => ds_dxb_src2_value,
            in_sel_src2    => ds_dxb_src2_sel,
            in_dest_0      => ds_dxb_dest_0,
            in_dest_1      => ds_dxb_dest_1,
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
    -- execute_stage : entity work.execute_stage
    --     port map(
    --         --IN
    --         clk                        => clk,

    --         operand_1                  => dxb_xs_operand0,
    --         operand_2                  => dxb_xs_operand1,
    --         alu_op_1_selector          => ?????, --TODO
    --         alu_op_2_selector          => ?????, --TODO
    --         alu_operation              => dxb_xs_alu_op,
    --         destination_register_1_in  => dxb_xs_dest_0,
    --         destination_register_2_in  => dxb_xs_dest_1,
    --         opCode_in                  => dxb_xs_opcode,
    --         int_bit_in                 => dxb_xs_interrupt,
    --         --OUT
    --         alu_output                 => ?????, --TODO
    --         ccr_out                    => ?????, --TODO
    --         memory_address             => ?????, --TODO
    --         memory_input               => ?????, --TODO
    --         opCode_out                 => ?????, --TODO
    --         destination_register_1_out => ?????, --TODO
    --         destination_register_2_out => ?????, --TODO
    --         destination_1_value_out    => ?????, --TODO
    --         destination_2_value_out    => ?????, --TODO
    --         interrupt_bit_out          => ?????, --TODO
    --     );

    --TODO: x_m_buffer
    --TODO: mem_stage
    --TODO: m_w_buffer
    --TODO: wb_stage
end architecture;