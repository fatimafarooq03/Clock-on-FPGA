-- Clock24Hours.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Clock24Hours is
    Port ( 
        MCLK : in  STD_LOGIC; -- input for standard clock on FPGA board
        reset : in  STD_LOGIC; -- input to reset the time of the clock
        resetfreq : in  STD_LOGIC; -- input to reset the frequency of seconds
        AN : out  STD_LOGIC_VECTOR(3 downto 0); -- output of the anode vector for the 7-segment display
        dec : out  STD_LOGIC_VECTOR(6 downto 0); -- output of the 7-segment display
        secondsLED : out  STD_LOGIC_VECTOR(5 downto 0) -- outputs of the seconds on LEDs
    );
end Clock24Hours;

architecture Behavioral of Clock24Hours is

    signal count : integer := 1; -- counts the number of cycles of the clock to produce a specific frequency
    signal seconds: integer := 0; -- keeps track of the seconds
    signal countAN : integer := 1; -- keeps track of the counter that forms frequency of alternating between the anodes
    signal sel : std_logic_vector(3 downto 0); -- signal to know which 7-segment unit to turn on
    signal minutes: integer := 0; -- keeps track of the minutes
    signal hours: integer := 0; -- keeps track of the hours
    signal digit: integer := 0; -- stores the digit to display for a specific 7-segment
    signal clk : std_logic := '0'; -- clock signal of frequency 1 Hz/500 Hz

begin

    process(MCLK, sel)
    begin
        if(MCLK'event and MCLK = '1') then -- if there is a clock event and the signal is high
            countAN <= countAN + 1; -- increments countAN to count the number of cycles to generate a signal of frequency 
            count <= count + 1; -- this counts the number of cycles of the clock

            if (countAN = 12500) then -- assigns sel as the first anode vector at first quarter cycle
                sel <= "0111";
            end if;

            if (countAN = 25000) then -- assigns sel as the second anode vector at second quarter cycle
                sel <= "1011";
            end if;

            if (countAN = 37500) then -- assigns sel as the third anode vector at third quarter cycle
                sel <= "1101";
            end if;

            if (countAN = 50000) then -- assigns sel as the fourth anode vector at fourth quarter cycle
                sel <= "1110";
                countAN <= 1;
            end if;

            if (count = 50000 and resetfreq = '1') then
                clk <= not clk; -- shifts the clock signal after 50000 cycles to create a signal of 500 Hz when the reset frequency button is pressed
                count <= 1; -- resets the counter so the process continues in a loop
            end if;

            if (count = 25000000) then
                clk <= not clk; -- shifts the clock signal after 25000000 cycles to create a signal of 1 Hz
                count <= 1; -- resets the counter so the process continues in a loop
            end if;

        end if;
    end process;

    process(clk, sel, seconds, minutes, hours)
    begin 
        if (rising_edge(clk)) then
            seconds <= seconds + 1; -- increments the seconds with a rising edge of the clock as there is 1 cycle per second at 1 Hz

            if (seconds >= 59) then 
                minutes <= minutes + 1; -- when seconds reach 60, minutes are incremented and seconds are reset to 0 
                seconds <= 0;

                if (minutes >= 59) then -- when minutes reach 60, hours are incremented and minutes are reset to 0
                    hours <= hours + 1;
                    minutes <= 0; 

                    if (hours >= 23) then -- when hours reach 24, hours are reset to 0
                        hours <= 0;  
                    end if;

                end if; 

            end if; 

        end if;

        if (reset = '1') then -- this assigns all hours, minutes, and seconds to 0 when the reset button is pressed
            seconds <= 0;
            minutes <= 0; 
            hours <= 0; 
        end if;

        secondsLED <= std_logic_vector(to_unsigned(seconds, secondsLED'length)); -- converts the seconds integer to a binary vector to display on LED
    end process;

    -- multiplexing the sel signal to turn on specific 7-segment according to the value of sel because the 7-segment will alternate 
    -- between the four but at a frequency not visible to the human eye
    with (sel) select
        AN <= "0111" when "0111",
              "1011" when "1011",
              "1101" when "1101",
              "1110" when "1110",
              "1111" when others; 

    process(minutes, hours, seconds, sel)
    begin 
        if (sel = "0111") then 
            if (minutes <= 9) then
                digit <= minutes; 
            elsif (minutes > 9 and minutes <= 19) then
                digit <= minutes - 10; 
            elsif (minutes > 19 and minutes <= 29) then
                digit <= minutes - 20; 
            elsif (minutes > 29 and minutes <= 39) then
                digit <= minutes - 30; 
            elsif (minutes > 39 and minutes <= 49) then
                digit <= minutes - 40; 
            elsif (minutes > 49 and minutes <= 59) then
                digit <= minutes - 50; 
            end if;
        end if;

        if (sel = "1011") then 
            if (minutes <= 9) then
                digit <= 0;
            elsif (minutes > 9 and minutes <= 19) then
                digit <= 1;
            elsif (minutes > 19 and minutes <= 29) then
                digit <= 2;
            elsif (minutes > 29 and minutes <= 39) then
                digit <= 3;
            elsif (minutes > 39 and minutes <= 49) then
                digit <= 4;
            elsif (minutes > 49 and minutes <= 59) then
                digit <= 5;
            end if;
        end if;

        if (sel = "1101") then 
            if (hours <= 9) then
                digit <= hours; 
            elsif (hours > 9 and hours <= 19) then
                digit <= hours - 10; 
            elsif (hours > 19 and hours <= 23) then
                digit <= hours - 20; 
            end if;
        end if;

        if (sel = "1110") then 
            if (hours <= 9) then
                digit <= 0; 
            elsif (hours > 9 and hours <= 19) then
                digit <= 1; 
            elsif (hours > 19 and hours <= 23) then
                digit <= 2; 
            end if;
        end if;

        -- output on 7-segment display according to the value of the digit
        case digit is 
            when 0 => dec <= "0000001"; -- shows 0
            when 1 => dec <= "1001111"; -- shows 1
            when 2 => dec <= "0010010"; -- shows 2
            when 3 => dec <= "0000110"; -- shows 3
            when 4 => dec <= "1001100"; -- shows 4
            when 5 => dec <= "0100100"; -- shows 5
            when 6 => dec <= "0100000"; -- shows 6
            when 7 => dec <= "0001111"; -- shows 7
            when 8 => dec <= "0000000"; -- shows 8 
            when 9 => dec <= "0000100"; -- shows 9
            when others => null;
        end case;
    end process;

end Behavioral;
