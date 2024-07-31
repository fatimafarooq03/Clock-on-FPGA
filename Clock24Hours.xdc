# Constraint File for Clock24Hours

NET "MCLK" LOC = "B8";       # Clock input
NET "reset" LOC = "G12";     # Reset button input
NET "resetfreq" LOC = "C11"; # Reset frequency button input

# Anode control for the 7-segment display
NET "AN(0)" LOC = "K14";
NET "AN(1)" LOC = "M13";
NET "AN(2)" LOC = "J12";
NET "AN(3)" LOC = "F12";

# LEDs to display the seconds
NET "secondsLED(0)" LOC = "M5";
NET "secondsLED(1)" LOC = "M11";
NET "secondsLED(2)" LOC = "P7";
NET "secondsLED(3)" LOC = "P6";
NET "secondsLED(4)" LOC = "N5";
NET "secondsLED(5)" LOC = "N4";

# Output to the 7-segment display
NET "dec(6)" LOC = "L14";
NET "dec(5)" LOC = "H12";
NET "dec(4)" LOC = "N14";
NET "dec(3)" LOC = "N11";
NET "dec(2)" LOC = "P12";
NET "dec(1)" LOC = "L13";
NET "dec(0)" LOC = "M12";
