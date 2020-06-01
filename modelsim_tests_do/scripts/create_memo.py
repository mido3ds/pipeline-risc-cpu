'''
this script reads the hexa file and construct it into a 
do file for memory loading
'''
import sys

memo_line_1 = "mem load -filltype value -filldata "
memo_line_2 = " -fillradix hexadecimal /main/fetch_stage/inst_mem/data("
memo_end = ")"

if __name__ == "__main__":
    args = sys.argv
    if (len(args)) <= 1:
        print("add the path of the hexa file")
        sys.exit()

    fileName = args[1]
    path_to_hexa = "../cases_hex/"
    path_to_hexa+=fileName
    path_to_hexa+=".hex"
    
    f = open(path_to_hexa, "r")
    lines = f.readlines()

    out_path = "../cases_do_memory/"
    out_path += fileName
    out_path += ".do"
    
    out_file = open(out_path, "w")

    print("started...")
    for i, line in enumerate(lines):
        memo_line = memo_line_1
        memo_line += str(line[0:4])
        memo_line += memo_line_2
        memo_line += str(i)
        memo_line += memo_end
                
        #when finished write it out
        out_file.write(memo_line)
        out_file.write("\n")
    out_file.close()
    f.close()
    print("finished")