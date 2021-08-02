the VHDL folder contains:
SYSTEM.vhd - the top entity connects to the leds, hex , switches on the board
segment - converts binary number into hex display on 7 segment
port_sw_interface - interface between system and switches
port_led_interface - interface between system and LEDs
port_hex_interface - interface between system and 7 segments
MIPS - the MIPS core top entity
IFETCH - the ifetch stage of mips. responsible for fetching instructions, envelopes the instruction memory
IDECODE - the top entity of the register file
EXECUTE - the entity that conducts most of the arithmatic and logical operations
DMEMORY - envelopes the data memory 
CONTROL - mips control unit
addr_decodr - decodes address to chip select in the SYSTEM for accessing I/O