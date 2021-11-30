class test_env extends uvm_env;
    `uvm_component_utils(test_env)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    extern function void build_phase(uvm_phase phase);

    virtual axi_lite_if axi_lite;
    
    axi_lite_agent axi_lite_agent_h;
    
endclass

function void test_env::build_phase(uvm_phase phase);
    
    // getting interfaces from a database
    if (!uvm_config_db #(virtual axi_lite_if)::get(this, "", "axi_lite", axi_lite))
        `uvm_fatal("GET_DB", "Can not get axi_lite interface")
       
    // create agents
    axi_lite_agent_h = axi_lite_agent::type_id::create("axi_lite_agent_h", this);
    
    // set agent's types
    axi_lite_agent_h.agent_type = MASTER;
    
    // connect interfaces
    axi_lite_agent_h.axi_lite_if_h = this.axi_lite;
    
endfunction
