LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg16b IS
  PORT (Input : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
		Enable, Clock : IN STD_LOGIC; 
		Output : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0)); 
END reg16b; 

ARCHITECTURE Behavior OF reg16b IS 
BEGIN 
  PROCESS (Clock) 
  BEGIN 
    IF Clock'EVENT AND Clock = '0' THEN 
      IF Enable = '1' THEN 
        Output <=Input; 
      END IF; 
    END IF; 
  END PROCESS; 
END Behavior;