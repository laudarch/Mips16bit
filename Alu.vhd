LIBRARY ieee;
Use ieee.STD_Logic_1164.all;
Use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

ENTITY Alu IS
		GENERIC ( 
			n : INTEGER := 16
		);
		Port (  Input1, Input2 :IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				Carryin :IN STD_LOGIC;
				CarryOut :OUT STD_LOGIC;
				Operation :IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				Output :OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
				);
END Alu;

Architecture Logicfunc Of Alu IS 
	component  AluSlice is
			Port (  Input1, Input2, Carryin, AInvert, BInvert, Op1, Op2 :IN STD_LOGIC;
					Output, Carryout :OUT STD_LOGIC
				); 
    end component;
    
    signal CarryOuts, tempOutput : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    signal COUT : STD_LOGIC;
    
   -- Command constants --
    constant ADD_FUNC : std_logic_vector(3 downto 0) := "0010";
	constant SUB_FUNC : std_logic_vector(3 downto 0) := "0011";
	constant AND_FUNC : std_logic_vector(3 downto 0) := "0000";
	constant OR_FUNC  : std_logic_vector(3 downto 0) := "0001";
	constant GEQ_FUNC : std_logic_vector(3 downto 0) := "0101";
	constant NOT_FUNC : std_logic_vector(3 downto 0) := "0110";
	constant MFPC_FUNC : std_logic_vector(3 downto 0) := "0111";
	constant MULT_FUNC : std_logic_vector(3 downto 0) := "0100";
	constant SLL_FUNC : std_logic_vector(3 downto 0) := "1000";
	constant SRL_FUNC : std_logic_vector(3 downto 0) := "1001";
