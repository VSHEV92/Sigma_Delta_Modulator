# ------------------------------------------------------
# ------ Cкрипт для автоматической упаковки ядра -------
# ------------------------------------------------------

# -----------------------------------------------------------
set Project_Name sigma_delta_modulator

# если проект с таким именем существует удаляем его
close_project -quiet
if { [file exists $Project_Name] != 0 } { 
	file delete -force $Project_Name
}

# создаем проект
create_project $Project_Name ./$Project_Name -part xcku060-ffva1156-2-e

# добавляем исходники к проекту
add_files [glob -nocomplain -- ./src_hdl/*.sv] -quiet
add_files [glob -nocomplain -- ./src_hdl/*.v] -quiet

# упаковка IP-ядра
ipx::package_project -root_dir IP_Core -vendor xilinx.com -library user -taxonomy /UserIP


# вендор и название ядра
set_property vendor vshev92 [ipx::current_core]
set_property name Sigma_Delta_Modulator [ipx::current_core]
set_property display_name {Sigma Delta Modulator} [ipx::current_core]
set_property description {Sigma Delta Modulator} [ipx::current_core]

# настройка параметра value
set_property widget {textEdit} [ipgui::get_guiparamspec -name "VALUE_WIDTH" -component [ipx::current_core] ]
set_property value_validation_type range_long [ipx::get_user_parameters VALUE_WIDTH -of_objects [ipx::current_core]]
set_property value_validation_range_minimum 8 [ipx::get_user_parameters VALUE_WIDTH -of_objects [ipx::current_core]]
set_property value_validation_range_maximum 16 [ipx::get_user_parameters VALUE_WIDTH -of_objects [ipx::current_core]]

# настройка axi интерфейса
ipx::remove_memory_map interface_aximm [ipx::current_core]
set_property name s_axi [ipx::get_bus_interfaces interface_aximm -of_objects [ipx::current_core]]
ipx::associate_bus_interfaces -busif s_axi -clock aclk [ipx::current_core]

# настройка адресного пространства
ipx::add_memory_map sigma_delta_modulator [ipx::current_core]
set_property slave_memory_map_ref sigma_delta_modulator [ipx::get_bus_interfaces s_axi -of_objects [ipx::current_core]]
ipx::add_address_block s_axi_lite [ipx::get_memory_maps sigma_delta_modulator -of_objects [ipx::current_core]]

# упаковка
update_compile_order -fileset sources_1
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project

