-- NOTES:
-- This is a 8 stage LFSR but only outputs the 3 LSBs

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR is
    Port (
        i_clk : in std_logic;
        i_load : in std_logic;
        i_next : in std_logic;
        i_seed : in std_logic_vector(2 downto 0);
        o_output : out std_logic_vector(2 downto 0)
    );
end LFSR;

architecture Behavioral of LFSR is

    signal r_stage1, r_stage2, r_stage3, r_stage4, r_stage5, r_stage6, r_stage7, r_stage8 : std_logic := '0';
    signal r_next_prev : std_logic := '0';
    signal r_load_prev : std_logic := '0';
    
begin

    process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            if (r_load_prev = '0' and i_load = '1') then -- Rising edge
                r_stage1 <= i_seed(0);
                r_stage2 <= i_seed(1);
                r_stage3 <= i_seed(2);
            else
                if ((r_next_prev = '1' and i_next = '0') or (r_stage3 = '1' and r_stage2 = '1' and r_stage1 = '1')) then -- if 8 then regen
                    r_stage1 <= r_stage3 xor r_stage4 xor r_stage5 xor r_stage7;
                    r_stage2 <= r_stage1;
                    r_stage3 <= r_stage2;
                    r_stage4 <= r_stage3;
                    r_stage5 <= r_stage4;
                    r_stage6 <= r_stage5;
                    r_stage7 <= r_stage6;
                    r_stage8 <= r_stage7;
                else
                    r_stage1 <= r_stage1;
                    r_stage2 <= r_stage2;
                    r_stage3 <= r_stage3;
                    r_stage4 <= r_stage4;
                    r_stage5 <= r_stage5;
                    r_stage6 <= r_stage6;
                    r_stage7 <= r_stage7;
                    r_stage8 <= r_stage8;
                end if;
            end if;
            r_next_prev <= i_next;
            r_load_prev <= i_load;
        end if;
    end process;

    o_output <= r_stage3 & r_stage2 & r_stage1;

end Behavioral;
