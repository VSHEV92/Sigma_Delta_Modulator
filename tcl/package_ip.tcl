# ------------------------------------------------------
# ------ Cкрипт для автоматической упаковки ядра -------
# ------------------------------------------------------

# -----------------------------------------------------------
set Project_Name temp_project

# создаем временный проект проект
create_project $Project_Name ./$Project_Name -part xcku060-ffva1156-2-e

# настраиваем AXI-интерфейс
create_peripheral user.org user Sigma_Delta_Modulator 1.0 -dir .
add_peripheral_interface S_AXI -interface_mode slave -axi_type lite [ipx::find_open_core user.org:user:Sigma_Delta_Modulator:1.0]
generate_peripheral -driver -bfm_example_design -debug_hw_example_design [ipx::find_open_core user.org:user:Sigma_Delta_Modulator:1.0]
write_peripheral [ipx::find_open_core user.org:user:Sigma_Delta_Modulator:1.0]
set_property  ip_repo_paths  Sigma_Delta_Modulator_1.0 [current_project]
update_ip_catalog -rebuild
ipx::edit_ip_in_project -upgrade true -name edit_Sigma_Delta_Modulator_v1_0 -directory . Sigma_Delta_Modulator_1.0/component.xml
set_property vendor vshev92 [ipx::current_core]

# удаляем автоматически сгенерированные файлы
export_ip_user_files -of_objects  [get_files Sigma_Delta_Modulator_1.0/hdl/Sigma_Delta_Modulator_v1_0.v] -no_script -reset -force -quiet
export_ip_user_files -of_objects  [get_files Sigma_Delta_Modulator_1.0/hdl/Sigma_Delta_Modulator_v1_0_S_AXI.v] -no_script -reset -force -quiet
remove_files  {Sigma_Delta_Modulator_1.0/hdl/Sigma_Delta_Modulator_v1_0.v Sigma_Delta_Modulator_1.0/hdl/Sigma_Delta_Modulator_v1_0_S_AXI.v}

# добавляем файлы исходников
add_files -norecurse -copy_to Sigma_Delta_Modulator_1.0/src {src_hdl/Sigma_Delta_Modulator_v1_0_S_AXI.v src_hdl/Sigma_Delta_Modulator_v1_0.v}
add_files -norecurse -copy_to Sigma_Delta_Modulator_1.0/src src_hdl/sigma_delta_core.sv
update_compile_order -fileset sources_1
ipx::merge_project_changes files [ipx::current_core]

# настраиваем параметры
ipx::merge_project_changes hdl_parameters [ipx::current_core]
ipgui::add_param -name {VALUE_WIDTH} -component [ipx::current_core] -display_name {Value Width} -show_label {true} -show_range {true} -widget {}
ipgui::move_param -component [ipx::current_core] -order 0 [ipgui::get_guiparamspec -name "VALUE_WIDTH" -component [ipx::current_core]] -parent [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core]]

# пакуем ядро
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property previous_version_for_upgrade user.org:user:Sigma_Delta_Modulator:1.0 [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete

# удаляем временный проект
close_project -delete
