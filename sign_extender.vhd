LIBRARY ieee;
Use ieee.STD_Logic_1164.all;
ENTITY sign_extender IS
	generic (
		n : integer := 16;
		k : integer := 6
	);
	port (	
		immediate : in std_logic_vector (k-1 downto 0);
		extended : out std_logic_vector (n-1 downto 0)
	);
END sign_extender;

Architecture Logicfunc Of sign_extender IS 		
begin
		-- the last $k bits are the same
	    -- extended(k-1 downto 0) <= immediate;
	    -- check the first bit and set the rest bits as that one
	    -- extended(n-1 downto k) <= (n-1 downto k => immediate(k-1));	 
	    extended <= (n-1 downto k => immediate(k-1)) & (immediate);
END Logicfunc;
