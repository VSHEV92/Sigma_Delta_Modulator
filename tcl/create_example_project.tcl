# ------------------------------------------------------
# ----    Cкрипт для автоматического создания     ------
#----- демонстрационного проекта для платы ZCU102 ------
# ------------------------------------------------------

# -----------------------------------------------------------
set Project_Name ZCU102_example_project

# если проект с таким именем существует удаляем его
close_project -quiet
if { [file exists $Project_Name] != 0 } { 
	file delete -force $Project_Name
}

# создаем проект
create_project $Project_Name ./$Project_Name -part xczu9eg-ffvb1156-2-e
set_property board_part xilinx.com:zcu102:part0:3.4 [current_project]

# добавляем constraints
add_files -fileset constrs_1 -norecurse xdc/leds_pins.xdc

# добавляем каталог с ядром модулятора
set_property  ip_repo_paths  IP_Core [current_project]
update_ip_catalog

# создаем block design
create_bd_design "zcu102_example"

# добавляем и настраиваем zynq
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 zynq_ultra_ps_e_0
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {0} CONFIG.PSU__MAXIGP0__DATA_WIDTH {32} CONFIG.PSU__USE__M_AXI_GP1 {0} CONFIG.PSU__USE__M_AXI_GP2 {1}] [get_bd_cells zynq_ultra_ps_e_0]

# добавляем 8 ядер сигма-дельта модулятора
for {set n 0} {$n < 8} {incr n} {
	create_bd_cell -type ip -vlnv vshev92:user:Sigma_Delta_Modulator:1.0 Sigma_Delta_Modulator_${n}
}

# подключаем ядра сигма-дельта модулятора к zunq
for {set n 0} {$n < 8} {incr n} {
	apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_LPD} Slave /Sigma_Delta_Modulator_${n}/s_axi ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins Sigma_Delta_Modulator_${n}/s_axi]
}

# создаем выходные порты
for {set n 0} {$n < 8} {incr n} {
	make_bd_pins_external  [get_bd_pins Sigma_Delta_Modulator_${n}/sigma_delta]
	set_property name led_${n} [get_bd_ports sigma_delta_0]
}

# сохраняем block design
regenerate_bd_layout
save_bd_design
close_bd_design [get_bd_designs zcu102_example]

# создаем hdl wrapper
make_wrapper -files [get_files ZCU102_example_project/ZCU102_example_project.srcs/sources_1/bd/zcu102_example/zcu102_example.bd] -top
add_files -norecurse ZCU102_example_project/ZCU102_example_project.gen/sources_1/bd/zcu102_example/hdl/zcu102_example_wrapper.v
update_compile_order -fileset sources_1

# синтез проекта
launch_runs synth_1 -jobs 2
wait_on_run synth_1

# имплементация проекта
launch_runs impl_1 -jobs 2
wait_on_run impl_1

# создание bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1

# генерация xsa-файла
write_hw_platform -fixed -include_bit -force -file zcu102_example.xsa