begin
		--Wire the inputs/outputs to the structural alu slices
		G0: AluSlice port map (Input1(0), Input2(0), Carryin, Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(0), CarryOuts(0));
		G1: AluSlice port map (Input1(1), Input2(1), CarryOuts(0), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(1), CarryOuts(1));
		G2: AluSlice port map (Input1(2), Input2(2), CarryOuts(1), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(2), CarryOuts(2));
		G3: AluSlice port map (Input1(3), Input2(3), CarryOuts(2), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(3), CarryOuts(3));
		G4: AluSlice port map (Input1(4), Input2(4), CarryOuts(3), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(4), CarryOuts(4));
		G5: AluSlice port map (Input1(5), Input2(5), CarryOuts(4), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(5), CarryOuts(5));
		G6: AluSlice port map (Input1(6), Input2(6), CarryOuts(5), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(6), CarryOuts(6));
		G7: AluSlice port map (Input1(7), Input2(7), CarryOuts(6), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(7), CarryOuts(7));
		G8: AluSlice port map (Input1(8), Input2(8), CarryOuts(7), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(8), CarryOuts(8));
		G9: AluSlice port map (Input1(9), Input2(9), CarryOuts(8), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(9), CarryOuts(9));
		G10: AluSlice port map (Input1(10), Input2(10), CarryOuts(9), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(10), CarryOuts(10));
		G11: AluSlice port map (Input1(11), Input2(11), CarryOuts(10), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(11), CarryOuts(11));
		G12: AluSlice port map (Input1(12), Input2(12), CarryOuts(11), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(12), CarryOuts(12));
		G13: AluSlice port map (Input1(13), Input2(13), CarryOuts(12), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(13), CarryOuts(13));
		G14: AluSlice port map (Input1(14), Input2(14), CarryOuts(13), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(14), CarryOuts(14));
		G15: AluSlice port map (Input1(15), Input2(15), CarryOuts(14), Operation(3), Operation(2), Operation(0), Operation(1), tempOutput(15), COUT);
	process(Operation)
		variable temp: std_logic_vector(n-1 downto 0);
		variable temp2: std_logic_vector(2*n-1 downto 0);
		variable temp3, temp4: std_logic;
	begin
		case Operation is
			when ADD_FUNC =>
				temp := tempOutput;
			when SUB_FUNC =>
				temp := Input1 - Input2;
			when AND_FUNC =>
				temp := tempOutput;
			when OR_FUNC =>
				temp := tempOutput;
			when MULT_FUNC =>
				temp2 := Input1 * Input2;
				temp := temp2(n-1 downto 0);
			when MFPC_FUNC =>
				temp := Input1;
			when GEQ_FUNC =>
				temp := (OTHERS => NOT(Input1(n-1)));
				temp4 := '0';
				temp3 := NOT(Input1(n-1));
			when NOT_FUNC =>
				temp := (OTHERS => '0');
				if (Input1 = (n-1 downto 0 => '0')) then
					temp(0) := '1';
				end if;
			when SLL_FUNC =>
				if Input2 = std_logic_vector( to_unsigned(0, Input2'length) ) then
					temp := Input1;
				elsif Input2 = std_logic_vector( to_unsigned(1, Input2'length) ) then
					temp := Input1(n-2 downto 0) & "0";
				elsif Input2 = std_logic_vector( to_unsigned(2, Input2'length) ) then
					temp := Input1(n-3 downto 0) & "00";
				elsif Input2 = std_logic_vector( to_unsigned(3, Input2'length) ) then
					temp := Input1(n-4 downto 0) & "000";
				elsif Input2 = std_logic_vector( to_unsigned(4, Input2'length) ) then
					temp := Input1(n-5 downto 0) & "0000";	
				elsif Input2 = std_logic_vector( to_unsigned(5, Input2'length) ) then
					temp := Input1(n-6 downto 0) & "00000";
				elsif Input2 = std_logic_vector( to_unsigned(6, Input2'length) ) then
					temp := Input1(n-7 downto 0) & "000000";
				elsif Input2 = std_logic_vector( to_unsigned(7, Input2'length) ) then
					temp := Input1(n-8 downto 0) & "0000000";
				elsif Input2 = std_logic_vector( to_unsigned(8, Input2'length) ) then
					temp := Input1(n-9 downto 0) & "00000000";
				elsif Input2 = std_logic_vector( to_unsigned(9, Input2'length) ) then
					temp := Input1(n-10 downto 0) & "000000000";
				elsif Input2 = std_logic_vector( to_unsigned(10, Input2'length) ) then
					temp := Input1(n-11 downto 0) & "0000000000";
				elsif Input2 = std_logic_vector( to_unsigned(11, Input2'length) ) then
					temp := Input1(n-12 downto 0) & "00000000000";
				elsif Input2 = std_logic_vector( to_unsigned(12, Input2'length) ) then
					temp := Input1(n-13 downto 0) & "000000000000";
				elsif Input2 = std_logic_vector( to_unsigned(13, Input2'length) ) then
					temp := Input1(n-14 downto 0) & "0000000000000";
				elsif Input2 = std_logic_vector( to_unsigned(14, Input2'length) ) then
					temp := Input1(n-15 downto 0) & "00000000000000";
				elsif Input2 = std_logic_vector( to_unsigned(15, Input2'length) ) then
					temp := Input1(0) & "000000000000000";
				else
					temp := (OTHERS => '0');
				end if;
			when SRL_FUNC =>
				if Input2 = std_logic_vector( to_unsigned(0, Input2'length) ) then
					temp := Input1;
				elsif Input2 = std_logic_vector( to_unsigned(1, Input2'length) ) then
					temp := "0" & Input1(n-1 downto 1);
				elsif Input2 = std_logic_vector( to_unsigned(2, Input2'length) ) then
					temp := "00" & Input1(n-1 downto 2);
				elsif Input2 = std_logic_vector( to_unsigned(3, Input2'length) ) then
					temp := "000" & Input1(n-1 downto 3);
				elsif Input2 = std_logic_vector( to_unsigned(4, Input2'length) ) then
					temp := "0000" & Input1(n-1 downto 4);
				elsif Input2 = std_logic_vector( to_unsigned(5, Input2'length) ) then
					temp := "00000" & Input1(n-1 downto 5);
				elsif Input2 = std_logic_vector( to_unsigned(6, Input2'length) ) then
					temp := "000000" & Input1(n-1 downto 6);
				elsif Input2 = std_logic_vector( to_unsigned(7, Input2'length) ) then
					temp := "0000000" & Input1(n-1 downto 7);
				elsif Input2 = std_logic_vector( to_unsigned(8, Input2'length) ) then
					temp := "00000000" & Input1(n-1 downto 8);
				elsif Input2 = std_logic_vector( to_unsigned(9, Input2'length) ) then
					temp := "000000000" & Input1(n-1 downto 9);
				elsif Input2 = std_logic_vector( to_unsigned(10, Input2'length) ) then
					temp := "0000000000" & Input1(n-1 downto 10);
				elsif Input2 = std_logic_vector( to_unsigned(11, Input2'length) ) then
					temp := "00000000000" & Input1(n-1 downto 11);
				elsif Input2 = std_logic_vector( to_unsigned(12, Input2'length) ) then
					temp := "000000000000" & Input1(n-1 downto 12);
				elsif Input2 = std_logic_vector( to_unsigned(13, Input2'length) ) then
					temp := "0000000000000" & Input1(n-1 downto 13);
				elsif Input2 = std_logic_vector( to_unsigned(14, Input2'length) ) then
					temp := "00000000000000" & Input1(n-1 downto 14);
				elsif Input2 = std_logic_vector( to_unsigned(15, Input2'length) ) then
					temp := "000000000000000" & Input1(n-1);
				else
					temp := (OTHERS => '0');
				end if;
			when others =>
				temp := Input1 - Input2;
		end case;
		
		IF (temp4 = '0') THEN
			Carryout <= temp3;
		ELSE
			Carryout <= COUT;
		END IF;
		
		Output <= temp;
	end process;
END Logicfunc;

