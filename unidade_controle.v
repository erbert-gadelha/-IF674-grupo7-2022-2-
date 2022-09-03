
// CONTROLE  IN  -[<1>clock, <1>reset, <6>flags, <6>opcode]
// CONTROLE  OUT -[<5>writes, <1>PC_source, <1>Mem_Adress_Source, <1>mux_ULAa, <1>mux_ULAb, <1>reset]

module unidade_controle(
    // INPUTS
        input wire clk,
        input wire reset,
        input wire [5:0] flags, // FLAGS: 0-overflow, 1-negative, 2-zero, 3-less, 4-greater
        input wire [5:0] OPCODE,
    //
    // OUTPUTS
        output reg [4:0] can_write, // CAN_WRITE: 0-pc, 1-memoria, 2-instrucao, 3-registradores, 4- regs_AB
        output reg [2:0] ULA_c,     // ULA_C: operacao da ULA

        // MUTIPLEXADORES
            output reg [1:0]PC_source,
            output reg [2:0] Adress_source,
            output reg M_ULAA,
            output reg [1:0] M_ULAB,
    //
    // RESETA MODULOS
            output reg reset_out
    //
);


// DECLARACOES
    // Variaveis 
        reg [2:0] COUNTER;
        reg [1:0] STATE;
    // 
    // Estados principais da maquina 
        parameter ST_COMMON = 2'b00;
        parameter ST_ULA = 2'b01;
        parameter ST_BUSCA = 2'b10;
        parameter ST_RESET = 2'b11;
    //
    // Opcode
        parameter ADD = 6'b000000;
        parameter ADDI = 6'b001000;
        parameter RESET = 6'b111111;
    //
//

initial begin
    // Tambem deve resetar pilha
    reset_out = 1'b1;
    PC_source = 1'b0;
    can_write = 5'd0;
    COUNTER = 3'd0;
    M_ULAB = 2'd0;
    M_ULAA = 1'b0;
    ULA_c = 3'd0;
end

always @(posedge clk) begin

    if ((reset == 1'b1) || (OPCODE == reset)) begin //  BOTAO RESET PRESSIONADO
        // DA 1 PULSO DE RESET PARA OS OUTROS MODULOS
            if (STATE != ST_RESET) begin
                STATE = ST_RESET;
                reset_out = 1'b1;
            end
            else begin
                STATE = ST_BUSCA;
                reset_out = 1'b0;
            end
        // SAIDAS SAO MANTIDAS ZERADAS
        PC_source = 1'b0;
        can_write = 3'd0;
        ULA_c = 3'b000;
        M_ULAA = 1'b0;
        M_ULAB = 2'b00;
        COUNTER = 3'd0;
    end
    
    else begin // FORA DO reset

        case (STATE)
            ST_BUSCA:
                if(COUNTER < 3) begin   // BUSCA
                    Adress_source = 0;      // LE PC
                    can_write = 5'b00100;   // LIBERA instr PARA ESCRITA

                    // ZERA OUTRAS SAIDAS

                    COUNTER =  COUNTER + 1;
                end else begin
                    case(OPCODE)
                        ST_RESET:   STATE = ST_RESET;
                        ST_ULA:     STATE = ST_ULA;
                    endcase
                end

            ST_ULA:
                if(COUNTER < 2) begin       // SELECIONA A E B
                    M_ULAA = 1;
                    if(OPCODE==6'd0)    // TIPO R
                        M_ULAB = 2'd0;
                    else                // TIPO I
                        M_ULAB = 2'd2;



                    COUNTER = COUNTER + 1;
                end else if(COUNTER == 3) begin // DIRECIONA RESULTADO
                    Adress_source = 3'd1;

                    // ZERA OUTRAS SAIDAS

                    COUNTER = COUNTER + 1;
                end else if(COUNTER == 3) begin // ESCREVE RESULTADO
                    can_write = 5'd01000;

                    // ZERA OUTRAS SAIDAS

                    COUNTER = COUNTER + 1;
                end else if(COUNTER < 5) begin
                    M_ULAA = 1;
                    M_ULAB = 2'd1;
                    PC_source = 0;
                    can_write = 5'd10000;

                    // ZERA OUTRAS SAIDAS

                    COUNTER = COUNTER + 1;
                end else begin
                    can_write = 5'd00000;
                    M_ULAA = 1;
                    M_ULAB = 2'd1;
                    PC_source = 0;

                end



        endcase

    end
end


endmodule