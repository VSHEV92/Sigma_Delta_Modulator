`timescale 1ns/1ps
module master_tb ();

    import uvm_pkg::*;
    import test_pkg::*; 

    localparam int unsigned VALUE_WIDTH = 8;                   //! ширина входных данных модулятора
    localparam int unsigned CYCLE_NUMBER = 5;                  //! число циклов изменения значения value
    localparam int unsigned CLK_PERIOD = 10;                   //! период тактового сигнала

    bit aclk = 0;
    bit sigma_delta;
    int unsigned acc_value = 0, final_value = 0;  

    axi_lite_if axi_lite (aclk);
    
    assign #(CLK_PERIOD/2) clk = ~clk;

    sigma_delta_top dut (
        .araddr  (axi_lite.araddr),
        .arprot  (axi_lite.arprot),
        .arready (axi_lite.arready),
        .arvalid (axi_lite.arvalid),

        .awaddr  (axi_lite.awaddr),
        .awprot  (axi_lite.awprot),
        .awvalid (axi_lite.awready),
        .awready (axi_lite.awvalid),

        .bready  (axi_lite.bready),
        .bresp   (axi_lite.bresp),
        .bvalid  (axi_lite.bvalid),

        .rdata   (axi_lite.rdata),
        .rresp   (axi_lite.rready),
        .rready  (axi_lite.rresp),
        .rvalid  (axi_lite.rvalid),

        .wdata   (axi_lite.wdata),
        .wready  (axi_lite.wready),
        .wstrb   (axi_lite.wstrb),
        .wvalid  (axi_lite.wvalid),

        .aclk    (aclk),
        .aresetn (axi_lite.aresetn),
        
        .sigma_delta (sigma_delta)
    );

    initial begin
        uvm_config_db #(virtual axi_lite_if)::set(null, "", "axi_lite", axi_lite);
        uvm_config_db #(int unsigned)::set(null, "", "value_width", VALUE_WIDTH);
        uvm_config_db #(int unsigned)::set(null, "", "value_cycles", CYCLE_NUMBER);
        run_test(base_test);
    end

    always begin
        wait(enable);
        for (int m = 0; m < 2**VALUE_WIDTH; m++) begin
            acc_value += sigma_delta;
            @(posedge clk); 
        end
        final_value  = acc_value;
        acc_value  = 0;
    end
endmodule