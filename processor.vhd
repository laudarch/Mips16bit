library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


entity processor is
port(
clock: in std_logic;
clock2: in std_logic;
-------------------------------------------------------
-- Eksodos Katahoriton
-------------------------------------------------------
regOUT: out std_logic_vector(127+16 downto 0); -- pros othoni (REGs + PC)
-------------------------------------------------------
-- Instruction Memory
-------------------------------------------------------
instructionAD : out std_logic_vector(15 downto 0);
instr: in std_logic_vector(15 downto 0):= x"0000";
-------------------------------------------------------
-- Data Memory
-------------------------------------------------------
dataAD: out std_logic_vector(15 downto 0);
fromData: in std_logic_vector(15 downto 0):= x"0000";
toData: out std_logic_vector(15 downto 0);
DataWriteFlag: out std_logic;
-------------------------------------------------------
-- Keyboard
-------------------------------------------------------
keyEnable : out std_logic;
keyData   : in std_logic_vector(15 downto 0);
-------------------------------------------------------
-- Eksodos Othonis
-------------------------------------------------------
printEnable: out std_logic;
printCode  : out std_logic_vector(15 downto 0):= x"0000";
printData  : out std_logic_vector(15 downto 0):= x"0000"
);
end processor;

architecture struct of processor is
-------------------------------------------------------------------------------------
--          				  	     COMPONENTS        		   			           --
-------------------------------------------------------------------------------------
component Alu is
		GENERIC ( n : INTEGER := 16 );
		Port (  Input1, Input2 :IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				Carryin :IN STD_LOGIC;
				CarryOut :OUT STD_LOGIC;
				Operation :IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				Output :OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
				);
END component Alu;

component AluControl is
		port (  opCode :IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				func :IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				output :OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
				);
END component AluControl;

component regFile is
	generic ( 
		n : integer := 16;
		k : INTEGER := 3;
		regNum : INTEGER := 8
	);
	port (	
		Clock : in std_logic;
		Write1 : in std_logic_vector (n-1 downto 0);
		Write1AD, Read1AD, Read2AD : in std_logic_vector (k-1 downto 0);
		Read1, Read2 : out std_logic_vector (n-1 downto 0);
		OUTall: out std_logic_vector(n*regNum-1 downto 0)
	);
END component regFile;

component sign_extender is
	generic (
		n : integer := 16;
		k : integer := 6
	);
	port (	
		immediate : in std_logic_vector (k-1 downto 0);
		extended : out std_logic_vector (n-1 downto 0)
	);
END component sign_extender;

component JRSelector is
	generic (
			n : integer := 16
	);
	PORT (
	   jumpAD, branchAd,PCP2AD :		IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	   JRopcode: 						IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	   result: 							OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
	);
END component JRSelector;

component forwarder is
 	generic(
		addr_size : INTEGER := 3
	);
	port (	R1AD, R2AD, RegAD_EXMEM, RegAD_MEMWB : IN STD_LOGIC_VECTOR(addr_size-1 downto 0);
      		S1, S2 : OUT STD_LOGIC_VECTOR(1 downto 0));
END component forwarder;

component controller is
	port (opCode :IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 func: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 flush: IN STD_LOGIC;
		 isMPFC, isJumpD, isReadDigit, isPrintDigit, isR, isLW, isSW, isBranch, isJR  :OUT STD_LOGIC
		 );
END component controller;

component jumpAD is
	generic (
    	n : integer := 16;
		k : integer := 12
	);
	port (	
		jumpAD : in std_logic_vector (k-1 downto 0);
        instrP2AD : in std_logic_vector (n-1 downto 0);
		EjumpAD : out std_logic_vector (n-1 downto 0)
	);
END component jumpAD;

component hazardUnit is
	 PORT (
			   isJR, isJump, wasJump, mustBranch : IN STD_LOGIC;
			   flush, wasJumpOut : OUT STD_LOGIC;
			   JRopcode: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	 );
END component hazardUnit;

