library ieee; 
use ieee.std_logic_1164.all;

entity forwarder is
	generic( addr_size : INTEGER := 3 );
	port (	R1AD, R2AD, RegAD_EXMEM, RegAD_MEMWB : IN STD_LOGIC_VECTOR(addr_size-1 downto 0);
      		S1, S2 : OUT STD_LOGIC_VECTOR(1 downto 0));
end entity forwarder;


architecture behave of forwarder is
begin
	process (RegAD_EXMEM, RegAD_MEMWB, R1AD, R2AD) 
	begin
		-- just set it to 00 for the default case (so the default input in the Selectors is used)
		S1 <= "00";  -- select R1AD
		S2 <= "00";  -- select R2AD
		
		if (R1AD = RegAD_EXMEM) then
			S1 <= "10";  -- select RegAD_EXMEM
		elsif (R1AD = RegAD_MEMWB) then
			S1<="01";  -- select RegAD_MEMWB
		end if;
		if (R2AD = RegAD_EXMEM) then
			S2 <= "10";  -- select RegAD_EXMEM
		elsif (R2AD = RegAD_MEMWB) then
			S2<="01";  -- select RegAD_MEMWB
		end if;
		
	end process;
end architecture behave;

