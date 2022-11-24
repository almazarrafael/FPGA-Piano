library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity score_counter is
    Port (
        i_clk : in std_logic;
        i_sw : in std_logic;
        i_reset : in std_logic;
        i_start : in std_logic;
        i_stop : in std_logic;
        
        o_l_counter : out std_logic_vector(3 downto 0);
        o_r_counter : out std_logic_vector(3 downto 0)
    );
end score_counter;

architecture Behavioral of score_counter is

    signal r_l_counter, r_r_counter : std_logic_vector(3 downto 0) := (others => '0');
    signal r_start : std_logic := '1';
    signal r_reset : std_logic := '0';

begin

    process (i_clk) is
    begin
    
        -- START/STOP
        if (rising_edge(i_clk)) then
            if (i_stop = '1' or i_reset = '1') then
                r_start <= '0';
            elsif (i_start = '1') then
                r_start <= '1';
            else
                r_start <= r_start;
            end if;
            
            r_reset <= i_reset;
            
        end if;
    
        -- UP/DOWN COUNTER
        if (rising_edge(i_clk)) then
            if (i_reset = '1') then
                -- RESET
                r_l_counter <= (others => '0');
                r_r_counter <= (others => '0');
            elsif (r_start = '1') then
                if (i_sw = '1') then
                    -- UP COUNTER
                    if (r_r_counter = std_logic_vector(to_unsigned(9, r_r_counter'length))) then
                        -- Reset right digit
                        r_r_counter <= (others => '0');
                        if (r_l_counter = std_logic_vector(to_unsigned(9, r_r_counter'length))) then
                            -- Reset left digit
                            r_l_counter <= (others => '0');
                        else
                            r_l_counter <= std_logic_vector(unsigned(r_l_counter) + 1);
                        end if;
                    else
                        r_r_counter <= std_logic_vector(unsigned(r_r_counter) + 1);
                    end if;
                else
                    -- DOWN COUNTER
                    
                    if (nor(r_r_counter)) then
                        -- Reset right digit
                        r_r_counter <= std_logic_vector(to_unsigned(9, r_r_counter'length));
                        if (nor(r_l_counter)) then
                            -- Reset left digit
                            r_l_counter <= std_logic_vector(to_unsigned(9, r_l_counter'length));
                        else
                            r_l_counter <= std_logic_vector(unsigned(r_l_counter) - 1);
                        end if;
                    else
                        r_r_counter <= std_logic_vector(unsigned(r_r_counter) - 1);
                    end if;
                end if;
            end if;
            
        end if;
            
    end process;

    o_l_counter <= r_l_counter;
    o_r_counter <= r_r_counter;
  
end Behavioral;
