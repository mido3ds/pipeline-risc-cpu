'''
Simple script that reads arg1(bin file) and produces a hexa file out of it.
'''
import sys

bina = ["0000","0001","0010","0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101","1110","1111"]
hexa = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]

if __name__ == "__main__":

    args = sys.argv
    if (len(args)) <= 1:
        print("add the path of the hexa file")
        sys.exit()

    path_to_hexa = args[1]

    f = open(path_to_hexa, "r")
    lines = f.readlines()

    out_file = open("./hex files/hexa.txt", "w")
    print("started...")
    for i, line in enumerate(lines):
        
        hexa_line = ""
        if len(line) <16:
            continue
        for j in range(4):
            start = j*4
            end = ((j+1)*4)
            sub_bina = line[start:end]
            idx = bina.index(sub_bina)
            hexa_line += hexa[idx]
        #when finished write it out
        out_file.write(hexa_line)
        out_file.write("\n")
    out_file.close()
    f.close()
    print("finished")