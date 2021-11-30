class axi_lite_cnt_sequence extends axi_lite_sequence;
    `uvm_object_utils(axi_lite_cnt_sequence)
    function new (string name = "");
        super.new(name);
    endfunction
    
    extern task body();
    extern task read_reg(int unsigned addr);
    extern task wrtie_reg(int unsigned data, int unsigned addr);
    
    int unsigned value_width;
    int unsigned value_cycles;

endclass

task axi_lite_cnt_sequence::body();
    int counter = 0;

    // set enable signal
    wrtie_reg(1, 0);
    read_reg(0);
   
    repeat(value_cycles) begin
        for (int n = 0; n < 2**value_width; n++) begin
            wrtie_reg(n, 1);
            read_reg(0);
            read_reg(1);
        end
    end
endtask

task axi_lite_cnt_sequence::read_reg(int unsigned addr);
    axi_lite_data_h = axi_lite_data::type_id::create("axi_lite_data_h");
    start_item(axi_lite_data_h);
        config_item();
        assert(axi_lite_data_h.randomize());
        axi_lite_data_h.data = '0;
        axi_lite_data_h.addr = addr;
        axi_lite_data_h.strb = 4'b1111;
        axi_lite_data_h.transaction_type = 1'b0;
    finish_item(axi_lite_data_h);
endtask

task axi_lite_cnt_sequence::write_reg(int unsigned data, int unsigned addr);
    axi_lite_data_h = axi_lite_data::type_id::create("axi_lite_data_h");
    start_item(axi_lite_data_h);
        config_item();
        assert(axi_lite_data_h.randomize());
        axi_lite_data_h.data = data;
        axi_lite_data_h.addr = addr;
        axi_lite_data_h.strb = 4'b1111;
        axi_lite_data_h.transaction_type = 1'b1;
    finish_item(axi_lite_data_h);
endtask