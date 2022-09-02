module mux_writereg(
    
    input wire [1:0] selector,
    input wire [4:0] Data_0,// primeira entrada de dados - RT - 4 bits 
    input wire [15:0] Data_1, // segunda entrada de dados - 16 bits - IMEDIATO 
    output wire [4:0]  Data_out // saida - reg do banco de reg - só tem 5 bits
); 
    // se for verdade eh so a parte do rd do data1 - diz os bits 
    // Só vou querer uma parte do sinal
    assign Data_out = (selector) ? Data_1[15:11] : Data_0;


endmodule