library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity music_controller is
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
end music_controller;

architecture Behavioral of music_controller is

-- BEGIN COMPONENTS --

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

component clockDivider is
    Port (
        i_clk : in std_logic;
        i_max : in std_logic_vector(26 downto 0);
        o_frequency : out std_logic
    );
end component;

-- END COMPONENTS --

-- BEGIN SIGNALS --

signal C, D, E, F, G, A, B : std_logic;
signal C_freq, D_freq, E_freq, F_freq, G_freq, A_freq, B_freq : std_logic;
signal C_prev, D_prev, E_prev, F_prev, G_prev, A_prev, B_prev : std_logic := '0';

-- END SIGNALS --

begin

-- BEGIN PULSE LOGIC --

process (i_clk) is
begin
    if (rising_edge(i_clk)) then
        if (C_prev = '1' and C = '0') then -- Falling edge
            C_pulse <= '1';
        else
            C_pulse <= '0';
        end if;
        
        if (D_prev = '1' and D = '0') then -- Falling edge
            D_pulse <= '1';
        else
            D_pulse <= '0';
        end if;
        
        if (E_prev = '1' and E = '0') then -- Falling edge
            E_pulse <= '1';
        else
            E_pulse <= '0';
        end if;
        
        if (F_prev = '1' and F = '0') then -- Falling edge
            F_pulse <= '1';
        else
            F_pulse <= '0';
        end if;
        
        if (G_prev = '1' and G = '0') then -- Falling edge
            G_pulse <= '1';
        else
            G_pulse <= '0';
        end if;
        
        if (A_prev = '1' and A = '0') then -- Falling edge
            A_pulse <= '1';
        else
            A_pulse <= '0';
        end if;
        
        if (B_prev = '1' and B = '0') then -- Falling edge
            B_pulse <= '1';
        else
            B_pulse <= '0';
        end if;
        
        C_prev <= C;
        D_prev <= D;
        E_prev <= E;
        F_prev <= F;
        G_prev <= G;
        A_prev <= A;
        B_prev <= B;
    end if;
end process;

-- END PULSE LOGIC --

-- BEGIN OUTPUT LOGIC --

speaker <= C_freq when C = '1' else
           D_freq when D = '1' else
           E_freq when E = '1' else
           F_freq when F = '1' else
           G_freq when G = '1' else
           A_freq when A = '1' else
           B_freq when B = '1' else
           '0';

-- END OUTPUT LOGIC --

-- BEGIN CLOCK DIVIDERS --

cd_C : clockDivider
port map (
    i_clk => i_clk,
    i_max => "000000000011101001010010110",
    o_frequency => C_freq
);

cd_D : clockDivider
port map (
    i_clk => i_clk,
    i_max => "000000000011001111110101010",
    o_frequency => D_freq
);

cd_E : clockDivider
port map (
    i_clk => i_clk,
    i_max => "000000000010111001001010101",
    o_frequency => E_freq
);

cd_F : clockDivider
port map (
    i_clk => i_clk,
    i_max => "000000000010101110110001100",
    o_frequency => F_freq
);

cd_G : clockDivider
port map (
    i_clk => i_clk,
    i_max => "000000000010011011101100111",
    o_frequency => G_freq
);

cd_A : clockDivider
port map (
    i_clk => i_clk,
    i_max => "000000000010001010101101111",
    o_frequency => A_freq
);

cd_B : clockDivider
port map (
    i_clk => i_clk,
    i_max => "000000000001111011010101011",
    o_frequency => B_freq
);

-- END CLOCK DIVIDERS --

-- BEGIN DEBOUNCERS --

db_C : debounce
generic map (
    clk_freq => 125_000_000,
    stable_time => 10
)
port map (
    clk => i_clk,
    rst => '0',
    button => C_raw,
    result => C
);

db_D : debounce
generic map (
    clk_freq => 125_000_000,
    stable_time => 10
)
port map (
    clk => i_clk,
    rst => '0',
    button => D_raw,
    result => D
);

db_E : debounce
generic map (
    clk_freq => 125_000_000,
    stable_time => 10
)
port map (
    clk => i_clk,
    rst => '0',
    button => E_raw,
    result => E
);

db_F : debounce
generic map (
    clk_freq => 125_000_000,
    stable_time => 10
)
port map (
    clk => i_clk,
    rst => '0',
    button => F_raw,
    result => F
);

db_G : debounce
generic map (
    clk_freq => 125_000_000,
    stable_time => 10
)
port map (
    clk => i_clk,
    rst => '0',
    button => G_raw,
    result => G
);

db_A : debounce
generic map (
    clk_freq => 125_000_000,
    stable_time => 10
)
port map (
    clk => i_clk,
    rst => '0',
    button => A_raw,
    result => A
);

db_B : debounce
generic map (
    clk_freq => 125_000_000,
    stable_time => 10
)
port map (
    clk => i_clk,
    rst => '0',
    button => B_raw,
    result => B
);

-- END DEBOUNCERS --

end Behavioral;
