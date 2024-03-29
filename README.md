# FPGA Piano

- ECE 524 - Advanced FPGA Design Final Project
- Professor: Saba Janamian
- Semester: Fall 2022

![hardware](./media/hardware.png)

This final project is based around a piezoelectric buzzer that can produce different sounds based on the frequencies being passed onto the buzzer. The overall idea is to construct a keyboard with different buttons that can be used to play different notes on the piano. Seven buttons were used because there are seven basic piano notes (C, E, D, F, G, A, B). As the project progressed, additional functions were included in order to incorporate more design functionality that were learned throughout the course. The first additional mode is a game mode. This game mode is inspired by piano tiles. The goal of the game is to press the corresponding buttons as the LED lights up. For each correct input, a score counter is incremented and respectively decremented for wrong inputs. After 10 seconds, the game ends and the project goes back to an idle state where you can freely play the piano. The final additional mode is a music player. The music player drives the buzzer according to different ROMs that is determined based on the switch values. A Python script was made in order to generate and encode songs into ROM files that is used in the HDL designs.

### State Machine

![state machine](./media/state_diagram.png)

A state machine is used in order to provide multiple functionalities. The three states are Idle, Game and Music Player. In the Idle state, the piano can be freely used. In order to produce the necessary frequencies for the buzzer, a reference piano frequency guide was used. With these values, an array of seven clock dividers were designed in order to produce the correct frequencies. This was then multiplexed based on the buttons being pressed. For the idle state and the game state, the buttons directly drive the frequency drivers.

For the game state, an LFSR is used in order to generate the random number needed to choose which LED to turn on. Since an LFSR is a deterministic system, the same sequence is produced with the same seed. In order to circumvent this, a clock counter is used that is loaded as a seed into the LFSR when the game starts. The LFSR used has 8 stages but the seed is only loaded into the bottom three LSB. This means that it produces 8 different sequences. This can be updated by making the clock counter 8 bits long and fully loaded into the LFSR to produce more sequences. A counter is also used in order to keep track of time. It starts off as 0 and counts up to a maximum that is calculated based on the system clock of 125 MHz and the maximum time of 10 seconds. Once this maximum is reached, the game ends and goes back to idle state. Another counter is also used in order to keep score which is incremented/decremented depending on if the user presses the correct input or not.

### ROM

For the final music player state, a ROM controller was used. It loads the different text files that were generated using the Python script. A counter is used that is incremented every half a second. This counter is used to choose a memory location address in the ROM. Each memory location corresponds to a seven digit binary number that is decoded and drives the buzzer and the LEDs. The counter is reset every time the switch changes in order to start the song from the beginning.

![script demo](./media/script.png)

### Implemented Design Schema

![implemented design](./media/implemented_design.png)
