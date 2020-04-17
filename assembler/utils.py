def gen_layout(ram_entries):
    """
        Write RAM layout to output file as HEX.
        Parameters:
        ram_entries (dict): dictionary of processed instructions.
    """
    ram_layout = [hex(int('0', 2))] * (2**8) # initialize layout with zeros
    # loop over all RAM blocks
    for block in ram_entries.keys():
        idx = int(block, 16)
        # insert all block content in RAM layout
        for i in range(idx,idx+len(ram_entries[block])):
            ram_layout[i] = hex(int(ram_entries[block][i-idx], 2))
    return ram_layout

def write_hex(ram_layout, output_txt):
    """
        Write RAM layout to output file as HEX.
        Parameters:
        ram_layout (list): list of instructions in RAM layout.
        output_txt (string): name of outut text.
    """            
    out_file = open("io/"+output_txt, "w")    
    for entry in ram_layout:
        out_file.write(entry)
        out_file.write("\n")
    out_file.close()