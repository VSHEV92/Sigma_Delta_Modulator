class base_test extends uvm_test;

    `uvm_component_utils(base_test)
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern task shutdown_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    
    axi_lite_cnt_sequence axi_lite_seqc;
    
    axi_lite_cnt_sequence_config axi_lite_seqc_config;

    test_env test_env_h; 

    int unsigned value_width;
    int unsigned value_cycles;
    
endclass

// --------------------------------------------------------------------
function void base_test::build_phase(uvm_phase phase);

    // getting value width
    if (!uvm_config_db #(int unsigned)::get(this, "", "value_width", value_width))
        `uvm_fatal("GET_DB", "Can not get value_width")

    // getting value cycles
    if (!uvm_config_db #(int unsigned)::get(this, "", "value_cycles", value_cycles))
        `uvm_fatal("GET_DB", "Can not get value_cycles")

    axi_lite_seqc = axi_lite_cnt_sequence::type_id::create("axi_lite_seqc", this);
    
    axi_lite_seqc_config = axi_lite_cnt_sequence_config::type_id::create("axi_lite_seqc_config");
    
    axi_lite_seqc.axi_lite_seqc_config = axi_lite_seqc_config;

    axi_lite_seqc_config.value_width = value_width;
    axi_lite_seqc_config.value_cycles = value_cycles;

    axi_lite_seqc_config.max_clocks_before_addr = (2**value_width)*4 + 5;
    axi_lite_seqc_config.min_clocks_before_addr = (2**value_width)*4 - 100;
    axi_lite_seqc_config.max_clocks_before_data = (2**value_width)*4 + 20;
    axi_lite_seqc_config.min_clocks_before_data = (2**value_width)*4 - 5;
    axi_lite_seqc_config.max_clocks_before_resp = 5;
    axi_lite_seqc_config.min_clocks_before_resp = 0;
    
    test_env_h = test_env::type_id::create("test_env_h", this);  
     
endfunction

task base_test::shutdown_phase(uvm_phase phase);
    phase.raise_objection(this);
        #1000;    
    phase.drop_objection(this);
endtask

task master_test::main_phase(uvm_phase phase);
    phase.raise_objection(this);
        axi_lite_seqc.start(test_env_h.axi_lite_agent_h.axi_lite_sequencer_h);
    phase.drop_objection(this);
endtask