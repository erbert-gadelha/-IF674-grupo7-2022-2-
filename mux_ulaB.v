module mux_ulaB(
    input wire [2:0] selector, // pra selecionar
    input wire [31:0] Data_0, // 1 entrada
    input wire [31:0] Data_1, // 2 entrada 

    output wire [31:0] Data_out // saida 

);
// Eu vou ter 3 entradas
// 2 bit seletores pra fazer 4 selecoes
/*
Data 0 - |
4      - |  -| meu A1 seleciona do 4 ao Data0
Data1 --------| - 
*/
    wire [31:0] A1; // cria o fio do A1 pra pegar o 4 e o Data 0 

    // fez a seleção instantanea - se V eh 4 em binario ou decimal, se F eh data0 
    // em binario 32'b0000000000000000000000000000100
    // em decimal 32'd4
    assign A1 = (selector[0]) ? 32'd4 : Data_0;
    // vai selecionar o bit mais a esquerda 
    assign Data_out = (selector[1]) ? Data_1 : A1;
endmodule