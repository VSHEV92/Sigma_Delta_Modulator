Sigma_Delta_Modulator_1.0:
	vivado -mode batch -source tcl/package_ip.tcl
	cp src_baremetal/Sigma_Delta_Modulator.* Sigma_Delta_Modulator_1.0/drivers/Sigma_Delta_Modulator_v1_0/src/
	rm Sigma_Delta_Modulator_1.0/drivers/Sigma_Delta_Modulator_v1_0/src/Sigma_Delta_Modulator_selftest.c
	rmdir temp_project

AXI_Lite_UVM_Agent:
	git clone https://github.com/VSHEV92/AXI_Lite_UVM_Agent.git

test: Sigma_Delta_Modulator_1.0 AXI_Lite_UVM_Agent
	vivado -mode batch -source tcl/create_tb_project.tcl

xsa: Sigma_Delta_Modulator_1.0
	vivado -mode batch -source tcl/create_example_project.tcl

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