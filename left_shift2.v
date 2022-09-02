module left_shift2 (
    input wire [31:0] data_in,
    output wire [31:0] data_out
    );

assign data_out = {data_in[29:0], 2'b00};

endmodule
