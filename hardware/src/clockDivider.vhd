library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clockDivider is
    Port (
        i_clk : in std_logic;
        i_max : in std_logic_vector(26 downto 0);
        o_frequency : out std_logic
    );
end clockDivider;

architecture Behavioral of clockDivider is

    signal r_counter : std_logic_vector(26 downto 0) := (others => '0');
    signal r_toggle : std_logic := '0';
    signal r_max : std_logic_vector(26 downto 0);

begin

    process (i_clk, i_max) is
    begin
        
        if (rising_edge(i_clk)) then
            -- if counter reaches max, reset counter and toggle
            if (r_counter >= i_max) then
                r_toggle <= not r_toggle;
                r_counter <= (others => '0');
            -- otherwise, count up
            else
                r_counter <= std_logic_vector(unsigned(r_counter) + 1);
            end if;
            
            -- If speed is changed, reset the counter
            if (r_max /= i_max) then
                r_counter <= (others => '0');
            end if;
            
            r_max <= i_max;
            
        end if;
    end process;

    o_frequency <= r_toggle;

end Behavioral;
