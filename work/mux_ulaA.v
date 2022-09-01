<<<<<<< HEAD
module mux_ulaA(
    // entradas e saidas do modulo

    input wire  selector,
    input wire [31:0] Data_0,// primeira entrada de dados
    input wire [31:0] Data_1, // segunda entrada de dados
    output wire [31:0]  Data_out // saida    
);
    // Modo instantaneo pra fazer combinacoes - assing -
    // No momento que der as entradas, o resultado já sai logo.
    // Não precisa de um ciclo de clock de espera 


    // Dá o bit selector, se verdadeiro ou falso 
    // se for 1, eh Data_1, se for 0, eh Data_0
    assign Data_out = (selector) ? Data_1 : Data_0;
=======
module mux_ulaA(
    // entradas e saidas do modulo

    input wire  selector,
    input wire [31:0] Data_0,// primeira entrada de dados
    input wire [31:0] Data_1, // segunda entrada de dados
    output wire [31:0]  Data_out // saida    
);
    // Modo instantaneo pra fazer combinacoes - assing -
    // No momento que der as entradas, o resultado já sai logo.
    // Não precisa de um ciclo de clock de espera 


    // Dá o bit selector, se verdadeiro ou falso 
    // se for 1, eh Data_1, se for 0, eh Data_0
    assign Data_out = (selector) ? Data_1 : Data_0;
>>>>>>> f5c760b8f7aa2e7e7d608408ebd4e02d28ba8bb9
endmodule