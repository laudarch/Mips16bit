LIBRARY IEEE;
USE IEEE.STD_Logic_1164.all;

ENTITY controller is
port (opCode :IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 func: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 flush: IN STD_LOGIC;
		 isMPFC, isJumpD, isReadDigit, isPrintDigit, isR, isLW, isSW, isBranch, isJR  :OUT STD_LOGIC
		 );
END controller;

architecture rtl Of controller IS 

begin
	get_result: process(opCode) begin
		if flush = '0' then
			case opCode is
				when "0000"  => 
					isR <= '1';
					if func = "111" then
						isMPFC <= '1';
					end if;
				when "0001"  => 
					isLW <= '1';
				when "0010"  => 
					isSW <= '1';
				when "0100"  => 
					isBranch <= '1';
				when "0110"  => 
					isReadDigit <= '1';
				when "0111"  => 
					isPrintDigit <= '1';
				when "1111"  => 
					isJumpD <= '1';
				when "1101"  => 
					isJR <= '1';
				when others => 
					isR <= '0';
			end case;
		end if;
	end process;

END rtl;
