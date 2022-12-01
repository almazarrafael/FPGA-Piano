library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        -- INPUTS
        i_clk : in std_logic;
        
        i_sw0 : in std_logic;
        i_sw1 : in std_logic;
        
        -- EXTERNAL BUTTONS
        C_raw : in std_logic;
        D_raw : in std_logic ;
        E_raw : in std_logic;
        F_raw : in std_logic;
        G_raw : in std_logic;
        A_raw : in std_logic;
        B_raw : in std_logic;
        
        -- EXTERNAL LEDS
        C_led : out std_logic;
        D_led : out std_logic;
        E_led : out std_logic;
        F_led : out std_logic;
        G_led : out std_logic;
        A_led : out std_logic;
        B_led : out std_logic;
        
        -- SPEAKER
        speaker : out std_logic;
        
        -- SEVEN SEGMENT DISPLAY
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic;
        
        -- RGB
        o_ledR : out std_logic;
        o_ledG : out std_logic;
        o_ledB : out std_logic;
        
        -- Buttons        
        i_btn0 : in std_logic;
        i_btn1 : in std_logic
    );
end top;

architecture Behavioral of top is

-- BEGIN COMPONENTS --

component music_controller is
    Port (
        -- INPUTS
        i_clk : in std_logic;
        C_raw : in std_logic;
        D_raw : in std_logic;
        E_raw : in std_logic;
        F_raw : in std_logic;
        G_raw : in std_logic;
        A_raw : in std_logic;
        B_raw : in std_logic;
        
        --OUTPUTS
        
        -- INTERNAL
        C_pulse : out std_logic;
        D_pulse : out std_logic;
        E_pulse : out std_logic;
        F_pulse : out std_logic;
        G_pulse : out std_logic;
        A_pulse : out std_logic;
        B_pulse : out std_logic;
        
        -- EXTERNAL
        speaker : out std_logic
    );
end component;

component LFSR is
    Port (
        i_clk : in std_logic;
        i_load : in std_logic;
        i_next : in std_logic;
        i_seed : in std_logic_vector(2 downto 0);
        o_output : out std_logic_vector(2 downto 0)
    );
end component;

component debounce is
    generic (
        clk_freq    : integer := 50_000_000; --system clock frequency in Hz
        stable_time : integer := 10);        --time button must remain stable in ms
    port (
        clk     : in std_logic;   --input clock
        rst : in std_logic;   --asynchronous active low reset
        button  : in std_logic;   --input signal to be debounced
        result  : out std_logic); --debounced signal
end component;

component score_counter is
    Port (
        i_clk : in std_logic;
        i_sw : in std_logic;
        i_reset : in std_logic;
        i_start : in std_logic;
        i_stop : in std_logic;
        
        o_l_counter : out std_logic_vector(3 downto 0);
        o_r_counter : out std_logic_vector(3 downto 0)
    );
end component;

