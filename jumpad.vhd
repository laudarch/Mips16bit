LIBRARY ieee;
Use ieee.STD_Logic_1164.all;
use ieee.numeric_std.all;

ENTITY jumpAD IS
generic (
    	n : integer := 16;
		k : integer := 12
	);
	port (	
		jumpAD : in std_logic_vector (k-1 downto 0);
        instrP2AD : in std_logic_vector (n-1 downto 0);
		EjumpAD : out std_logic_vector (n-1 downto 0)
	);
END jumpAD;

Architecture Logicfunc Of jumpAD IS
   signal extended,multed : std_logic_vector(n-1 DOWNTO 0);
begin
   extended <= (n-1 downto k => jumpAD(k-1)) & (jumpAD);
--extended(10 downto 0) <= jumpAD(10 downto 0);
--extended(15) <= jumpAD(11);
--extended(14) <= jumpAD(11);
--extended(13) <= jumpAD(11);
--extended(12) <= jumpAD(11);
--extended(11) <= jumpAD(11);
process(instrP2AD)
begin
  multed <= extended(n-2 downto 0) & "0";
  EjumpAD <= std_logic_vector( unsigned(multed) + unsigned(instrP2AD));
end process;
END Logicfunc;