component trapUnit is
	  PORT (opcode : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			EOR : OUT STD_LOGIC);
END component trapUnit; 

component register_EX_MEM is
	generic ( n : INTEGER := 16; addressSize : INTEGER := 3 );
	port (
		clock, isLW, WriteEnable, ReadDigit, PrintDigit : IN std_logic;
  	 	R2Reg, Result : IN std_logic_vector(n-1 downto 0);
  	 	RegAD : IN std_logic_vector(addressSize-1 downto 0);
  	 	---------------------------------------------------------------------
		isLW_EXMEM, WriteEnable_EXMEM, ReadDigit_EXMEM, PrintDigit_EXMEM : OUT std_logic;
  	 	R2Reg_EXMEM, Result_EXMEM : OUT std_logic_vector(n-1 downto 0);
  	 	RegAD_EXMEM : OUT std_logic_vector(addressSize-1 downto 0)
	 );
end component register_EX_MEM;

component register_ID_EX is
	generic ( n : INTEGER := 16; addressSize : INTEGER := 3 );
	port (
			clock, isEOR, wasJumpOut, isJump, isJR, isBranch, isR, isMFPC, isLW, isSW, isReadDigit, isPrintDigit : in std_logic;
		ALUFunc : in STD_LOGIC_VECTOR(3 DOWNTO 0);
		R1Reg , R2Reg , immediate16 : IN std_logic_vector(n-1 downto 0);
		R2AD, R1AD : IN std_logic_vector(addressSize-1 downto 0);
		jumpShortAddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		---------------------------------------------------------------------
		isEOR_IDEX, wasJumpOut_IDEX, isJump_IDEX, isJR_IDEX , isBranch_IDEX, isR_IDEX, isMFPC_IDEX, isLW_IDEX, isSW_IDEX, isReadDigit_IDEX, isPrintDigit_IDEX : out STD_LOGIC;
		ALUFunc_IDEX : out STD_LOGIC_VECTOR(3 DOWNTO 0);
		R1Reg_IDEX , R2Reg_IDEX , immediate16_IDEX : OUT STD_LOGIC_VECTOR(n-1 downto 0);
		R2AD_IDEX , R1AD_IDEX : OUT STD_LOGIC_VECTOR(addressSize-1 downto 0);
		jumpShortAddr_IDEX : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	 );
end component register_ID_EX;

component register_IF_ID is
	generic ( n : INTEGER := 16 );
	port (
  		inPC, inInstruction : IN std_logic_vector(n-1 downto 0);
  		clock, IF_Flush, IF_ID_ENABLE : IN std_logic;
  		---------------------------------------------------------------------
  		outPC, outInstruction : OUT std_logic_vector(n-1 downto 0)
	 );
end component register_IF_ID;

component register_MEM_WB is
	generic ( n : INTEGER := 16; addressSize : INTEGER := 3 );
	port(	Result : IN std_logic_vector(n-1 downto 0);
			RegAD : IN std_logic_vector(addressSize-1 downto 0);
			clk : IN std_logic;
			---------------------------------------------------------------------
			writeData : OUT std_logic_vector(n-1 downto 0);
			writeAD : OUT std_logic_vector(addressSize-1 downto 0)
	 );
end component register_MEM_WB;

component reg16b IS
	PORT (Input : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
		  Enable, Clock : IN STD_LOGIC; 
		  Output : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0)); 
END component reg16b; 

component selector IS
	port (Reg, Memory, WriteBack : IN STD_LOGIC_VECTOR(15 downto 0);
		  operation : IN STD_LOGIC_VECTOR(1 downto 0);
		  output : OUT STD_LOGIC_VECTOR(15 downto 0));
end component selector;

