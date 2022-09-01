module mux_ulaB(
    input wire [31:0] Data_0, // 1 entrada
    input wire [27:0] Data_1, // 2 entrada 

    output wire [31:0] Data_out // saida 
);

    assign Data_out = {Data_0[31:28], Data_1};

endmodule