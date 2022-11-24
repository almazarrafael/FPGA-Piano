library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevSegDecoder is
    Port ( i_Val : in STD_LOGIC_VECTOR (3 downto 0);
           o_SegArr : out STD_LOGIC_VECTOR (6 downto 0));
end SevSegDecoder;

architecture Behavioral of SevSegDecoder is

begin

with i_Val select
    o_SegArr <= "1111110" when "0000", -- 0
                "0110000" when "0001", -- 1
                "1101101" when "0010", -- 2
                "1111001" when "0011", -- 3
                "0110011" when "0100", -- 4
                "1011011" when "0101", -- 5
                "1011111" when "0110", -- 6
                "1110000" when "0111", -- 7
                "1111111" when "1000", -- 8
                "1111011" when "1001", -- 9
                "1110111" when "1010", -- a
                "0011111" when "1011", -- b
                "1001110" when "1100", -- c
                "0111101" when "1101", -- d
                "1001111" when "1110", -- e
                "1000111" when "1111", -- f
                "0000101" when others; -- r
end Behavioral;