------------------------------------------------------------------------------------------
---------                       END     COMPONENTS                        ----------------
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
--                  				 SIGNALS    						                --
------------------------------------------------------------------------------------------
signal PCresult: STD_LOGIC_VECTOR(15 DOWNTO 0):= x"0000";
signal outIFID_PC, outIFID_Instr, JROutput, immediate16, immediate16_IDEX, Jump_AD, writeData, Result_MEMWB, 
		R1Reg, R2Reg, R1Reg_IDEX, R2Reg_IDEX, R2Reg_EXMEM, S1Output, S2Output : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal JRopcode, S1opcode, S2opcode : STD_LOGIC_VECTOR(1 DOWNTO 0):="00";

signal isEOR_IDEX : STD_LOGIC:='0';

signal writeAD, RegAD_EXMEM : STD_LOGIC_VECTOR (2 downto 0);

signal wasJump : STD_LOGIC;
signal Flush_hazard, wasJumpOut, isEOR  : STD_LOGIC;

signal IF_Flush							:STD_LOGIC:='0';
signal IF_Enable						:STD_LOGIC:='1';

signal opcode							:STD_LOGIC_VECTOR(3 DOWNTO 0):= outIFID_Instr(15 DOWNTO 12);
signal RD								:STD_LOGIC_VECTOR(2 DOWNTO 0):= outIFID_Instr(11 DOWNTO 9);
signal R1AD								:STD_LOGIC_VECTOR(2 DOWNTO 0):= outIFID_Instr(8 DOWNTO 6);
signal RT								:STD_LOGIC_VECTOR(2 DOWNTO 0):= outIFID_Instr(5 DOWNTO 3);
signal func								:STD_LOGIC_VECTOR(2 DOWNTO 0):= outIFID_Instr(2 DOWNTO 0);
signal immediate						:STD_LOGIC_VECTOR(5 DOWNTO 0):= outIFID_Instr(5 DOWNTO 0);
signal jumpShortAddr					:STD_LOGIC_VECTOR(11 DOWNTO 0):= outIFID_Instr(11 DOWNTO 0);

signal jumpShortAddr_IDEX				:STD_LOGIC_VECTOR(11 DOWNTO 0);

signal R2AD, R2AD_IDEX, R1AD_IDEX   	:STD_LOGIC_VECTOR(2 DOWNTO 0); --:= outInstr(5 DOWNTO 3);

signal ALUFunc, ALUFunc_IDEX			:STD_LOGIC_VECTOR(3 DOWNTO 0);
signal allRegOut						:STD_LOGIC_VECTOR(127 DOWNTO 0);

--------------------- CONTROLLER SIGNALS ----------------------
signal isMFPC, isJump, isReadDigit, isPrintDigit, isR, isLW, isSW, isLW_IDEX, isSW_IDEX, isBranch, isJR, 
	   wasJumpOut_IDEX, isJump_IDEX, isJR_IDEX , isBranch_IDEX, isR_IDEX, isMFPC_IDEX, isReadDigit_IDEX, isPrintDigit_IDEX,
	   isLW_EXMEM, ReadDigit_EXMEM :STD_LOGIC;

--------------------- ALU SIGNALS ----------------------
signal ALUInput1, ALUInput2, ALUOutput, Result_EXMEM : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal ALUCarryin, ALUCarryout : STD_LOGIC;
signal ALUOperation : STD_LOGIC_VECTOR(3 DOWNTO 0);

------------------------------------------------------------------------------------------
----------     				      END     SIGNALS			        	------------------
------------------------------------------------------------------------------------------

begin

PC: reg16b port map(JROutput, isEOR NOR isEOR_IDEX, clock, PCresult);

IFIDREG: register_IF_ID PORT map(PCresult, instr, clock, IF_Flush, IF_Enable, outIFID_PC, outIFID_Instr);

SignExtend: sign_extender port map(immediate, immediate16);

JR: JRSelector port map(Jump_AD, immediate16_IDEX, outIFID_PC, JRopcode, JROutput);

Hazard: hazardUnit port map(isJR, isJump, wasJump, isBranch_IDEX AND ALUCarryout, Flush_hazard, wasJumpOut, JRopcode);

Trap: trapUnit port map(opcode, isEOR);

ALUController: ALUControl port map(opcode, func, ALUFunc);

