mem save -o fileName.mem -f mti -data symbolic -addr hex /main/fetch_stage/inst_mem/data


#main waves
add wave -position end  sim:/main/clk
add wave -position end  sim:/main/rst
add wave -position end  sim:/main/interrupt
add wave -position end  sim:/main/hlt

#CCR and IO Ports
add wave -position end  sim:/main/ccr
add wave -position end  sim:/main/in_value
add wave -position end  sim:/main/out_value

#Fetch_Decode buffer
add wave -position end  sim:/main/fs_fdb_instruction_bits
add wave -position end  sim:/main/fs_fdb_predicted_address
add wave -position end  sim:/main/fs_fdb_inc_pc
add wave -position end  sim:/main/fs_fdb_hashed_address

#Decode_Execute buffer
add wave -position end  sim:/main/ds_dxb_alu_op
add wave -position end  sim:/main/ds_dxb_dest_0
#NOTE: active only when swap instr.
add wave -position end  sim:/main/ds_dxb_dest_1
add wave -position end  sim:/main/ds_dxb_opcode
add wave -position end  sim:/main/ds_dxb_r_w
add wave -position end  sim:/main/ds_dxb_src2_value
add wave -position end  sim:/main/ds_dxb_src2_sel
add wave -position end  sim:/main/rf_dxb_op0_value
add wave -position end  sim:/main/rf_dxb_op1_value

#Register File
add wave -position end  sim:/main/rf_ds_instr_adr
add wave -position end  sim:/main/rf_dst0_adr
add wave -position end  sim:/main/rf_dst1_adr
add wave -position end  sim:/main/rf_src0_adr
add wave -position end  sim:/main/rf_src1_adr
add wave -position end  sim:/main/rf_wb0_value
add wave -position end  sim:/main/rf_wb1_value
add wave -position end  sim:/main/rf_br_io_enbl
add wave -position end  sim:/main/rf_rst

#Execute_Memory_buffer
add wave -position end  sim:/main/xs_xmb_alu_output_1
add wave -position end  sim:/main/xs_xmb_alu_output_2
add wave -position end  sim:/main/xs_xmb_destination_0
add wave -position end  sim:/main/xs_xmb_destination_1
add wave -position end  sim:/main/xs_xmb_mem_adr
add wave -position end  sim:/main/xs_xmb_mem_input
add wave -position end  sim:/main/xs_xmb_opcode
add wave -position end  sim:/main/xs_xmb_r_w
add wave -position end  sim:/main/xs_hdu_src_0
add wave -position end  sim:/main/xs_hdu_src_1

#STALLING 
add wave -position end  sim:/main/ms_stalling_enable

#Memory_WriteBack_buffer
add wave -position end  sim:/main/ms_mwb_aluout_1
add wave -position end  sim:/main/ms_mwb_aluout_2
add wave -position end  sim:/main/ms_mwb_mem_input
add wave -position end  sim:/main/ms_mwb_opcode
add wave -position end  sim:/main/ms_mwb_dest_0_adr
add wave -position end  sim:/main/ms_mwb_dest_1_adr

#Write back to reg file
add wave -position end  sim:/main/ws_rf_dest_reg_1
add wave -position end  sim:/main/ws_rf_dest_reg_2
add wave -position end  sim:/main/ws_rf_dest_reg_1_value
add wave -position end  sim:/main/ws_rf_dest_reg_2_value
