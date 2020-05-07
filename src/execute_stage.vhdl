library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity execute_stage is
    port (
        clk                         : in std_logic;
        --reset is a signal propagated through buffers
        --rst                         : in std_logic;

        -- choose the alu inputs from the alu selectors
        operand_1                   : in std_logic_vector(31 downto 0);
        operand_2                   : in std_logic_vector(31 downto 0);
        --data forwarded from ALU -> ALU
        forwarded_data_1            : in std_logic_vector(31 downto 0);
        forwarded_data_2            : in std_logic_vector(31 downto 0);
        --data forwarded from Mem -> ALU
        forwarded_data_2_1          : in std_logic_vector(31 downto 0);
        forwarded_data_2_2          : in std_logic_vector(31 downto 0);

        -- from hazerd detection unit
        --00 -> just pass operand_1
        --01 -> alu -> alu
        --10 -> mem -> alu
        alu_op_1_selector           : in std_logic_vector(1 downto 0);   
        alu_op_2_selector           : in std_logic_vector(1 downto 0);

        -- the selected operation
        alu_operation               : in std_logic_vector(3 downto 0);

        --Memory address is Rsrc2 (operand_2)
        --initial_mem_address         : in std_logic_vector(31 downto 0);

        r_w_control                 : in std_logic_vector(1 downto 0);

        destination_register_in_1   : in std_logic_vector(3  downto 0);
        --Second one is used only in swap
        destination_register_in_2   : in std_logic_vector(3  downto 0);
        
        opCode_in                   : in std_logic_vector(6  downto 0);
        int_bit_in                  : in std_logic;

        --main regs
        alu_output                  : out std_logic_vector(31 downto 0);
        memory_address              : out std_logic_vector(31 downto 0);
        mem_in                      : out std_logic_vector(31 downto 0);  -- out from operand 1
        --propagation
        opCode_out                  : out std_logic_vector(6  downto 0);
        int_bit_out                 : out std_logic;
        r_w_control_out             : out std_logic_vector(1 downto 0);
        --write back addresses
        destination_register_out_1  : out std_logic_vector(3  downto 0);
        destination_register_out_2  : out std_logic_vector(3  downto 0);
        --useless
        ccr                         : out std_logic_vector(2  downto 0)
        
    );
end entity;

architecture rtl of execute_stage is
    signal alu_operand_1      : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_operand_2      : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_output_sig       : std_logic_vector(31 downto 0) := (others => '0');
begin

    --MAIN OUT REGS:
    --1- alu_output 32
    --  usually holds the data to be written back
    --  its address is always destination_register_out_1

    --2- mem_in_data 32
    --  usually holds the data that will be written into memory

    --3- mem_in_out_address 32
    --  usually holds the address of the data to be written or extracted

    --Operation analysis:

    --One operand operations (inc dec not)
    --      input: operand_1
    --      output: alu_output
    --      wb:     true -> destination_register_out_1

    --two operands operations (add sub and or )
    --      input: operand_1 & operand_2
    --      output: alu_output
    --      wb:     true -> destination_register_out_1

    --two operand operations (iadd shl shr)
    --      input: operand_1(Reg value) & operand_2(immediate value)
    --      output: alu_output
    --      wb:     true -> destination_register_out_1

    --SWAP...you will not do anything, they're already swapped
    --      input: operand_1(Rsrc_2) and operand_2(Rsrc_1)
    --      output: alu_output & (mem_in_data)---> I'm reusing these places
    --      wb:     true -> destination_register_out_1 && destination_register_out_2

    --stackers (push pop call ret rti)
    --      input: operand_1(Data) and operand_2(SP)
    --      output: mem_in_data & mem_adr
    --      wb:     it depends

    --loaders (ldm ldd)
    --      input: operand_1(NONE) and operand_2(immediate value or address)
    --      output: mem_in_out_adr (immediate or address)
    --      wb:     true -> destination_register_out_1

    --std
    --      input: operand_1(reg value) and operand_2(address)
    --      output: mem_in_data & mem_in_out_adr (address)
    --      wb:     false

    --jumppers (jz jmp)
    --      input: none
    --      output: none
    --      wb:     false


    --Propagated Signals
    opCode_out               <= opCode_in;
    int_bit_out              <= int_bit_in;
    r_w_control_out             <= r_w_control;
    destination_register_out_1 <= destination_register_in_1;
    destination_register_out_2 <= destination_register_in_2;

    memory_address              <= operand_2;

    --Swap special case
    with opCode_in(6 downto 3) select alu_output <=
                    operand_1   when "0001",  
                    alu_output_sig when others;

    with opCode_in(6 downto 3) select mem_in <=
                    operand_2   when "0001",  
                    operand_1 when others;


    --FOR DATA FORWARDING
    with alu_op_1_selector select alu_operand_1 <=
                    forwarded_data_1   when "10", 
                    forwarded_data_2_1 when "01",
                    operand_1          when "00",  
                    (others => 'Z')    when others;

    with alu_op_2_selector select alu_operand_2 <=
                    forwarded_data_2   when "10", 
                    forwarded_data_2_2 when "01",
                    operand_2          when "00",  
                    (others => 'Z')    when others;

    --alu_operand_1 <= forwarded_data_1 when alu_op_1_selector = '1' else operand_1;
    --alu_operand_2 <= forwarded_data_2 when alu_op_2_selector = '1' else operand_2;

    operation: entity work.alu port map (
        op    => alu_operation,
        a     => alu_operand_1,
        b     => alu_operand_2,
        ccr   => ccr,
        c     => alu_output_sig
    );

end architecture;