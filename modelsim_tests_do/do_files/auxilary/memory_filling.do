
#TO INIT. THE SIMULATION
vsim -gui work.main

#PASTE HERE THE MEMO FILE FROM CASES_DO_MEMORY/FILENAME.DO
	#FOR EXAMPLE:
	
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(0)
mem load -filltype value -filldata 0010 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(1)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(2)
mem load -filltype value -filldata 0100 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(3)
mem load -filltype value -filldata 0000 -fillradix hexadecimal /main/fetch_stage/inst_mem/data(4)

#CHANGE THE FILENAME
mem save -o FILENAME.mem -f mti -data symbolic -addr hex /main/fetch_stage/inst_mem/data

#QUIT
quit -sim