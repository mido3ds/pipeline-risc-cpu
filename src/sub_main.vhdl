library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity sub_main is
    port (

        clk                 : in std_logic
        
    );
end entity;

architecture rtl of sub_main is
    --SIGNALS:
    signal emp :  std_logic_vector(31 downto 0); -- DST
    signal zero_flag_sig, if_flush_sig, rst_sig : std_logic := '0';
    signal op0_value_sig, op1_value_sig : std_logic_vector(31 downto 0); -- OP
    signal branch_adr_update_sig  : std_logic_vector(31 downto 0);
    signal feedback_hashed_adr_sig :std_logic_vector(3 downto 0);
    signal src0_adr_sig, src1_adr_sig : std_logic_vector (3 downto 0);
begin

    decode_Stage_0 : entity work.decode_stage
        port map(
            ---------in
            clk => clk,
            IF_ID_buffer=> --buffer
            zero_flag => zero_flag_sig,
            op0_value=> op0_value_sig,
            op1_value=> op1_value_sig,
            --------out
            if_flush=> if_flush_sig,
            branch_adr_update=> branch_adr_update_sig, 
            feedback_hashed_adr=> feedback_hashed_adr_sig,
            ID_EX_buffer=> --buffer
            src0_adr=> src0_adr_sig,
            src1_adr=> src1_adr_sig,
            rst => rst_sig
        );

    reg_file_0 : entity work.reg_file
        port map(
            ---------in
            dst0_adr => emp(3 downto 0),--empty
            dst1_adr => emp(3 downto 0),--empty
            src0_adr => src0_adr_sig,
            src1_adr => src1_adr_sig,
            fetch_adr => emp(3 downto 0),--empty
            wb0_value => emp(31 downto 0),--emp
            wb1_value => emp(31 downto 0),--emp
            in_value => emp(31 downto 0),--emp
            rst => rst_sig,
            clk => clk,
            br_io_enbl => 
            -----------out
            op0_value => op0_value_sig,
            op1_value => op1_value_sig,
            fetch_value => emp(31 downto 0), --emp
            instr_adr => emp(31 downto 0),--emp
            out_value => emp(31 downto 0)--emp
        );


end architecture;