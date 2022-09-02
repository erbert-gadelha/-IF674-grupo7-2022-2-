module mux_4
(
    input wire [1:0]seletor,
    input wire [31:0] a0,
    input wire [31:0] a1,
    input wire [31:0] a2,
    input wire [31:0] a3,
    
    input wire [31:0] out
);

wire [31:0] w0, w1, w2, w3, w4, w5;
assign w0 = {seletor[0]?a1:a0};
assign w1 = {seletor[0]?a3:a2};

assign out = {seletor[1]?w1:w0};

endmodule
