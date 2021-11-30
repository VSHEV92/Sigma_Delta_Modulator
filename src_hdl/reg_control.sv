`define REGS_NUMBER     2     // число регистров
`define ENABLE_REG_ADDR 32'h0 // адрес регистра включения ядра 
`define VALUE_REG_ADDR  32'h4 // адрес регистра входного значения ядра

//! Модуль, реализующий блок управления регистрами
//!
//! **РЕГИСТРЫ**
//!
//! Enable
//! { reg: [
//!     { bits: 1, name: "en"},
//!     { bits: 31, name: "unused"},
//! ] } 

//! Value 
//! { reg: [
//!     { bits: 8, name: "used"},
//!     { bits: 8, name: "may be used"},
//!     { bits: 16, name: "unused"},
//! ] } 

module reg_control(
    //! тактовый сигнал
    input logic aclk,; 
    //! сигнал сброса
    input logic aresetn,; 

    //! @virtualbus awrite @dir in
    input  logic [31:0] awaddr,
    input  logic [2:0] awprot,  
    input  logic awvalid,       
    output logic awready, //! @end    
    
    //! @virtualbus write @dir in
    input  logic [31:0] wdata,
    input  logic [3:0] wstrb, 
    input  logic wvalid,
    output logic wready, //! @end   
    
    //! @virtualbus bresp @dir out
    output logic [1:0] bresp, 
    output logic bvalid,
    input  logic bready, //! @end  
    
    //! @virtualbus aread @dir in
    input  logic [31:0] araddr,
    input  logic [2:0] arprot,
    input  logic arvalid,
    output logic arready, //! @end 
    
    //! @virtualbus read @dir out
    output logic [31:0] rdata,
    output logic [1:0] rresp, 
    output logic rvalid,
    input  logic rready, //! @end 
    
    //! 0 - выкл, 1 - вкл.
    output logic enable,
    //! входное значение для модулятора 
    output logic [31:0] value 
);
    
    // -----------------------------------------------------------------------------------------------------------
    
    //! массив адресов регистров
    localparam logic [31:0] regs_addr [`REGS_NUMBER] = '{`ENABLE_REG_ADDR, `VALUE_REG_ADDR};
    //! массив значений регистров
    logic [31:0] regs_data [`REGS_NUMBER];
    //! флаг, пренадлежности адреса записи к пространству регистров
    logic good_waddr;
    //! флаг, пренадлежности адреса чтения к пространству регистров
    logic good_raddr;
    //! внутренние регистры для адресов и данных
    logic [31:0] waddr_reg, wdata_reg, raddr_reg;
    //! флаги записи внутренних регистров
    logic update_regs_data;

    //! WAIT_WR_TRANS - ожидание начала транзакции записи
    //! WAIT_ADDR - данные получены, ожидание адреса
    //! WAIT_DATA - получен корректный адрес, ожидание данных
    //! WAIT_DATA_BAD - получен некорректный адрес, ожидание данных
    //! SEND_RESP - успешная запись данных
    //! SEND_RESP_BAD - неуспешная запись данных
    enum {WAIT_WR_TRANS, WAIT_ADDR, WAIT_DATA, SEND_RESP, WAIT_DATA_BAD, SEND_RESP_BAD} write_state;

    //! WAIT_RD_TRANS - ожидание начала транзакции чтения
    //! CHECK_ADDR - проверка корректности адреса
    //! SEND_DATA - успешная выдача данных
    //! SEND_DATA_BAD - неуспешная выдача данных
    enum {WAIT_RD_TRANS, CHECK_ADDR, SEND_DATA, SEND_DATA_BAD} read_state;

    // -----------------------------------------------------------------------------------------------------------
    
    //! формирование выходных сигналов управления
    assign enable = regs_data[0][0];
    assign value = regs_data[1];

    // -----------------------------------------------------------------------------------------------------------

    //! вычисление корректности адреса записи
    always_comb begin : Check_Write_Addr
        good_waddr = 1'b0;
        for (int n = 0; n < `REGS_NUMBER; n++)
            if (awaddr == regs_addr[n])
                good_waddr = 1'b1;
    end : Check_Write_Addr 

    //! вычисление корректности адреса чтения
    always_comb begin : Check_Read_Addr
        good_raddr = 1'b0;
        for (int n = 0; n < `REGS_NUMBER; n++)
            if (raddr_reg == regs_addr[n])
                good_raddr = 1'b1;
    end : Check_Read_Addr 

    // -----------------------------------------------------------------------------------------------------------

    //! конченый автомат записи данных (write_state)   
    always_ff@(posedge aclk) begin : Write_FSM
        if (!aresetn)
            write_state <= WAIT_WR_TRANS;
        else
            unique case (write_state)
            WAIT_WR_TRANS: begin
                if (awvalid && wvalid && good_waddr)
                    write_state <= SEND_RESP;
                if (awvalid && wvalid && !good_waddr)
                    write_state <= SEND_RESP_BAD;
                if (awvalid && good_waddr)
                    write_state <= WAIT_DATA;
                if (awvalid && !good_waddr)
                    write_state <= WAIT_DATA_BAD;
                if (wvalid)    
                    write_state <= WAIT_ADDR;
            end
            WAIT_ADDR: begin
                if (awvalid && good_waddr)
                    write_state <= SEND_RESP;
                if (awvalid && !good_waddr)
                    write_state <= SEND_RESP_BAD;
            end
            WAIT_DATA: begin
                if (wvalid)    
                    write_state <= SEND_RESP;
            end
            WAIT_DATA_BAD: begin
                if (wvalid)    
                    write_state <= SEND_RESP_BAD;
            end
            SEND_RESP: begin
                if (bready)    
                    write_state <= WAIT_WR_TRANS;
            end
            SEND_RESP_BAD: begin
                if (bready)    
                    write_state <= WAIT_WR_TRANS;
            end          
            endcase            
    end : Write_FSM

    //! выходные сигналы автомата записи (write_state)   
    always_comb begin : Write_FSM_Outputs
        unique case (write_state)
        WAIT_WR_TRANS: begin
            update_regs_data = 1'b0;
            awready = 1'b1;
            wready = 1'b1;
            bresp = 2'b00;
            bvalid = 1'b0;
        end
        WAIT_ADDR: begin
            update_regs_data = 1'b0;
            awready = 1'b1;
            wready = 1'b0;
            bresp = 2'b00;
            bvalid = 1'b0; 
        end
        WAIT_DATA || WAIT_DATA_BAD: begin
            update_regs_data = 1'b0;
            awready = 1'b0;
            wready = 1'b1;
            bresp = 2'b00;
            bvalid = 1'b0; 
        end
        SEND_RESP: begin
            update_regs_data = 1'b1;
            awready = 1'b0;
            wready = 1'b0;
            bresp = 2'b00;
            bvalid = 1'b1;    
        end
        SEND_RESP_BAD: begin
            update_regs_data = 1'b0;
            awready = 1'b0;
            wready = 1'b0;
            bresp = 2'b10;
            bvalid = 1'b1;
        end          
        endcase      
    end : Write_FSM_Outputs

    //! запись временного регистра адреса
    always_ff@(posedge aclk) begin : Save_waddr_reg
        if (awvalid && awready)
            waddr_reg <= awaddr;    
    end : Save_waddr_reg
    
    //! запись временного регистра данных
    always_ff@(posedge aclk) begin : Save_wdata_reg
        if (wvalid && wready)
            wdata_reg <= wdata;    
    end : Save_wdata_reg
    
    //! запись обновление регистров новыми данными
    always_ff@(posedge aclk) begin : Updata_regs_data
        if (update_regs_data)
            for (int n = 0; n < `REGS_NUMBER; n++) begin
                if (waddr_reg == regs_addr[n])
                    regs_data[n] <= wdata_reg;
            end
    end : Updata_regs_data
    
    // -----------------------------------------------------------------------------------------------------------

    //! конченый автомат чтения данных (read_state) 
    always_ff@(posedge aclk) begin : Read_FSM
        if (!aresetn)
            read_state <= WAIT_WR_TRANS;
        else
            unique case (read_state)
            WAIT_RD_TRANS: begin
                if (arvalid)
                    read_state <= CHECK_ADDR;
            end
            CHECK_ADDR: begin
                if (good_raddr)
                    read_state <= SEND_DATA;
                else
                    read_state <= SEND_DATA_BAD;    
            end  
            SEND_DATA: begin
                if (rready)
                    read_state <= WAIT_RD_TRANS;
            end  
            SEND_DATA_BAD: begin
                if (rready)
                    read_state <= WAIT_RD_TRANS;
            end            
            endcase
    end : Read_FSM
    
    //! выходные сигналы автомата чтения (read_state)   
    always_comb begin : Read_FSM_Outputs
        unique case (read_state)
        WAIT_RD_TRANS: begin
            arready = 1'b1;
            rvalid = 1'b0;
            rresp = 2'b00;
        end
        CHECK_ADDR: begin
            arready = 1'b0;
            rvalid = 1'b0;
            rresp = 2'b00;
        end  
        SEND_DATA: begin
            arready = 1'b0;
            rvalid = 1'b1;
            rresp = 2'b00;
        end  
        SEND_DATA_BAD: begin
            arready = 1'b0;
            rvalid = 1'b1;
            rresp = 2'b10;
        end            
        endcase   
    end : Read_FSM_Outputs

    //! запись временного регистра адреса
    always_ff@(posedge aclk) begin : Save_raddr_reg
        if (arvalid && arready)
            raddr_reg <= araddr;    
    end : Save_raddr_reg
    
    //! получение считываемого значения
    always_ff@(posedge aclk) begin : Get_read_data
        if (good_raddr)
            for (int n = 0; n < `REGS_NUMBER; n++) begin
                if (raddr_reg == regs_addr[n])
                    rdata <= regs_data[n];
            end
    end : Get_read_data
    
endmodule