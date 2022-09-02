
module sign_extend_16(
    // so vai ter 1 entrada e 1 saida
    
    input wire [15:0] Data_in,
    output wire [31:0] Data_out


);

// dizermos que o imediato tem sinal - um inteiro - o mais a esquerda
// dai extende com 1 ou com 0 a depender do primeiro bit do Data_in 
// 15 sao numeros e o mais a esquerda eh um sinal 
// pega o bit de sinal e compara - se for 1, numero negativo, cria uma saida pra extender so com 1 a esquerda 
// se for o contrario, só com 0 
// concatenar sinais usa chaves 
// o bit 1 vai se repetir 16 vezes , concatenado com o Data_in - EXTENSAO DE SINAL {{16{1'b1}} , Data_in} 
    assign Data_out = (Data_in[15]) ? {{16{1'b1}} , Data_in} : {{16{0'b0}} , Data_in};
    
endmodule