				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS

	PORT( reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		MemReadOut,MemWriteOut          : OUT   STD_LOGIC; 
		j                               : OUT   STD_LOGIC;
		j_re                            : out   STD_LOGIC_VECTOR(9 downto 0);
		Address                         : OUT   STD_LOGIC_VECTOR(11 downto 0);
		PC,check						: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		data_out_write                  : OUT  STD_LOGIC_VECTOR(7 downto 0);
		data_in_read                    : IN   STD_LOGIC_VECTOR(7 downto 0);
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC );
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch
   	     PORT( Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	 PC_plus_4_out 		: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	 Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	 Branch 			: IN 	STD_LOGIC;
        	 Zero 				: IN 	STD_LOGIC;
			 Jump             	: IN    STD_LOGIC;
			 Jump_reg_val  		 : IN    STD_LOGIC_VECTOR(9 downto 0);
			 Jump_reg       	 : IN    STD_LOGIC;
      		 PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			check              :out    STD_LOGIC_VECTOR(9 downto 0);
			clock, reset 		: IN 	STD_LOGIC);
	END COMPONENT; 

	COMPONENT Idecode
 	     PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC;
			RegDst 		: IN 	STD_LOGIC;
			shift       : In    STD_LOGIC;
			Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock,reset	: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT control
	     PORT( 		Func        : IN    STD_LOGIC_VECTOR (5 DOWNTO 0);
					Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
					RegDst 		: OUT 	STD_LOGIC;
					ALUSrc 		: OUT 	STD_LOGIC;
					MemtoReg 	: OUT 	STD_LOGIC;
					RegWrite 	: OUT 	STD_LOGIC;
					MemRead 	: OUT 	STD_LOGIC;
					MemWrite 	: OUT 	STD_LOGIC;
					Branch 		: OUT 	STD_LOGIC;
					Jump        : out   STD_LOGIC;
					Jump_reg    :OUT    STD_LOGIC;
					shift       : OUT   STD_LOGIC;
					ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
					clock, reset	: IN 	STD_LOGIC );

	END COMPONENT;

	COMPONENT  Execute
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
	END COMPONENT;


	COMPONENT dmemory
	     PORT(read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
	END COMPONENT;

	signal padded_address	: STD_LOGIC_VECTOR(9 downto 0);
					-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL Branch 			: STD_LOGIC;
	SIGNAL RegDst 			: STD_LOGIC;
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemWrite_real 	: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC;
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL MemRead_real 	: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  1 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal choice           : STD_LOGIC_VECTOR(5 downto 0);
	signal Jump             : STD_LOGIC;
	signal Jump_reg         : STD_LOGIC;
    signal Jump_reg_val        :STD_LOGIC_VECTOR(9 downto 0);
	signal data_in_fin      :STD_LOGIC_VECTOR(31 downto 0);
	signal writeData        :STD_LOGIC_VECTOR(31 downto 0);
	signal shift            : STD_LOGIC;
BEGIN
	j<=jump;
	j_re<=Jump_reg_val;
	MemReadOut<=MemRead;
	MemWriteOut<=MemWrite;
	Address<= ALU_Result(11 downto 0);				
					-- copy important signals to output pins for easy 
					-- display in Simulator
	MemRead_real	<=MemRead when (ALU_Result (11)='0') else '0';
	MemWrite_real   <=MemWrite when (ALU_Result(11)='0') else '0';
   Instruction_out 	<= Instruction;
   ALU_result_out 	<= ALU_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;
   data_out_write 	<=read_data_2(7 downto 0);  
   data_in_fin		<=(0=>data_in_read(0), 1=>data_in_read(1), 2=>data_in_read(2), 3=>data_in_read(3),
					   4=>data_in_read(4), 5=>data_in_read(5), 6=>data_in_read(6), 7=>data_in_read(7),others=>'0');
   write_data_out  	<=writeData;
   writeData		<= ALU_Result when (MemtoReg='0') else data_in_fin when (ALU_Result(11)='1') else read_data;
   Branch_out 		<= Branch;
   Zero_out 		<= Zero;
   RegWrite_out 	<= RegWrite;
   MemWrite_out 	<= MemWrite;
   choice           <= Instruction(31 downto 26) when (ALUOp="00" or ALUOp="01" ) 
						else Instruction( 5 DOWNTO 0 ) ;
					-- connect the 5 MIPS components   
  IFE : Ifetch
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				Branch 			=> Branch,
				Zero 			=> Zero,
				Jump            => Jump,
				Jump_reg_val    =>Jump_reg_val,
				Jump_reg        =>Jump_reg,
				PC_out 			=> PC,
				check			=>check,        		
				clock 			=> clock,  
				reset 			=> reset );

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data 		=> writeData,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				RegDst 			=> RegDst,
				Sign_extend 	=> Sign_extend,
				shift          	=> shift, 
        		clock 			=> clock,  
				reset 			=> reset );


   CTL:   control
	PORT MAP ( 	Func            => Instruction(5 downto 0), 
				Opcode 			=> Instruction( 31 DOWNTO 26 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				Branch 			=> Branch,
				Jump            => Jump,
				Jump_reg        => Jump_reg,
				shift          	=> shift, 
				ALUop 			=> ALUop,
                clock 			=> clock,
				reset 			=> reset );

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
                Function_opcode	=> choice ,
				ALUOp 			=> ALUop,
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
				Jump_reg_val    =>Jump_reg_val,
                Clock			=> clock,
				Reset			=> reset );

	padded_address <= ALU_Result (9 DOWNTO 2) & "00";--jump memory address by 4
   MEM:  dmemory
	PORT MAP (	read_data 		=> read_data,
				address 		=> padded_address,
				write_data 		=> read_data_2,
				MemRead 		=> MemRead_real, 
				Memwrite 		=> MemWrite_real, 
                clock 			=> clock,  
				reset 			=> reset );
END structure;

