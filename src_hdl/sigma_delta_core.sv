//! Модуль, реализующий сигма-дельта модулятор 
module sigma_delta_core
#(
    parameter VALUE_WIDTH = 8 //! ширина входных данных модулятора
)
(
    input  logic clk,                     //! тактовый сигнал
    input  logic enable,                  //! сигнал вкдючения модулятора 
    input  logic [VALUE_WIDTH-1:0] value, //! входные данные модулятора
    output logic sigma_delta              //! выходной сигнал
 );
    //! нулевой значение
    localparam [VALUE_WIDTH-1:0] ZEROS = '0; 
    //! единичное значение
    localparam [VALUE_WIDTH-1:0] ONES = '1; 
    //! пороговое значение для блок сравнения
    localparam [VALUE_WIDTH-1:0] THRESH_VALUE = ONES/2; 
    
    //! выход интегратора
    logic signed [VALUE_WIDTH+1:0] accum_value; 

    //! алгоритм работы модулятора
     always_ff@(posedge clk) begin : modulator
        if (!enable)
            accum_value <= '0;
        else
            if (sigma_delta)    
                accum_value <= accum_value + value - ONES;
            else     
                accum_value <= accum_value + value - ZEROS;
    end

    //! формирование выходного сигнала
    assign sigma_delta = (accum_value > signed'(THRESH_VALUE)) ? 1'b1 : 1'b0;
    
endmodule