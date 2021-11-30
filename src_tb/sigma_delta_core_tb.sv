//! testbench для проверки модуля sigma_delta_core 
`timescale 1ns/1ps
module sigma_delta_core_tb();

    localparam VALUE_WIDTH = 8;                   //! ширина входных данных модулятора
    localparam CYCLE_NUMBER = 5;                  //! число циклов изменения значения value
    localparam VALUE_DELAY = 4*(2**VALUE_WIDTH);  //! число тактов на одно значение value
    localparam CLK_PERIOD = 10;                   //! период тактового сигнала

    bit clk;                     //! тактовый сигнал
    bit enable;                  //! сигнал вкдючения модулятора 
    bit [VALUE_WIDTH-1:0] value; //! входные данные модулятора
    bit sigma_delta;             //! выходной сигнал

    int unsigned acc_value = 0, final_value = 0;  //! интегрированное значение sigma_delta

    //! тактовый сигнал
    assign #(CLK_PERIOD/2) clk = ~clk;

    //! сигнал enable
    initial  
        #(CLK_PERIOD*10) enable = 1'b1;    

    //! сигнал value
    initial begin
        // начальная задержка
        #(CLK_PERIOD*20);

        // неколько циклов по всем значениям value
        for (int n = 0; n < CYCLE_NUMBER; n++)
            for (int m = 0; m < 2**VALUE_WIDTH; m++)
                #(CLK_PERIOD*VALUE_DELAY) value = m;
        
        // конечная задержка
        #(CLK_PERIOD*VALUE_DELAY);

        $finish;
    end
    
    //! интегрирование сигнала sigma_delta для проверки
    always begin
        wait(enable);
        for (int m = 0; m < 2**VALUE_WIDTH; m++) begin
            acc_value += sigma_delta;
            @(posedge clk); 
        end
        final_value  = acc_value;
        acc_value  = 0;
    end
    
    //! тестируемый модуль
    sigma_delta_core #(
        .VALUE_WIDTH(VALUE_WIDTH)
    )
    DUT(.*);

endmodule