LIBRARY ieee;
Use ieee.STD_Logic_1164.all;
Use ieee.std_logic_signed.all;

ENTITY fa IS
Port ( in1, in2, carryin :IN STD_LOGIC;
		sum, carryout : OUT STD_LOGIC ); 
END fa;

Architecture Logicfunc Of fa IS 


Begin

sum<= in1 XOR in2 XOR carryin;
carryout<= (in1 AND in2) OR(in1 AND carryin)OR(in2 AND carryin);

END Logicfunc;
