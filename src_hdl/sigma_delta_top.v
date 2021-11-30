//! IP-ядро сигма-дульта модулятора
//!
//! **РЕГИСТРЫ**
//!
//! Enable - регистр включения IP-ядра
//! { reg: [
//!     { bits: 1, name: "en"},
//!     { bits: 31, name: "unused"},
//! ] } 

//! Value - входное значение для модулятора (от 8 до 16 бит)
//! { reg: [
//!     { bits: 8, name: "used"},
//!     { bits: 8, name: "may be used"},
//!     { bits: 16, name: "unused"},
//! ] } 

module sigma_delta_top
#(
    parameter VALUE_WIDTH = 8 //! ширина входных данных модулятора
)(
    //! тактовый сигнал
    input aclk, 
    //! сигнал сброса
    input aresetn, 

    //! @virtualbus awrite @dir in
    input  [31:0] awaddr,
    input  [2:0] awprot,  
    input  awvalid,       
    output awready, //! @end    
    
    //! @virtualbus write @dir in
    input  [31:0] wdata,
    input  [3:0] wstrb, 
    input  wvalid,
    output wready, //! @end   
    
    //! @virtualbus bresp @dir out
    output [1:0] bresp, 
    output bvalid,
    input  bready, //! @end  
    
    //! @virtualbus aread @dir in
    input  [31:0] araddr,
    input  [2:0] arprot,
    input  arvalid,
    output arready, //! @end 
    
    //! @virtualbus read @dir out
    output [31:0] rdata,
    output [1:0] rresp, 
    output rvalid,
    input  rready, //! @end 
    
    //! выходное сигнал модулятора 
    output sigma_delta 
);
    wire [31:0] value;
    wire enable;

    //! блок управления регистрами
    reg_control reg_control_inst
    (
        .aclk(aclk), 
        .aresetn(aresetn), 
        .awaddr(awaddr),
        .awprot(awprot),  
        .awvalid(awvalid),       
        .awready(awready),    
        .wdata(wdata),
        .wstrb(wstrb), 
        .wvalid(wvalid),
        .wready(wready),   
        .bresp(bresp), 
        .bvalid(bvalid),
        .bready(bready),  
        .araddr(araddr),
        .arprot(arprot),
        .arvalid(arvalid),
        .arready(arready), 
        .rdata(rdata),
        .rresp(rresp), 
        .rvalid(rvalid),
        .rready(rready), 
        .enable(enable),
        .value(value) 
    );

    //! сигма дельта модулятор
    sigma_delta_core 
    #(
        .VALUE_WIDTH(VALUE_WIDTH)
    )
    sigma_delta_core_inst
    (
        .clk(aclk),
        .enable(enable),
        .value(value),
        .sigma_delta(sigma_delta)
    );

endmodule