library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM is
    port (
        -- IN
        rst    : in std_logic;
        enable : in std_logic;
        input  : in std_logic;
        -- OUT
        output : out std_logic
    );
end entity;

-------------- Synchronized -------------
Architecture moore_arch of FSM is
    
    type states is (strongly_not_taken, weakly_not_taken, weakly_taken, strongly_taken);
    signal current_state : states := strongly_not_taken;
    
    begin
    
        --calculate and store state
        process (rst, enable) 
            begin
                if rst = '1' then
                    current_state <= strongly_not_taken;
                elsif enable = '1' then
                    case current_state is
                        when strongly_not_taken => 
                            if input = '1' then current_state <= weakly_not_taken; else current_state <= strongly_not_taken; end if;
                        when weakly_not_taken =>
                            if input = '1' then current_state <= weakly_taken; else current_state <= strongly_not_taken; end if;
                        when weakly_taken =>
                            if input = '1' then current_state <= strongly_taken; else current_state <= weakly_not_taken; end if;
                        when strongly_taken =>
                            if input = '1' then current_state <= strongly_taken; else current_state <= weakly_taken; end if;
                    end case;
                end if;
        end process;
        
    
        --Output calculation
        process (current_state) 
        begin
            output <= '0';
            case current_state is
                when strongly_not_taken =>
                    output <= '0';
                when weakly_not_taken =>
                    output <= '0';
                when weakly_taken =>
                    output <= '1';
                when strongly_taken =>
                    output <= '1';
            end case;
        end process;

end Architecture;