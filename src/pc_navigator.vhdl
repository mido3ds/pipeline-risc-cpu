library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity pc_navigator is
    port (

        clk                         : in  std_logic;
        int_bit_in                  : in  std_logic;
        enable                      : in  std_logic;
        stalling                    : in  std_logic;
        opCode_in                   : in  std_logic_vector(6  downto 0);
        address                     : in  std_logic_vector(31 downto 0);
        stack_pointer               : out std_logic_vector(31 downto 0);
        pc_selector                 : out std_logic;
        stalling_enable             : out std_logic
    );
end entity;

architecture rtl of pc_navigator is
    -- signals needed
    signal enable_addition        : std_logic                          := '0';
    signal enable_subtraction     : std_logic                          := '0';
    signal res1_addition          : std_logic_vector(31 downto 0)      := (others => '0');
    signal res2_addition          : std_logic_vector(31 downto 0)      := (others => '0');
    signal res1_subtraction       : std_logic_vector(31 downto 0)      := (others => '0');
    signal res2_subtraction       : std_logic_vector(31 downto 0)      := (others => '0');

begin

    -- we need incrementor and decrementor entities here

    inc1 : entity work.incrementor(rtl)
    generic map ( N => 32)
    port map (
        a          => address,
        enbl       => enable_addition,
        c          => res1_addition
    );

    inc2 : entity work.incrementor(rtl)
    generic map ( N => 32)
    port map (
        a          => res1_addition,
        enbl       => enable_addition,
        c          => res2_addition
    );

    dec1 : entity work.decrementor(rtl)
    generic map ( N => 32)
    port map (
        a          => address,
        enbl       => enable_subtraction,
        c          => res1_subtraction
    );

    dec2 : entity work.decrementor(rtl)
    generic map ( N => 32)
    port map (
        a          => res1_subtraction,
        enbl       => enable_subtraction,
        c          => res2_subtraction
    );


    process(clk)
    begin

        if rising_edge(clk) then

            if enable = '1' then

                if int_bit_in = '1' then                  -- pc store so don't active the pc selector
                    pc_selector                <= '0';

                    if stalling = '1' then
                        stalling_enable        <= '0';
                    else
                        stalling_enable        <= '1';
                    end if;
                    enable_subtraction         <= '1';
                    enable_addition            <= '0';
                    stack_pointer              <= res2_subtraction;
                    -- decrement the memory and store the result in sp output

                elsif opCode_in = "0000101" then          -- rti operation so activate the pc selector and stalling enable bits
                    pc_selector                <= '1';

                    if stalling = '1' then
                        stalling_enable        <= '0';
                    else
                        stalling_enable        <= '1';
                    end if;

                    enable_addition            <= '1';
                    enable_subtraction         <= '0';
                    stack_pointer              <= res2_addition;

                elsif opCode_in = "0000100" then
                    pc_selector                <= '1';
                    stalling_enable            <= '0';
                    stack_pointer              <= (others => '0');

                end if;
                    -- check depending on the opcode to enable stalling bit or no
            else

                stalling_enable                <= '0';
                pc_selector                    <= '0';
                stack_pointer                  <= (others => '0');

            end if;

        end if;

    end process;

end architecture;