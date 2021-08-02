transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:\Users\david\Desktop\arch\lab5\ex4 - MIPS Architecture (ModelSim  Quartus)\MIPS ModelSim\VHDL_DUT\MIPS.vhd}
vcom -93 -work work {C:\Users\david\Desktop\arch\lab5\ex4 - MIPS Architecture (ModelSim  Quartus)\MIPS ModelSim\VHDL_DUT\IFETCH.VHD}
vcom -93 -work work {C:\Users\david\Desktop\arch\lab5\ex4 - MIPS Architecture (ModelSim  Quartus)\MIPS ModelSim\VHDL_DUT\IDECODE.VHD}
vcom -93 -work work {C:\Users\david\Desktop\arch\lab5\ex4 - MIPS Architecture (ModelSim  Quartus)\MIPS ModelSim\VHDL_DUT\EXECUTE.VHD}
vcom -93 -work work {C:\Users\david\Desktop\arch\lab5\ex4 - MIPS Architecture (ModelSim  Quartus)\MIPS ModelSim\VHDL_DUT\DMEMORY.VHD}
vcom -93 -work work {C:\Users\david\Desktop\arch\lab5\ex4 - MIPS Architecture (ModelSim  Quartus)\MIPS ModelSim\VHDL_DUT\CONTROL.VHD}

vcom -93 -work work {C:\Users\david\Desktop\arch\lab5\ex4 - MIPS Architecture (ModelSim  Quartus)\MIPS ModelSim\VHDL_tb\mips_tester_struct.vhd}
vcom -93 -work work {C:\Users\david\Desktop\arch\lab5\ex4 - MIPS Architecture (ModelSim  Quartus)\MIPS ModelSim\VHDL_tb\mips_tb_struct.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneii -L rtl_work -L work -voptargs="+acc"  MIPS_tb

add wave *
view structure
view signals
run 20 us
