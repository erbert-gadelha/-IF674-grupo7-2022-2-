module mux_8
(
    input wire [2:0]seletor,
    input wire [31:0] a0,
    input wire [31:0] a1,
    input wire [31:0] a2,
    input wire [31:0] a3,
    input wire [31:0] a4,
    input wire [31:0] a5,
    input wire [31:0] a6,
    input wire [31:0] a7,
    
    input wire [31:0] out
);

wire [31:0] w0, w1, w2, w3, w4, w5;
assign w0 = {seletor[0]?a1:a0};
assign w1 = {seletor[0]?a3:a2};
assign w2 = {seletor[0]?a5:a4};
assign w3 = {seletor[0]?a7:a6};

assign w4 = {seletor[1]?w1:w0};
assign w5 = {seletor[1]?w3:w2};

assign out = {seletor[2]?w5:w4};

endmodule
