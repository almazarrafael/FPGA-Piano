library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

entity ROM_controller is
  Port (
		clk : in std_logic;
		song_sel : in std_logic_vector(1 downto 0);
		addr : in std_logic_vector(6 downto 0);
		song_out : out std_logic_vector(6 downto 0)
	);
end ROM_controller;

architecture Behavioral of ROM_controller is

constant ADDR_WIDTH: integer := 7;
constant DATA_WIDTH: integer := 7;

constant DEPTH: integer := 2**ADDR_WIDTH;

type rom_type is array (0 to DEPTH-1)
       of std_logic_vector(DATA_WIDTH-1 downto 0);
       
    impure function init_rom(d_type: std_logic_vector(1 downto 0)) return rom_type is
        file text_file_song1: text open read_mode is "../data/song1.txt";
        file text_file_song2: text open read_mode is "../data/song2.txt";
				file text_file_song3: text open read_mode is "../data/song3.txt";
				file text_file_song4: text open read_mode is "../data/song4.txt";
        variable text_line : line;
        variable value : std_logic_vector(DATA_WIDTH-1 downto 0);
        variable rom_content: rom_type;
    begin
    
        for i in 0 to DEPTH-1 loop
            if d_type = "00" then
                readline(text_file_song1, text_line);
            elsif d_type = "01" then
                readline(text_file_song2, text_line);
						elsif d_type = "10" then
								readline(text_file_song3, text_line);
						else -- "11"
								readline(text_file_song4, text_line);
            end if;
            read(text_line, value);
            rom_content(i) := value;
        end loop;
        
        return rom_content;
    
    end function;
    
    signal song1: rom_type := init_rom("00");
    signal song2: rom_type := init_rom("01");
    signal song3: rom_type := init_rom("10");
    signal song4: rom_type := init_rom("11");

	begin
		process (clk) is
		begin
			if (rising_edge(clk)) then
				if (song_sel = "00") then
            song_out <= song1(to_integer(unsigned(addr)));
				elsif (song_sel = "01") then
            song_out <= song2(to_integer(unsigned(addr)));
				elsif (song_sel = "10") then
            song_out <= song3(to_integer(unsigned(addr)));
        else -- 11
            song_out <= song4(to_integer(unsigned(addr)));
        end if;
			end if;
		end process;

	end Behavioral;