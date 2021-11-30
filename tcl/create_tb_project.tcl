# ------------------------------------------------------
# ---- Cкрипт для автоматического создания проекта -----
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

# добавляем файлы тестового окружения к проекту
add_files -fileset sim_1 [glob -nocomplain -- ./src_tb/*.svh] -quiet
add_files -fileset sim_1 [glob -nocomplain -- ./src_tb/*.sv] -quiet
add_files -fileset sim_1 [glob -nocomplain -- ./AXI_Lite_UVM_Agent/src/*.svh] -quiet
add_files -fileset sim_1 [glob -nocomplain -- ./AXI_Lite_UVM_Agent/src/*.sv] -quiet

# подключение uvm библиотек к проекту
set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]

