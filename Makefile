Sigma_Delta_Modulator_1.0:
	vivado -mode batch -source tcl/package_ip.tcl

AXI_Lite_UVM_Agent:
	git clone https://github.com/VSHEV92/AXI_Lite_UVM_Agent.git

run_test: Sigma_Delta_Modulator_1.0 AXI_Lite_UVM_Agent
	vivado -mode batch -source tcl/create_tb_project.tcl

clean:
	rm -Rf Sigma_Delta_Modulator_1.0	 
	rm -Rf AXI_Lite_UVM_Agent
	rm *.jou *.log *.str