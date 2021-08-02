LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY addr_decoder is 
	port(
		addr        :in STD_LOGIC_VECTOR(3 downto 0);
		cs_vector   :out STD_LOGIC_VECTOR(6 downto 0)
	);
end addr_decoder;

ARCHITECTURE struct OF addr_decoder IS
begin 

with addr select 
	cs_vector<= (0=> '1' ,others=> '0') when "1000",
				(1=> '1' , others=> '0') when "1001",
				(2=> '1' , others=>'0') when "1010",
				(3=> '1', others=>'0') when "1011",
				(4=> '1', others=>'0') when "1100",
				(5=> '1', others=>'0') when "1101",
				(6=> '1', others=>'0') when "1110",
				(others =>'0') when others;
				
end struct;