module ula_control (
    input wire clock,
    input wire [31:16] opcode,
    input wire [15:0] funct,
    output reg [2:0] seletor
);


always@ (opcode or funct) begin
    //SE OPCODE == 0
    if(opcode == 16'd0) begin
        
    end
    else begin

    end

end

endmodule