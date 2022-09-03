module append (
    input [31:0] pc,
    input [25:0] offset,
    output [31:0] out
    );

    assign out = {pc[31:27], offset[24:0], 2'd0};

endmodule
