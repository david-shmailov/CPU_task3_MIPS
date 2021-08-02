LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

LIBRARY work;

entity system_no_mips_tb is

end system_no_mips_tb;

architecture struct of system_no_mips_tb is
    component system_no_mips is
        port ( reset , clock    :IN STD_LOGIC;
            SW_vector       :in STD_LOGIC_VECTOR(7 downto 0);
            LEDG_vector      :out STD_LOGIC_VECTOR(7 downto 0);
            LEDR_vector      :out STD_LOGIC_VECTOR(7 downto 0);
            HEX0            :out std_logic_vector(6 downto 0);
            HEX1            :out std_logic_vector(6 downto 0);
            HEX2            :out std_logic_vector(6 downto 0);
            HEX3            :out std_logic_vector(6 downto 0);
            -- replace the mips with inputs from outside
            MemRead         :in std_logic;
            MemWrite        :in std_logic;
            full_address    :in std_logic_vector(11 downto 0);
            data_in_read    :out std_logic_vector(7 downto 0);
            data_out_write  :in std_logic_vector(7 downto 0);
            cs_output_for_test: out std_logic_vector(6 downto 0);
            addr_output_for_test: out std_logic_vector(3 downto 0)
        );
    end component;

    signal reset , clock    :STD_LOGIC := '0';
    signal SW_vector       :STD_LOGIC_VECTOR(7 downto 0);
    signal LEDG_vector     :STD_LOGIC_VECTOR(7 downto 0);
    signal LEDR_vector     :STD_LOGIC_VECTOR(7 downto 0);
    signal HEX0            :std_logic_vector(6 downto 0);
    signal HEX1            :std_logic_vector(6 downto 0);
    signal HEX2            :std_logic_vector(6 downto 0);
    signal HEX3            :std_logic_vector(6 downto 0);
    -- replace the mips with inputs from outside
    signal MemRead         :std_logic;
    signal MemWrite        :std_logic;
    signal full_address    :std_logic_vector(11 downto 0);
    signal data_in_read    :std_logic_vector(7 downto 0);
    signal data_out_write  :std_logic_vector(7 downto 0);
    signal cs_vector       :std_logic_vector(6 downto 0);
    signal addr            :std_logic_vector(3 downto 0);

begin

    system: system_no_mips 
        port map(
            reset               => reset,         
            clock               => clock,        
            SW_vector           => SW_vector,     
            LEDG_vector         => LEDG_vector,   
            LEDR_vector         => LEDR_vector ,  
            HEX0                => HEX0        ,  
            HEX1                => HEX1         , 
            HEX2                => HEX2          ,
            HEX3                => HEX3          ,
            MemRead             => MemRead       ,
            MemWrite            => MemWrite      ,
            full_address        => full_address  ,
            data_in_read        => data_in_read  ,
            data_out_write      => data_out_write,
            cs_output_for_test  => cs_vector,
            addr_output_for_test => addr
        );


    test: process
    begin
        wait for 100 ns;
        SW_vector <= b"0010_0110";
        --read from switches
        full_address <= x"818";
        memRead <= '1';
        memWrite <= '0';
        data_out_write <= b"0000_0000";
        wait for 100 ns;

        --write to green leds
        full_address <= x"800";
        memWrite <= '1';
        memRead <= '0';
        data_out_write <= b"0000_1010";
        wait for 100 ns;

        --write to red leds
        full_address <= x"804";
        memWrite <= '1';
        memRead <= '0';
        data_out_write <= b"0101_0010";
        wait for 100 ns;

        --read from green leds
        full_address <= x"800";
        memWrite <= '0';
        memRead <= '1';
        data_out_write <= b"0000_0000";
        wait for 100 ns;

        -- write to HEX0
        full_address <= x"808";
        memWrite <= '1';
        memRead <= '0';
        data_out_write <= b"0000_1111";
        wait for 100 ns;
        -- read from hex0
        memRead <= '1';
        memWrite <= '0';
        wait for 100 ns;
    end process test;

    gen_clk : process
    begin
        clock <= not clock;
        wait for 50 ns;
    end process;

    gen_rst : process
    begin
      reset <='1','0' after 100 ns;
      wait;
    end process; 


end struct;