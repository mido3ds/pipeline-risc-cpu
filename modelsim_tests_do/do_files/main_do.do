vsim -gui work.main


force -freeze sim:/main/clk 1 0, 0 {50 ns} -r 100


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

force -freeze sim:/main/ccr 3'h0 0
force -freeze sim:/main/rst 1 0
run
run
force -freeze sim:/main/rst 0 0
noforce sim:/main/ccr


add wave -position end  sim:/main/clk
add wave -position end  sim:/main/rst
add wave -position end  sim:/main/hlt
add wave -position end  sim:/main/ccr
add wave -position end  sim:/main/in_value
add wave -position end  sim:/main/out_value



mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(0)
mem load -filltype value -filldata 0010 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(1)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(2)
mem load -filltype value -filldata 0100 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(3)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(4)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(5)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(6)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(7)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(8)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(9)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(10)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(11)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(12)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(13)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(14)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(15)
mem load -filltype value -filldata 7A20 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(16)
mem load -filltype value -filldata 7A20 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(17)
mem load -filltype value -filldata 7920 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(18)
mem load -filltype value -filldata 7B20 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(19)
mem load -filltype value -filldata 7000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(20)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(21)


