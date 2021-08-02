-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	SIGNAL Branch 			: IN 	STD_LOGIC;
        	SIGNAL Zero 			: IN 	STD_LOGIC;
			SIGNAL Jump             : IN    STD_LOGIC;
			SIGNAL Jump_reg_val     : IN    STD_LOGIC_VECTOR(9 downto 0);
			SIGNAL Jump_reg         : IN    STD_LOGIC;
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			signal check            :out    STD_LOGIC_vector(9 downto 0);
        	SIGNAL clock, reset 	: IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4,Mem_Addr 	 : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL next_PC  		 : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL jump_result       : STD_LOGIC_vector (9 downto 0);
	SIGNAL one               : STD_LOGIC_VECTOR(9 downto 0):= (0=>'1',others=> '0');
	signal jmp               :STD_LOGIC_VECTOR(9 downto 0);
	signal out_ins           :STD_LOGIC_VECTOR(31 downto 0);
BEGIN
		jmp<= out_ins(9 downto 0);
		jump_result<= std_logic_vector(shift_left(unsigned(jmp),2)) ;
		check<=jump_result;
						--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => 10,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "program.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clock,
		address_a 	=> Mem_Addr, 
		q_a 			=> out_ins );
		Instruction<=out_ins;
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
		Mem_Addr <= Next_PC &"00";
						-- Adder to increment PC by 4        
      	PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
		Next_PC  <=jump_reg_val(9 downto 2) when Jump_reg = '1' else jump_result(9 downto 2) when jump='1' else X"00" WHEN Reset = '1' ELSE
			Add_result  WHEN ( ( Branch = '1' ) AND ( Zero = '1' ) ) 
			ELSE   PC_plus_4( 9 DOWNTO 2 );
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC( 9 DOWNTO 2) <= "00000000" ; 
			else 
				PC( 9 DOWNTO 2 ) <= next_PC;
			END IF;
	END PROCESS;

	-- process(clock, reset)
	-- begin
	-- 	if reset = '1' then
	-- 		PC( 9 DOWNTO 2) <= "00000000" ; 
	-- 	elsif rising_edge(clock) then
	-- 		PC( 9 DOWNTO 2 ) <= next_PC;
	-- 	end if;
	-- end process;
END behavior;


