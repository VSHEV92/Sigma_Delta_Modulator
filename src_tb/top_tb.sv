`timescale 1ns/1ps
module top_tb ();

    import uvm_pkg::*;
    import test_pkg::*; 

    localparam int unsigned VALUE_WIDTH = 8;                   //! ширина входных данных модулятора
    localparam int unsigned CYCLE_NUMBER = 5;                  //! число циклов изменения значения value
    localparam int unsigned CLK_PERIOD = 10;                   //! период тактового сигнала

    bit aclk = 0;
    bit sigma_delta;
    int unsigned acc_value = 0, final_value = 0;  

    axi_lite_if axi_lite (aclk);
    
    always
        #(CLK_PERIOD/2) aclk = ~aclk;

    Sigma_Delta_Modulator_0 dut
    (
        .s_axi_araddr  (axi_lite.araddr),
        .s_axi_arprot  (axi_lite.arprot),
        .s_axi_arready (axi_lite.arready),
        .s_axi_arvalid (axi_lite.arvalid),

        .s_axi_awaddr  (axi_lite.awaddr),
        .s_axi_awprot  (axi_lite.awprot),
        .s_axi_awvalid (axi_lite.awvalid),
        .s_axi_awready (axi_lite.awready),

        .s_axi_bready  (axi_lite.bready),
        .s_axi_bresp   (axi_lite.bresp),
        .s_axi_bvalid  (axi_lite.bvalid),

        .s_axi_rdata   (axi_lite.rdata),
        .s_axi_rresp   (axi_lite.rresp),
        .s_axi_rready  (axi_lite.rready),
        .s_axi_rvalid  (axi_lite.rvalid),

        .s_axi_wdata   (axi_lite.wdata),
        .s_axi_wready  (axi_lite.wready),
        .s_axi_wstrb   (axi_lite.wstrb),
        .s_axi_wvalid  (axi_lite.wvalid),

        .s_axi_aclk    (aclk),
        .s_axi_aresetn (axi_lite.aresetn),
        
        .sigma_delta (sigma_delta)
    );

    initial begin
        uvm_config_db #(virtual axi_lite_if)::set(null, "", "axi_lite", axi_lite);
        uvm_config_db #(int unsigned)::set(null, "", "value_width", VALUE_WIDTH);
        uvm_config_db #(int unsigned)::set(null, "", "value_cycles", CYCLE_NUMBER);
        run_test("base_test");
    end

    always begin
        wait(axi_lite.aresetn);
        for (int m = 0; m < 2**VALUE_WIDTH; m++) begin
            acc_value += sigma_delta;
            @(posedge aclk); 
        end
        final_value  = acc_value;
        acc_value  = 0;
    end
endmodule