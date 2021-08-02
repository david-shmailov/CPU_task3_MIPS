LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity PORT_LED_INTERFACE is
    port(
        reset,
        MemRead,
        CS,
        MemWrite       :in std_logic;
        data           :inout std_logic_vector(7 downto 0);
        output_to_leds :out std_logic_vector(7 downto 0)
    );
end PORT_LED_INTERFACE;


architecture structure of PORT_LED_INTERFACE is

    signal enable_write         :std_logic;
    signal read_leds_state      :STD_LOGIC_VECTOR(7 downto 0);
    signal enable_read          :std_logic;
    signal latch_output         :std_logic_vector(7 downto 0);
    --signal latch_input          :std_logic_vector(7 downto 0);
    signal tristate_output      :std_logic_vector(7 downto 0);

begin
    

    enable_read <= MemRead and cs;
    enable_write <= MemWrite and cs;

    output_to_leds <= latch_output;
    
    D_latch: process(enable_write, reset)
        variable Q      :STD_LOGIC_VECTOR(7 downto 0);
    begin
        if reset = '1' then
            Q := (others => '0');
        elsif rising_edge(enable_write) then
            Q := data;
        end if;
        latch_output <= Q;
    end process D_latch;


    --tristate behavior
    data <= latch_output when (enable_read = '1' and enable_write = '0') else (others => 'Z');

    -- tristate: process(enable_read)
    -- begin
    --     if rising_edge(enable_read) then
    --         tristate_output <= latch_output;
    --     else
    --         tristate_output <= (others => 'Z');
    --     end if;
    -- end process tristate;

END structure;