Controler: controller port map(opcode, func, Flush_hazard OR isEOR_IDEX, isMFPC, isJump, isReadDigit, isPrintDigit, isR, isLW, isSW, isBranch, isJR);

-------
selectRegister : process(isR) begin
	case isR is
		when '1'  =>
			R2AD <= RT;
		when '0'  => 
			R2AD <= RD;
		when others => 
			R2AD <= RD;
	end case;
end process;
-------

RegisterFile: regFile port map(clock2, writeData, writeAD, R1AD, R2AD, R1Reg, R2Reg, allRegOut);

IDEXREG: register_ID_EX port map(clock, isEOR, wasJumpOut, isJump, isJR, isBranch, isR, isMFPC, isLW, 
	isSW, isReadDigit, isPrintDigit, ALUFunc, R1Reg , R2Reg , immediate16, R2AD, R1AD, jumpShortAddr, 
	isEOR_IDEX, wasJumpOut_IDEX, isJump_IDEX, isJR_IDEX , isBranch_IDEX, isR_IDEX, isMFPC_IDEX, isLW_IDEX, 
	isSW_IDEX, isReadDigit_IDEX, isPrintDigit_IDEX, ALUFunc_IDEX, R1Reg_IDEX , R2Reg_IDEX , immediate16_IDEX, 
																	R2AD_IDEX , R1AD_IDEX, jumpShortAddr_IDEX);
																	
Selector1: selector port map(R1Reg_IDEX, Result_MEMWB, writeData, S1opcode, S1Output);
Selector2: selector port map(R2Reg_IDEX, Result_MEMWB, writeData, S2opcode, S2Output);

ForwardUnit: forwarder port map(R1AD_IDEX, R2AD_IDEX, RegAD_EXMEM, writeAD, S1opcode, S2opcode);

--		ALUSrc, EX_MEM_regwrite, MEM_WB_regwrite : IN STD_LOGIC;

ALUMuxes : process(isMFPC_IDEX, isR_IDEX) begin
	IF (isMFPC_IDEX = '1') then
		ALUInput1 <= S1Output;
	ELSE 
		ALUInput1 <= outIFID_PC;
	END IF;
	IF (isR_IDEX = '1') then
		ALUInput2 <= immediate16_IDEX;
	ELSE 
		ALUInput2 <= S2Output;
	END IF;
end process;

ALU16: ALU port map(ALUInput1, ALUInput2, ALUCarryin, ALUCarryout, ALUFunc_IDEX, ALUOutput);

EXMEMREG: register_EX_MEM port map(clock, isLW_IDEX, isSW_IDEX, isReadDigit_IDEX, isPrintDigit_IDEX, R2Reg_IDEX, ALUOutput, R2AD_IDEX,
						isLW_EXMEM, DataWriteFlag, ReadDigit_EXMEM, printEnable, R2Reg_EXMEM, Result_EXMEM, RegAD_EXMEM);

-------
selectMEMWBResult : process(isLW_EXMEM, ReadDigit_EXMEM) begin
	IF (isLW_EXMEM = '1') then
		Result_MEMWB <= fromData;
	ELSIF (ReadDigit_EXMEM = '1') then
		Result_MEMWB <= keyData;
	ELSE 
		Result_MEMWB <= Result_EXMEM; -- or R2Reg_EXMEM ?
	END IF;
end process;
-------

MEMWBREG: register_MEM_WB port map(Result_MEMWB, RegAD_EXMEM, clock, writeData, writeAD);

--- behavioral signals ---
printData <= Result_EXMEM;

toData <= Result_EXMEM;

printCode <= R2Reg_EXMEM;

keyEnable <= ReadDigit_EXMEM;

dataAD <= R2Reg_EXMEM;

Jump_AD <= (15 downto 12 => jumpShortAddr_IDEX(11)) & (jumpShortAddr_IDEX); --extend jumpShortAddr_IDEX to 16 bits

instructionAD <= PCresult;

RegOut <=  PCresult & allRegOut;


end struct;
