class axi_lite_cnt_sequence_config extends axi_lite_sequence_config;
    
    `uvm_object_utils(axi_lite_cnt_sequence_config)
    function new (string name = "");
        super.new(name);
    endfunction
    
    int unsigned value_width = 8;
    int unsigned value_cycles = 5;
endclass