component SevSegDecoder is
    Port ( i_Val : in STD_LOGIC_VECTOR (3 downto 0);
           o_SegArr : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component ROM_controller is
  Port (
		clk : in std_logic;
		song_sel : in std_logic_vector(1 downto 0);
		addr : in std_logic_vector(6 downto 0);
		song_out : out std_logic_vector(6 downto 0)
	);
end component;

component clockDivider is
    Port (
        i_clk : in std_logic;
        i_max : in std_logic_vector(26 downto 0);
        o_frequency : out std_logic
    );
end component;

-- END COMPONENTS --

-- BEGIN SIGNALS --

signal C_pulse, D_pulse, E_pulse, F_pulse, G_pulse, A_pulse, B_pulse : std_logic;
signal r_counter : unsigned(2 downto 0) := (others => '0');
signal w_rand : std_logic_vector(2 downto 0);
signal r_load : std_logic := '0';

signal r_btn0_prev : std_logic := '0';

type state is (Idle, Game, Music);
signal currState : state := Idle;

signal r_game_counter : unsigned(30 downto 0) := (others => '0');
signal r_game_score : unsigned(6 downto 0) := (others => '0');
signal r_next : std_logic := '0';

signal r_reset : std_logic := '1';
signal r_reset_prev : std_logic := '1';
signal r_counter_led : std_logic_vector(3 downto 0) := (others => '0');
signal i_btn0_db : std_logic;

signal w_led : std_logic;

signal w_rand_decoded : std_logic_vector(6 downto 0);
signal w_piano : std_logic_vector(6 downto 0);

signal w_dir, w_start: std_logic;
signal w_stop, w_reset :std_logic := '1';
signal w_l_counter, w_r_counter : std_logic_vector(3 downto 0);
signal w_seg_l, w_seg_r : std_logic_vector(6 downto 0);

signal clk_cnt: unsigned(19 downto 0);

signal song_clk : std_logic;

signal r_song_cntr : unsigned(6 downto 0) := (others => '0');
signal r_prv_song_clk : std_logic := '0';
signal r_prv_song_sel : std_logic_vector(1 downto 0) := (others => '0');
signal song_sel : std_logic_vector(1 downto 0);
signal prevState : state;
signal song_decoded : std_logic_vector(6 downto 0);
signal r_btn1_prev : std_logic := '0';
signal i_btn1_db : std_logic;

signal C_mc, D_mc, E_mc, F_mc, G_mc, A_mc, B_mc : std_logic;

-- END SIGNALS --

begin

-- BEGIN MUSIC PLAYER LOGIC --

song_sel <= i_sw1 & i_sw0;

ROM : ROM_controller
port map (
    clk => i_clk,
    song_sel => i_sw1 & i_sw0,
    addr => std_logic_vector(r_song_cntr),
    song_out => song_decoded
);

clk_1Hz : clockDivider
port map (
    i_clk => i_clk,
    i_max => "000011101110011010110010100",
    o_frequency => song_clk
);

process (i_clk) is
begin
    if (rising_edge(i_clk)) then
        if (r_prv_song_clk = '0' and song_clk = '1') then
            if (r_prv_song_sel /= song_sel OR prevState /= currState) then
                r_song_cntr <= (others => '0');
            else
                r_song_cntr <= r_song_cntr + 1;
            end if;
            prevState <= currState;
            r_prv_song_sel <= song_sel;
        end if;
        r_prv_song_clk <= song_clk;
    end if;
end process;

-- END MUSIC PLAYER LOGIC --

-- BEGIN COMBINATIONAL LOGIC --

w_piano <= B_pulse & A_pulse & G_pulse & F_pulse & E_pulse & D_pulse & C_pulse;
w_rand_decoded <= "0000001" when w_rand = "000" else
                  "0000010" when w_rand = "001" else
                  "0000100" when w_rand = "010" else
                  "0001000" when w_rand = "011" else
                  "0010000" when w_rand = "100" else
                  "0100000" when w_rand = "101" else
                  "1000000" when w_rand = "110" else
                  "0000000";
                  
        
C_led <= C_raw when currState = Idle else
         w_rand_decoded(0) when currState = Game else
         song_decoded(6) when currState = Music else '0';
D_led <= D_raw when currState = Idle else
         w_rand_decoded(1) when currState = Game else
         song_decoded(5) when currState = Music else '0';
E_led <= E_raw when currState = Idle else
         w_rand_decoded(2) when currState = Game else
         song_decoded(4) when currState = Music else '0';
F_led <= F_raw when currState = Idle else
         w_rand_decoded(3) when currState = Game else
         song_decoded(3) when currState = Music else '0';
G_led <= G_raw when currState = Idle else
         w_rand_decoded(4) when currState = Game else
         song_decoded(2) when currState = Music else '0';
A_led <= A_raw when currState = Idle else
         w_rand_decoded(5) when currState = Game else
         song_decoded(1)  when currState = Music else '0';
B_led <= B_raw when currState = Idle else
         w_rand_decoded(6) when currState = Game else
         song_decoded(0) when currState = Music else '0';

o_ledR <= '1' when currState = Idle else '0';
o_ledG <= '1' when currState = Game else '0';
o_ledB <= '1' when currState = Music else '0';

-- END COMBINATIONAL LOGIC --

btn0DB : debounce
generic map (
    clk_freq => 125_000_000,
    stable_time => 10
)
port map (
    clk => i_clk,
    rst => '0',
    button => i_btn0,
    result => i_btn0_db
);

btn1DB : debounce
generic map (
    clk_freq => 125_000_000,
    stable_time => 10
)
port map (
    clk => i_clk,
    rst => '0',
    button => i_btn1,
    result => i_btn1_db
);

FSM_stateMachine : process (i_clk) is
begin
    if (rising_edge(i_clk)) then
        case currState is
            when Idle =>
                if (r_btn0_prev = '1' and i_btn0_db = '0') then
                    currState <= Game;
                elsif (r_btn1_prev = '1' and i_btn1_db = '0') then
                    currState <= Music;
                else
                    currState <= currState;
                end if;
            when Game =>                
                if (std_logic_vector(r_game_counter) = "1001010100000010111110010000000") then
                    r_game_counter <= (others => '0');
                    currState <= Idle;
                else
                    r_game_counter <= r_game_counter + 1;
                    currState <= currState;
                end if;
            when Music =>
                if (r_btn0_prev = '1' and i_btn0_db = '0') then
                    currState <= Idle;
                else
                    currState <= currState;
                end if;
        end case;
        r_btn0_prev <= i_btn0_db;
        r_btn1_prev <= i_btn1_db;
    end if;
end process;

FSM_outputLogic : process (i_clk) is
begin
    if (rising_edge(i_clk)) then
        case currState is
            when Idle =>
                r_reset <= '1';
                r_load <= '0';
            when Game =>
                r_reset <= '0';
                r_load <= '1';
            when Music =>
                r_reset <= r_reset;
                r_load <= r_load;
        end case;
    end if;
end process;

FSM_game : process (i_clk) is
begin
    if (rising_edge(i_clk)) then
        if (r_reset_prev = '1' and r_reset = '0') then
            r_game_score <= (others => '0');
            w_reset <= '1';
        else
            w_reset <= '0';
        end if;
        r_reset_prev <= r_reset;
    
        if (currState = Game) then                
                if (nor(w_piano)) then
                    r_next <= '0';
                    w_start <= '0';
                    w_stop <= '1';
                elsif (w_piano = w_rand_decoded) then
                    r_next <= '1';
                    r_game_score <= r_game_score + 1;
                    w_dir <= '1';
                    w_stop <= '0';
                    w_start <= '1';
                else
                    if (nor(std_logic_vector(r_game_score))) then
                        r_next <= '1';
                        r_game_score <= r_game_score;
                        w_start <= '0';
                        w_stop <= '1';
                    else
                        r_next <= '1';
                        r_game_score <= r_game_score - 1;
                        w_dir <= '0';
                        w_stop <= '0';
                        w_start <= '1';
                    end if;
                    
                end if;

        end if;
    end if;
end process;

-- Score counter
scoreCounter : score_counter
Port map (
    i_clk => i_clk,
    i_sw => w_dir, -- 1 = up, 0 = down
    i_reset => w_reset,
    i_start => w_start,
    i_stop => w_stop,
    o_l_counter => w_l_counter,
    o_r_counter => w_r_counter
);

-- Seven Segment Display

SSDL : sevSegDecoder
port map (
    i_val => w_l_counter,
    o_segArr => w_seg_l
);

SSDR : sevSegDecoder
port map (
    i_val => w_r_counter,
    o_segArr => w_seg_r
);

process(i_clk)
    begin
        if rising_edge(i_clk) then
            clk_cnt <= clk_cnt + 1;
        end if;
    end process;
         
 process(clk_cnt'high)
    begin
        if clk_cnt(clk_cnt'high) = '0' then
            seg <= w_seg_r;
        else
            seg <= w_seg_l;
       end if;   
    end process;
an <= clk_cnt(clk_cnt'high);

-- Clock counter
clock_counter : process (i_clk) is
begin
    if (rising_edge(i_clk)) then
        r_counter <= r_counter + 1;
    end if;
end process;

randGen : LFSR
port map (
    i_clk => i_clk,
    i_load => not w_reset,
    i_next => r_next,
    i_seed => std_logic_vector(r_counter),
    o_output => w_rand
);

music_ctrl : music_controller
port map (
    i_clk => i_clk,
    C_raw => C_mc,
    D_raw => D_mc,
    E_raw => E_mc,
    F_raw => F_mc,
    G_raw => G_mc,
    A_raw => A_mc,
    B_raw => B_mc,
    C_pulse => C_pulse,
    D_pulse => D_pulse,
    E_pulse => E_pulse,
    F_pulse => F_pulse,
    G_pulse => G_pulse,
    A_pulse => A_pulse,
    B_pulse => B_pulse,
    speaker => speaker
);

C_mc <= C_raw when currState = Idle or currState = Game else song_decoded(6) when currState = Music else '0';
D_mc <= D_raw when currState = Idle or currState = Game else song_decoded(5) when currState = Music else '0';
E_mc <= E_raw when currState = Idle or currState = Game else song_decoded(4) when currState = Music else '0';
F_mc <= F_raw when currState = Idle or currState = Game else song_decoded(3) when currState = Music else '0';
G_mc <= G_raw when currState = Idle or currState = Game else song_decoded(2) when currState = Music else '0';
A_mc <= A_raw when currState = Idle or currState = Game else song_decoded(1) when currState = Music else '0';
B_mc <= B_raw when currState = Idle or currState = Game else song_decoded(0) when currState = Music else '0';

end Behavioral;
