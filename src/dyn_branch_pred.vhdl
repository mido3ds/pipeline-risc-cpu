library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dyn_branch_pred is
    port (
        -- Reset
        rst             : in std_logic;

        -- Update predictor hash table
        prev_hashed_adr : in std_logic_vector(3 downto 0);
        -- taken or not to update FSM
        update          : in std_logic;
        -- update enable
        enable          : in std_logic;

        -- Get prediction
        cur_hashed_adr  : in std_logic_vector(3 downto 0);
        -- predict whether the branch taken or not
        taken           : out std_logic
    );
end entity;

architecture rtl of dyn_branch_pred is
    -- enable and output signals for all FSMs
    signal enable_0  : std_logic :='0';
    signal output_0  : std_logic;

    signal enable_1  : std_logic :='0';
    signal output_1  : std_logic;

    signal enable_2  : std_logic :='0';
    signal output_2  : std_logic;

    signal enable_3  : std_logic :='0';
    signal output_3  : std_logic;

    signal enable_4  : std_logic :='0';
    signal output_4  : std_logic;

    signal enable_5  : std_logic :='0';
    signal output_5  : std_logic;

    signal enable_6  : std_logic :='0';
    signal output_6  : std_logic;
    
    signal enable_7  : std_logic :='0';
    signal output_7  : std_logic;

    signal enable_8  : std_logic :='0';
    signal output_8  : std_logic;

    signal enable_9  : std_logic :='0';
    signal output_9  : std_logic;

    signal enable_10 : std_logic :='0';
    signal output_10 : std_logic;

    signal enable_11 : std_logic :='0';
    signal output_11 : std_logic;

    signal enable_12 : std_logic :='0';
    signal output_12 : std_logic;

    signal enable_13 : std_logic :='0';
    signal output_13 : std_logic;

    signal enable_14 : std_logic :='0';
    signal output_14 : std_logic;

    signal enable_15 : std_logic :='0';
    signal output_15 : std_logic;

begin
    -- all FSMs port maps (Total of 16 FSMs)
    fsm_0 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_0,
            input  => update,
            output => output_0
        );
    
    fsm_1 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_1,
            input  => update,
            output => output_1
        );
    
    fsm_2 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_2,
            input  => update,
            output => output_2
        );

    fsm_3 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_3,
            input  => update,
            output => output_3
        );
    
    fsm_4 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_4,
            input  => update,
            output => output_4
        );

    fsm_5 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_5,
            input  => update,
            output => output_5
        );

    fsm_6 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_6,
            input  => update,
            output => output_6
        );

    fsm_7 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_7,
            input  => update,
            output => output_7
        );

    fsm_8 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_8,
            input  => update,
            output => output_8
        );

    fsm_9 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_9,
            input  => update,
            output => output_9
        );
        
    fsm_10 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_10,
            input  => update,
            output => output_10
        );

    fsm_11 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_11,
            input  => update,
            output => output_11
        );

    fsm_12 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_12,
            input  => update,
            output => output_12
        );

    fsm_13 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_13,
            input  => update,
            output => output_13
        );

    fsm_14 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_14,
            input  => update,
            output => output_14
        );

    fsm_15 : entity work.moore(rtl)
        port map(
            rst    => rst,
            enable => enable_15,
            input  => update,
            output => output_15
        );

    -- input activation process
    process (enable, prev_hashed_adr)
    begin
        if prev_hashed_adr = "0000" then
            enable_0 <= enable;
        elsif prev_hashed_adr = "0001" then
            enable_1 <= enable;
        elsif prev_hashed_adr = "0010" then
            enable_2 <= enable;
        elsif prev_hashed_adr = "0011" then
            enable_3 <= enable;
        elsif prev_hashed_adr = "0100" then
            enable_4 <= enable;
        elsif prev_hashed_adr = "0101" then
            enable_5 <= enable;
        elsif prev_hashed_adr = "0110" then
            enable_6 <= enable;
        elsif prev_hashed_adr = "0111" then
            enable_7 <= enable;
        elsif prev_hashed_adr = "1000" then
            enable_8 <= enable;
        elsif prev_hashed_adr = "1001" then
            enable_9 <= enable;
        elsif prev_hashed_adr = "1010" then
            enable_10 <= enable;
        elsif prev_hashed_adr = "1011" then
            enable_11 <= enable;
        elsif prev_hashed_adr = "1100" then
            enable_12 <= enable;
        elsif prev_hashed_adr = "1101" then
            enable_13 <= enable;
        elsif prev_hashed_adr = "1110" then
            enable_14 <= enable;
        elsif prev_hashed_adr = "1111" then
            enable_15 <= enable;
        end if;
    end process;

    -- output activation process
    process (cur_hashed_adr)
    begin
        if cur_hashed_adr = "0000" then
            taken <= output_0;
        elsif cur_hashed_adr = "0001" then
            taken <= output_1;
        elsif cur_hashed_adr = "0010" then
            taken <= output_2;
        elsif cur_hashed_adr = "0011" then
            taken <= output_3;
        elsif cur_hashed_adr = "0100" then
            taken <= output_4;
        elsif cur_hashed_adr = "0101" then
            taken <= output_5;
        elsif cur_hashed_adr = "0110" then
            taken <= output_6;
        elsif cur_hashed_adr = "0111" then
            taken <= output_7;
        elsif cur_hashed_adr = "1000" then
            taken <= output_8;
        elsif cur_hashed_adr = "1001" then
            taken <= output_9;
        elsif cur_hashed_adr = "1010" then
            taken <= output_10;
        elsif cur_hashed_adr = "1011" then
            taken <= output_11;
        elsif cur_hashed_adr = "1100" then
            taken <= output_12;
        elsif cur_hashed_adr = "1101" then
            taken <= output_13;
        elsif cur_hashed_adr = "1110" then
            taken <= output_14;
        elsif cur_hashed_adr = "1111" then
            taken <= output_15;
        end if;
    end process;
end architecture;