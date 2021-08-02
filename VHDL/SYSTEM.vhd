LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

entity system is
    port ( reset , clock    :IN STD_LOGIC;
            SW_vector       :in STD_LOGIC_VECTOR(7 downto 0);
            LEDG_vector      :out STD_LOGIC_VECTOR(7 downto 0);
            LEDR_vector      :out STD_LOGIC_VECTOR(7 downto 0);
            HEX0            :out std_logic_vector(6 downto 0);
            HEX1            :out std_logic_vector(6 downto 0);
            HEX2            :out std_logic_vector(6 downto 0);
            HEX3            :out std_logic_vector(6 downto 0)      
    );
end system;

architecture structure of system is
    component MIPS 
        PORT( reset, clock				: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		MemReadOut,MemWriteOut          : OUT   STD_LOGIC; 
		Address                         : OUT   STD_LOGIC_VECTOR(11 downto 0);
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		data_out_write                  : OUT  STD_LOGIC_VECTOR(7 downto 0);
		data_in_read                    : IN   STD_LOGIC_VECTOR(7 downto 0);
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC );
    end component;

    component PORT_LED_INTERFACE
        port(
            reset,
            MemRead,
            CS,
            MemWrite       :in std_logic;
            data           :inout std_logic_vector(7 downto 0);
            output_to_leds :out std_logic_vector(7 downto 0)
        );
    end component;

    component PORT_HEX_INTERFACE
        port(
            reset,
            MemRead,
            CS,
            MemWrite        :in std_logic;
            data            :inout STD_LOGIC_VECTOR(7 downto 0);
            output_to_7seg  :out std_logic_vector(6 downto 0)
        );

    end component;

    component addr_decoder
        port(
            addr        :in STD_LOGIC_VECTOR(3 downto 0);
            cs_vector   :out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    component port_sw_interface
        port(
            MemRead,
            cs7         :in std_logic;
            SW_vector   :in std_logic_vector(7 downto 0);
            data        :out std_logic_vector(7 downto 0)
        );
    end component;
    --signal clock                :std_logic;
    signal MemRead              :std_logic;
    signal MemWrite             :std_logic;
    signal cs_vector            :std_logic_vector(6 downto 0);
    signal data                 :std_logic_vector(7 downto 0);
    signal full_address         :std_logic_vector(11 downto 0);
    signal addr                 :std_logic_vector(3 downto 0);
    signal data_in_read            :std_logic_vector(7 downto 0);
    signal data_out_write           :std_logic_vector(7 downto 0);

    signal SW_vector_inside       :STD_LOGIC_VECTOR(7 downto 0);
    signal LEDG_vector_inside     :STD_LOGIC_VECTOR(7 downto 0);
    signal LEDR_vector_inside     :STD_LOGIC_VECTOR(7 downto 0);
    signal HEX0_inside            :STD_LOGIC_VECTOR(6 downto 0);
    signal HEX1_inside            :STD_LOGIC_VECTOR(6 downto 0);
    signal HEX2_inside            :STD_LOGIC_VECTOR(6 downto 0);
    signal HEX3_inside            :STD_LOGIC_VECTOR(6 downto 0);
    -- the push buttons are 0 when pressed
    signal neg_reset              :std_logic;
    --debug
    --constant    N : integer := 0;
    --signal one                    :std_logic_vector(N downto 0):= (0 => '1',others=>'0');
begin
    -- -- to create hardware clock division increase N constant to divide by 2^N the clock.
    -- delay : process(clock_24mhz)
	-- 	variable counter : std_logic_vector (N downto 0) :=(others=>'0');
	-- begin
	-- 	if(rising_edge(clock_24mhz)) then
	-- 		counter := counter + one;
	-- 	end if;
	-- 	clock <= counter(N);
	-- end process;


    --the reset is negetive edge in the fpga, but positive edge in the sub entities.
    neg_reset <= not reset;

    -- --short the input registers:
    -- SW_vector_inside <= SW_vector;

    -- short the output registers:
    HEX0 <= HEX0_inside;
    HEX1 <= HEX1_inside;
    HEX2 <= HEX2_inside;
    HEX3 <= HEX3_inside;
    LEDG_vector <= LEDG_vector_inside;
    LEDR_vector <= LEDR_vector_inside;

    -- the 2 following procceses are input and output registers for synchronus IO
    
    input_buffer: process(clock, neg_reset)
        variable temp_sw_vec :std_logic_vector(7 downto 0);
    begin
        if neg_reset = '1' then
            temp_sw_vec := (others => '0');
        elsif rising_edge(clock) then
            temp_sw_vec := SW_vector;
        end if;
        SW_vector_inside <= temp_sw_vec;
    end process input_buffer;

    -- output_buffer: process(clock,neg_reset)
    --     variable LEDG_vector_temp :std_logic_vector(7 downto 0);
    --     variable LEDR_vector_temp :std_logic_vector(7 downto 0);
    --     variable HEX0_temp :std_logic_vector(6 downto 0);
    --     variable HEX1_temp :std_logic_vector(6 downto 0);
    --     variable HEX2_temp :std_logic_vector(6 downto 0);
    --     variable HEX3_temp :std_logic_vector(6 downto 0);
    -- begin
    --     if neg_reset = '1' then
    --         LEDG_vector_temp := (others => '0');
    --         LEDR_vector_temp := (others => '0');
    --         HEX0_temp := (others => '0');
    --         HEX1_temp := (others => '0');
    --         HEX2_temp := (others => '0');
    --         HEX3_temp := (others => '0');
    --     elsif rising_edge(clock) then
    --         LEDG_vector_temp := LEDG_vector_inside;
    --         LEDR_vector_temp := LEDR_vector_inside;
    --         HEX0_temp := HEX0_inside;
    --         HEX1_temp := HEX1_inside;
    --         HEX2_temp := HEX2_inside;
    --         HEX3_temp := HEX3_inside;
    --     end if;
    --     LEDG_vector <= LEDG_vector_temp;
    --     LEDR_vector <= LEDR_vector_temp;
    --     HEX0 <= HEX0_temp;
    --     HEX1 <= HEX1_temp;
    --     HEX2 <= HEX2_temp;
    --     HEX3 <= HEX3_temp;

    -- end process output_buffer;

    --two tri-state to combine data inout into data_in_read IN and data_out_write OUT
    data <= data_out_write when (memRead = '0' and memWrite = '1') else (others => 'Z');
    
    data_in_read <= data when (memRead = '1' and memWrite = '0') else (others => 'Z');
    
    -- cutting address to addr before input into decoder
    addr <= full_address(11) & full_address(4 downto 2);

    MIPS_CORE: MIPS
        port map(
            reset           => neg_reset, 
            clock			=> clock,
            data_in_read    => data_in_read,
            data_out_write  => data_out_write,
            MemWriteOut     => MemWrite,
            MemReadOut      => MemRead,
            Address         => full_address
        );    

    PORT_LEDG_INTERFACE: PORT_LED_INTERFACE
        port map(
            reset           => neg_reset,
            MemRead         => MemRead,
            CS              => cs_vector(0),
            MemWrite        => MemWrite,
            data            =>  data,
            output_to_leds  =>  LEDG_vector_inside
        );

    PORT_LEDR_INTERFACE: PORT_LED_INTERFACE
        port map(
            reset           => neg_reset,
            MemRead         => MemRead,
            CS              => cs_vector(1),
            MemWrite        => MemWrite,
            data            =>  data,
            output_to_leds  =>  LEDr_vector_inside
        );


    PORT_HEX0_INTERFACE: PORT_HEX_INTERFACE
        port map(
            reset           => neg_reset,
            MemRead         => MemRead,
            Memwrite        => Memwrite,
            CS              => cs_vector(2),
            data            => data,
            output_to_7seg  => HEX0_inside
        );

    PORT_HEX1_INTERFACE: PORT_HEX_INTERFACE
        port map(
            reset           => neg_reset,
            MemRead         => MemRead,
            Memwrite        => Memwrite,
            CS              => cs_vector(3),
            data            => data,
            output_to_7seg  => HEX1_inside
        );

    PORT_HEX2_INTERFACE: PORT_HEX_INTERFACE
        port map(
            reset           => neg_reset,
            MemRead         => MemRead,
            Memwrite        => Memwrite,
            CS              => cs_vector(4),
            data            => data,
            output_to_7seg  => HEX2_inside
        );
        
    PORT_HEX3_INTERFACE: PORT_HEX_INTERFACE
        port map(
            reset           => neg_reset,
            MemRead         => MemRead,
            Memwrite        => Memwrite,
            CS              => cs_vector(5),
            data            => data,
            output_to_7seg  => HEX3_inside
        );

    optimized_address_decoder: addr_decoder
        port map(
            addr        => addr,
            cs_vector   => cs_vector
        );

    sw_interface: port_sw_interface
        port map(
            MemRead     =>  MemRead,
            cs7         =>  cs_vector(6),
            SW_vector   =>  SW_vector_inside,
            data        =>  data
        );

END structure;

    