--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.numeric_std.all;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			Jump_reg_val       :OUT    STD_LOGIC_VECTOR(9 downto 0);
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput   			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal Binput 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
signal choice               : STD_LOGIC_VECTOR(31 downto 0);
signal op1, op2             : STD_LOGIC;
signal zero1                : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
SIGNAL MUL                  : STD_LOGIC_VECTOR(63 DOWNTO 0);
signal Bne                  : STD_LOGIC;
BEGIN
	bne<=((not Function_opcode(5))and  (not Function_opcode(4)) and (not Function_opcode(3)) and
						( Function_opcode(2)) and (not Function_opcode(1)) and ( Function_opcode(0)));
	MUL<= Ainput *Binput;
	Ainput <= Read_data_1;
						-- ALU input mux
	choice <= Read_data_2 when(ALUOp="00" and bne='1') else sign_extend( 31 downto 0) WHEN (ALUOp ="00"  ) else Read_data_2;
	Binput <= choice
		WHEN ( ALUSrc = '0' ) 
  		ELSE  Sign_extend( 31 DOWNTO 0 );
						-- Generate ALU control bits
						ALU_ctl( 0 ) <= ((( Function_opcode( 0 ) OR Function_opcode( 3 ) )and ALUOp(1)) 
										or (( Function_opcode( 0 ) OR (not Function_opcode( 3 )) ) and (not ALUOp(1))) or
										((not Function_opcode(5))and  (Function_opcode(4)) and (Function_opcode(3)) and
										(Function_opcode(2)) and (not Function_opcode(1)) and (not Function_opcode(0)) and 
										(not ALUOp(0)) and (not ALUOp(1))) or
										((not Function_opcode(5))and  (not Function_opcode(4)) and (Function_opcode(3)) and
										(not Function_opcode(2)) and (Function_opcode(1)) and (not Function_opcode(0)) and (not ALUOp(0)) and (not ALUOp(1)))
										 or 
										((not Function_opcode(5))and  (not Function_opcode(4)) and (not Function_opcode(3)) and
										( Function_opcode(2)) and (not Function_opcode(1)) and ( Function_opcode(0)) and 
										(not ALUOp(0)) and (not ALUOp(1))));

						ALU_ctl( 1 ) <= (( NOT Function_opcode( 2 ) )or
										((not Function_opcode(5))and  (not Function_opcode(4)) and (not Function_opcode(3)) and
										(Function_opcode(2)) and (not Function_opcode(1)) and (Function_opcode(0)) and 
										(not ALUOp(0)) and (not ALUOp(1))) or 
										((not Function_opcode(5))and  (not Function_opcode(4)) and (not Function_opcode(3)) and
										( Function_opcode(2)) and (not Function_opcode(1)) and (not Function_opcode(0)) and 
										( ALUOp(0)) and (not ALUOp(1))));
	
	ALU_ctl( 2 ) <= (((( Function_opcode( 1 )) AND ALUOp( 1 )) OR ALUOp( 0 ) ) or
						((not Function_opcode(5))and (not Function_opcode(4)) and (Function_opcode(3)) and
						(Function_opcode(2)) and Function_opcode(1) and (not Function_opcode(0)) and 
						(not ALUOp(0)) and (not ALUOp(1))) or
						((not Function_opcode(5))and  (not Function_opcode(4)) and (Function_opcode(3)) and
						(not Function_opcode(2)) and (Function_opcode(1)) and (not Function_opcode(0)) and 
						(not ALUOp(0)) and (not ALUOp(1)))or
						((not Function_opcode(5))and  (not Function_opcode(4)) and (Function_opcode(3)) and
						(Function_opcode(2)) and (Function_opcode(1)) and (Function_opcode(0)) and 
						(not ALUOp(0)) and (not ALUOp(1))) or
						((not Function_opcode(5))and  (not Function_opcode(4)) and (not Function_opcode(3)) and
						(Function_opcode(2)) and (not Function_opcode(1)) and (Function_opcode(0)) and 
						(not ALUOp(0)) and (not ALUOp(1)))  or 
						((not Function_opcode(5))and  (not Function_opcode(4)) and (not Function_opcode(3)) and
						( Function_opcode(2)) and (not Function_opcode(1)) and ( Function_opcode(0)) and 
						(not ALUOp(0)) and (not ALUOp(1))));	

	ALU_ctl( 3 ) <=  ((Function_opcode(5) AND (NOT ALUOp(0)) AND (NOT ALUOp(1)))or ((NOT ALUOp(0))and ALUOp(1) and
						(not Function_opcode(5)) and (not Function_opcode(4)) and
						(not Function_opcode(3) ) and (not Function_opcode(2)) and  (not Function_opcode(0))) or
					   ((not Function_opcode(5))and  (Function_opcode(4)) and (Function_opcode(3)) and
						   (Function_opcode(2)) and (not Function_opcode(1)) and (not Function_opcode(0)) and 
						   (not ALUOp(0)) and (not ALUOp(1))));
						-- Generate Zero Flag
	op1 <= '1' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = zero1 )
		ELSE '0'; 
    op2 <= '0' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = zero1 )
		ELSE '1'; 		
	Zero <= op2 
		WHEN ( ALUOp ="00")
		ELSE op1;    
	Jump_reg_val<= Ainput(9 downto 0) when (ALUOp="10" and Function_opcode="001000") else (others=>'0');
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) 
		WHEN  ALU_ctl = "0111" 
		ELSE  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
		Add_result 	<= Branch_Add( 7 DOWNTO 0 );

PROCESS ( ALU_ctl, Ainput, Binput )
	BEGIN
					-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- ALU performs ALU_Result = A_input
 	 	WHEN "0011" 	=>	ALU_output_mux <= Ainput;
						-- ALU performs ALUresult = A_input xor B_input
 	 	WHEN "0100" 	=>	ALU_output_mux 	<= Ainput xor Binput;
						-- ALU performs ?
 	 	WHEN "0101" 	=>	ALU_output_mux 	<= std_logic_vector(shift_left(unsigned(Binput),16));
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "0111" 	=>	ALU_output_mux 	<= Ainput - Binput ;
		WHEN "1010"     =>  ALU_output_mux  <=std_logic_vector( shift_left(unsigned(Binput),to_integer(unsigned(Ainput))));
		WHEN "1110"     =>  ALU_output_mux <= std_logic_vector(shift_right(unsigned(Binput), to_integer(unsigned(Ainput))));
		WHEN "1001"     => ALU_output_mux <= MUL(31 downto 0);
		WHEN "1011"     => ALU_output_mux <= Ainput +Binput;
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
END behavior;

