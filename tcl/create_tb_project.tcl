# ------------------------------------------------------
# ---- Cкрипт для автоматического создания проекта -----
# ------------------------------------------------------

# -----------------------------------------------------------
set Project_Name tb_project

# если проект с таким именем существует удаляем его
close_project -quiet
if { [file exists $Project_Name] != 0 } { 
	file delete -force $Project_Name
}

# создаем проект
create_project $Project_Name ./$Project_Name -part xcku060-ffva1156-2-e

# добавляем файлы тестового окружения к проекту
add_files -fileset sim_1 [glob -nocomplain -- ./src_tb/*.svh] -quiet
add_files -fileset sim_1 [glob -nocomplain -- ./src_tb/*.sv] -quiet
add_files -fileset sim_1 [glob -nocomplain -- ./AXI_Lite_UVM_Agent/src/*.svh] -quiet
add_files -fileset sim_1 [glob -nocomplain -- ./AXI_Lite_UVM_Agent/src/*.sv] -quiet

# добавляем репозиторий с ядром
set_property  ip_repo_paths Sigma_Delta_Modulator_1.0 [current_project]
update_ip_catalog

create_ip -name Sigma_Delta_Modulator -vendor vshev92 -library user -version 1.0 -module_name Sigma_Delta_Modulator_0
generate_target {simulation} [get_files tb_project/tb_project.srcs/sources_1/ip/Sigma_Delta_Modulator_0/Sigma_Delta_Modulator_0.xci]

# подключение uvm библиотек к проекту
set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]

start_gui