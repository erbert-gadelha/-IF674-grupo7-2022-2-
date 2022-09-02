
module sign_extend_16 (
    input wire [15:0] Data_in,
    output wire [31:0] Data_out
);

    // PREENCHE OS PRIMEIROS 16 BITS COM O MAIS SIGNIFICATIVO DE data_in E O CONCATENA COM data_in
    assign Data_out = (Data_in[15]) ? {{16{1'b1}} , Data_in} : {{16{0'b0}} , Data_in};
    
endmodule