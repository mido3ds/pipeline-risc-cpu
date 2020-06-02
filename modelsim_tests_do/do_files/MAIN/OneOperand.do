#To restart the simulation
restart -f

#Init the simulation
vsim -gui work.main

#init the clock
force -freeze sim:/main/clk 1 0, 0 {50 ns} -r 100

#Force down the test_bench signals
force -freeze sim:/main/tb_controls 0 0
force -freeze sim:/main/tb_dm_rd 0 0
force -freeze sim:/main/tb_dm_wr 0 0
force -freeze sim:/main/tb_dm_is_stack 0 0
force -freeze sim:/main/tb_dm_data_in 0 0
force -freeze sim:/main/tb_dm_adr 0 0
force -freeze sim:/main/tb_ccr_sel 0 0
force -freeze sim:/main/tb_ccr_in 0 0
force -freeze sim:/main/tb_rf_src0_adr 0 0
force -freeze sim:/main/tb_rf_dst0_adr 0 0
force -freeze sim:/main/tb_rf_dst0_value 0 0
force -freeze sim:/main/tb_im_rd 0 0
force -freeze sim:/main/tb_im_wr 0 0
force -freeze sim:/main/tb_im_data_in 0 0
force -freeze sim:/main/tb_im_adr 0 0


#Added waves..

#main waves
add wave -position end  sim:/main/clk
add wave -position end  sim:/main/rst
add wave -position end  sim:/main/interrupt
add wave -position end  sim:/main/hlt
add wave -position end  sim:/main/in_value
add wave -position end  sim:/main/out_value
add wave -position end  sim:/main/ccr

add wave -position end  sim:/main/fs_fdb_instruction_bits
add wave -position end  sim:/fetch_stage/pc
add wave -position end  sim:/main/reg_file/sp

#Reg file
add wave -position end  sim:/main/reg_file/r0
add wave -position end  sim:/main/reg_file/r1
add wave -position end  sim:/main/reg_file/r2
add wave -position end  sim:/main/reg_file/r3
add wave -position end  sim:/main/reg_file/r4
add wave -position end  sim:/main/reg_file/r5
add wave -position end  sim:/main/reg_file/r6
add wave -position end  sim:/main/reg_file/r7


#Stalling and Forwarding Signals
add wave -position end  sim:/main/hdu/operand_1_select
add wave -position end  sim:/main/hdu/operand_2_select
add wave -position end  sim:/main/hdu_stall
add wave -position end  sim:/main/fsi_if_flush


#Run reset signal for one or two cycles
force -freeze sim:/main/interrupt 0 0
force -freeze sim:/main/rst 1 0
run
run
force -freeze sim:/main/rst 0 0



#load the memory from modelsim_tests_do/cases_mem folder/filename.mem
#FileNames = [Branch, BranchPrediction, Memory, MemoryCache, OneOperand, TwoOperand]
mem load -i {cases_mem/OneOperand.mem} /main/fetch_stage/inst_mem/data


####################ADD these to disable the forwarding unit#################################

#TO disable forwarding...uncomment these
#force -freeze sim:/main/hdu/operand_1_select 0 0
#force -freeze sim:/main/hdu/operand_2_select 0 0

#TO disable flushing..no need here!
#force -freeze sim:/main/fsi_if_flush 0 0

####################ANY ADDED INSTRUCTIONS GOES HEERE########################################
run
run
run
force -freeze sim:/main/in_value 5 0
run
run
run
run
force -freeze sim:/main/in_value 10 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run