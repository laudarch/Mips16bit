library ieee; 
use ieee.std_logic_1164.all;

entity Selector is
port (Reg, Memory, WriteBack : IN STD_LOGIC_VECTOR(15 downto 0);
      operation : IN STD_LOGIC_VECTOR(1 downto 0);
      output : OUT STD_LOGIC_VECTOR(15 downto 0));
end entity Selector;

architecture rtl Of Selector IS 
begin

process(operation) begin
		case operation is
			 when "00"  => output <= Reg;
			 when "01"  => output <= WriteBack;
			 when "10"  => output <= Memory;
			 when "11"  => output <= "0000000000000000";
		end case;
 end process;
end;
