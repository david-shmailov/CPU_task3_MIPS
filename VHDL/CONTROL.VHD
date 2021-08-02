		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 
	Func        : IN    STD_LOGIC_VECTOR (5 DOWNTO 0);
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC;
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC;
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 	: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Branch 		: OUT 	STD_LOGIC;
	Jump        : out   STD_LOGIC;
	Jump_reg    : OUT   STD_LOGIC;
	shift       : OUT   STD_LOGIC;
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq ,Ben : STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	shift<=  (((NOT Beq)and R_format and (not Func(5)) and (not Func(4)) and
					 (not Func(3) ) and (not Func(2)) and  (not Func(0))));
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  (Opcode = "000100"  ) ELSE '0';
	Ben         <=  '1'  when  (opcode = "000101") else '0';
	Jump        <=  '1' when  (opcode="000010" or opcode="000011") else '0';
	Jump_reg    <=  '1' when  (opcode= "000000" and Func ="001000") else '0';
  	RegDst    	<=  R_format;
 	ALUSrc  	<=  Lw OR Sw;
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  ((R_format) OR (Lw) or( (not opcode(0)) and (not opcode(1)) and (not opcode(2)) and (opcode(3)) and (not opcode(4)) and (not opcode(5)))
	  or ( (not opcode(0)) and (not opcode(1)) and ( opcode(2)) and (opcode(3)) and (not opcode(4)) and (not opcode(5)))
	  or ( ( opcode(0)) and (not opcode(1)) and ( opcode(2)) and (opcode(3)) and (not opcode(4)) and (not opcode(5)))
	  or ( (not opcode(0)) and ( opcode(1)) and ( opcode(2)) and (opcode(3)) and (not opcode(4)) and (not opcode(5)))
	  or ( ( opcode(0)) and ( opcode(1)) and (opcode(2)) and (opcode(3)) and (not opcode(4)) and (not opcode(5)))
	  or ( (not opcode(0)) and (opcode(1)) and (not opcode(2)) and (opcode(3)) and (not opcode(4)) and (not opcode(5))));
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch      <=  Beq or Ben;
	ALUOp( 1 ) 	<=  R_format;
	ALUOp( 0 ) 	<=  Beq; 

   END behavior;


