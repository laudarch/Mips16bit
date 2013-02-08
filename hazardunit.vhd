LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hazardUnit IS
 PORT (
		   isJR, isJump, wasJump, mustBranch : IN STD_LOGIC;
		   flush, wasJumpOut : OUT STD_LOGIC;
		   JRopcode: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
 );
END hazardUnit;

ARCHITECTURE Behavior OF hazardUnit IS
BEGIN
 --OPCODE:
 -- 00: +2
 -- 01: JumpADd
 -- 10: BranchAd
 PROCESS (isJR, isJump, wasJump)
 BEGIN
	IF isJR = '1' OR isJump = '1' OR wasJump = '1' OR mustBranch = '1'  THEN
		flush <= '1';
	END IF;
	IF isJump = '1' THEN
		JRopcode <= "01";
	ELSIF mustBranch = '1' THEN
		JRopcode <= "10";
	ELSE
		JRopcode <= "00";
	END IF;	
 END PROCESS;
 
	wasJumpOut <= isJump;
 
END Behavior;
