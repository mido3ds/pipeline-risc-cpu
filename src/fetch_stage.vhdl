library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity fetch_stage is
    port (
        clk                       : in std_logic;
        rst                       : in std_logic;
        interrupt                 : in std_logic;
        if_flush                  : in std_logic;
        stall                     : in std_logic;
        parallel_load_pc_selector : in std_logic;
        loaded_pc_value           : in std_logic_vector(31 downto 0);
        branch_address            : in std_logic_vector(31 downto 0);
        in_hashed_address         : in std_logic_vector(3 downto 0);
        int_bit                   : out std_logic;
        inst_length_bit           : out std_logic; -- 16 or 32 bits
        instruction_bits          : out std_logic_vector(31 downto 0);
        predicted_address         : out std_logic_vector(31 downto 0);
        out_hashed_address        : out std_logic_vector(3 downto 0);
        current_pc_value          : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of fetch_stage is
begin
    null;
end architecture;