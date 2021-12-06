Sigma_Delta_Modulator_1.0:
	vivado -mode batch -source tcl/package_ip.tcl
	cp src_baremetal/Sigma_Delta_Modulator* Sigma_Delta_Modulator_1.0/drivers/Sigma_Delta_Modulator_v1_0/src/
	rmdir temp_project

AXI_Lite_UVM_Agent:
	git clone https://github.com/VSHEV92/AXI_Lite_UVM_Agent.git

test_project: Sigma_Delta_Modulator_1.0 AXI_Lite_UVM_Agent
	vivado -mode batch -source tcl/create_tb_project.tcl

zcu102_example.xsa: Sigma_Delta_Modulator_1.0
	vivado -mode batch -source tcl/create_example_project.tcl

baremetal: zcu102_example.xsa
	xsct -eval "source tcl/create_baremetal.tcl"; 

petaproject: zcu102_example.xsa
	source /opt/Xilinx/PetaLinux/2021.1/tool/settings.sh; \
	petalinux-create --type project --template zynqMP --name petaproject; \
	cd petaproject; \
	petalinux-config --get-hw-description .. --silentconfig; \
	petalinux-create -t modules --name miscsigmadelatdriver; \
	
clean:
	rm -Rf Sigma_Delta_Modulator_1.0
	rm -Rf ZCU102_example_project
	rm -Rf AXI_Lite_UVM_Agent
	rm -Rf tb_project
	rm -Rf Packages
	rm -Rf temp_project
	rm -Rf baremetal
	rm -Rf petaproject
	rm -f *.jou *.log *.str
	rm -Rf .Xil
	rm -f zcu102_example.xsa 