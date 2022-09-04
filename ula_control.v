//  ALU_CONTROL [<1>clock, <8>opcode, <6>func, <3>sel]
module ula_control (
    input wire clock,
    input wire sum,
    input wire [31:26] opcode,
    input wire [15:0] funct,
    output reg [2:0] seletor
);


always@ (opcode or funct)
begin

    // DEVE SER ATIVA QUANDO PC+4
    if(sum) begin
        seletor = 3'b001;
    end
    
    else begin
        //SE OPCODE == 0
        case (opcode)
            6'h0:   //Tipo R
            case (funct[5:0])
                6'h20: seletor = 3'b001; //add
                6'h24: seletor = 3'b011; //and
                6'h10: seletor = 3'b000; //jr
                6'h2:  seletor = 3'b010; //sub
                6'h22: seletor = 3'b001; //break
                6'hd:  seletor = 3'b001; //Rte
                // 6'd13: 3'b001 //Push
                // 6'd5:  3'b001 //Pop
            endcase
        default:
            case(opcode)
                6'h08:  seletor = 3'b001;  // adddi -  Tipo I incremento de A
                6'h09:  seletor = 3'b001;  // addiu -  Tipo I incremento de A
                6'h04:  seletor = 3'b011;  // beq   -  Tipo I and logico
                6'h05:  seletor = 3'b111;  // bne   -  Tipo I comparação
                6'h06:  seletor = 3'b111;  // ble   -  Tipo I comparação
                6'h07:  seletor = 3'b111;  // bgt   -  Tipo I comparação
                6'h020: seletor = 3'b000;  // lb    -  Tipo I
                6'h021: seletor = 3'b000;  // lh    -  Tipo I
                6'hf:   seletor = 3'b000;  // lui   -  Tipo I
                6'h23:  seletor = 3'b000;  // lw    -  Tipo I
                6'h28:  seletor = 3'b000;  // sb    -  Tipo I
                6'h29:  seletor = 3'b000;  // sh    -  Tipo I
                6'h0a:  seletor = 3'b111;  // slti  -  Tipo I
                6'h2b:  seletor = 3'b000;  // sw    -  Tipo I
            endcase
        endcase
    end
end

endmodule