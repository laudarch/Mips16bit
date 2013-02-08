LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY JRSelector IS
generic (
		n : integer := 16
	);
PORT (
   jumpAD, branchAd,PCP2AD :		IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   JRopcode: 						IN STD_LOGIC_VECTOR(1 DOWNTO 0);
   result: 							OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END JRSelector;

ARCHITECTURE Behavior OF JRSelector IS
BEGIN
 --OPCODE:
 -- 00: +2
 -- 01: JumpADd
 -- 10: BranchAd
 PROCESS (JRopcode)
 BEGIN
	case JRopcode is
		when "00"  => 
			result <= PCP2AD;
		when "01"  => 
			result <= jumpAD;
		when "10"  => 
			result <= branchAd;
		when others => result <= PCP2AD;
	end case;		
 END PROCESS;
 
END Behavior;
