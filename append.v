module append (
    input wire write,
    input wire [31:0] data_0,
    input wire [25:0] data_1,
    output reg [31:0] data_out
    );


wire [31:0] w1 = {data_0[31:27], data_1[24:0], 2'd0};

assign data_out = {write?w1:data_out};

endmodule
