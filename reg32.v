module reg32 (
    input write,
    input reset,
    input wire [31:0] data_in,
    output wire [31:0] data_out
    );

    reg [31:0] data;
    assign data = {reset?0:{ write ? data_in:data}};
    assign data_out = data;
 
endmodule
