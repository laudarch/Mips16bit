LIBRARY ieee;
Use ieee.STD_Logic_1164.all;
ENTITY mux3 IS

Port ( in1, in2, in3, sig1, sig2 :IN STD_LOGIC ;
		output : OUT STD_LOGIC ); 
END mux3;

Architecture Logicfunc Of mux3 IS 

component mux
	Port (  in1, in2, sig :IN STD_LOGIC ;
			output : OUT STD_LOGIC ); 
end component;

signal f: STD_LOGIC;

Begin

	G1: MUX port map (in1, in2, sig1, f);
	G2: MUX port map (f, in3, sig2, output);
  
END Logicfunc;
