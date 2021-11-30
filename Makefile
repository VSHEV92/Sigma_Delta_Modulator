sigma_delta_core: AXI_Lite_UVM_Agent
	vivado -mode batch -source tcl/create_tb_project.tcl


AXI_Lite_UVM_Agent:
	git clone https://github.com/VSHEV92/AXI_Lite_UVM_Agent.git
	
clean:
	rm -Rf sigma_delta_modulator		
	rm -Rf AXI_Lite_UVM_Agent
	rm *.jou *.log *.str