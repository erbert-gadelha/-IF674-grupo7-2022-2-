module mux2
(
    input  wire sel,
    input  wire [31:0]A,
    input  wire [31:0]B,
    output wire [31:0]O
);


assign O = {sel?B:A};
endmodule
