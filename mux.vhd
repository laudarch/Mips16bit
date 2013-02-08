LIBRARY ieee;
Use ieee.STD_Logic_1164.all;

ENTITY mux IS
Port ( in1, in2, sig :IN STD_LOGIC ;
		output : OUT STD_LOGIC ); 
END mux;

Architecture Logicfunc Of mux IS 
Begin
	output<= (in1 AND NOT sig) OR (in2 AND sig);
	
END Logicfunc;
