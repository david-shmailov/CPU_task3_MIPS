
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

 ENTITY port_sw_interface is 
        port(
            MemRead     :in std_logic;     
            cs7         :in std_logic;
            SW_vector   :in std_logic_vector(7 downto 0);
            data        :inout std_logic_vector(7 downto 0)
        );
    end port_sw_interface;

ARCHITECTURE struct OF port_sw_interface IS
begin 

tristate: process (cs7, MemRead,SW_vector)
begin 
	if (MemRead='1' and cs7='1') then
	    data <= SW_vector;
    else 
		data <= (others =>'Z');
    end if;
end process tristate;

				
end struct;