LIBRARY ieee;
Use ieee.STD_Logic_1164.all;
Use ieee.std_logic_signed.all;
ENTITY AluSlice IS
		Port (  Input1, Input2, Carryin, AInvert, BInvert, Op1, Op2 :IN STD_LOGIC;
				Output, Carryout :OUT STD_LOGIC
				);
END AluSlice;

Architecture Logicfunc Of AluSlice IS 
	component  fa is
			Port ( in1, in2, carryin :IN STD_LOGIC ;
					sum, carryout : OUT STD_LOGIC );
    end component;
	---------------
	component  mux is
			Port ( in1, in2, sig :IN STD_LOGIC ;
					output : OUT STD_LOGIC ); 
    end component;
	---------------
	component  mux3 is
			Port ( in1, in2, in3, sig1, sig2 :IN STD_LOGIC ;
					output : OUT STD_LOGIC );  
    end component;

	signal f1, f2, f3, f4, f5: STD_LOGIC;
begin

	G0: mux port map (Input1, NOT Input1, AInvert, f1);
	G1: mux port map (Input2, NOT Input2, BInvert, f2);
	f3 <= f1 AND f2;
	f4 <= f1 OR f2;
	G2: fa port map ( f1, f2, Carryin, f5, Carryout);
	G3: mux3 port map (f3, f4, f5, Op1, Op2, Output);

END Logicfunc;
