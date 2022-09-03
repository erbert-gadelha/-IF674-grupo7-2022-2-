
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

        // MUTIPLEXADORES
            output reg [1:0]PC_source,
            output reg [2:0] Adress_source,
            output reg M_ULAA,
            output reg [1:0] M_ULAB,
    //
    // RESETA MODULOS
            output wire reset_out
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
    Adress_source = 3'd0;
    PC_source = 1'b0;
    can_write = 5'd0;
    COUNTER = 3'd0;
    M_ULAB = 2'd0;
    M_ULAA = 1'b0;
    STATE = ST_RESET;
end

assign reset_out = ((STATE != ST_RESET) & (reset == 1'b1));

always @(posedge clk) begin

    if ((reset == 1'b1) || (STATE == ST_RESET)) begin //  BOTAO RESET PRESSIONADO
        // DA 1 PULSO DE RESET PARA OS OUTROS MODULOS
            STATE = {(reset == 1'b1)?ST_RESET:ST_BUSCA};
        //
        // SAIDAS SAO MANTIDAS ZERADAS
        PC_source = 1'b0;
        can_write = 5'd0;
        M_ULAA = 1'b0;
        M_ULAB = 2'b00;
        COUNTER = 3'd0;
    end
    
    else begin // FORA DO reset

        case (STATE)
            ST_BUSCA:
            begin
                if(COUNTER < 3) begin   // BUSCA
                    Adress_source = 0;      // LE PC
                    can_write = 5'b00100;   // LIBERA instr PARA ESCRITA

                    // ZERA OUTRAS SAIDAS
                        PC_source = 1'b0;
                        M_ULAB = 2'd0;
                        M_ULAA = 1'b0;
                    //

                    COUNTER =  COUNTER + 1;
                end else begin
                    case(OPCODE)
                        RESET:   begin STATE = ST_RESET;end
                        ADD:     begin STATE = ST_ULA;end
                        ADDI:     begin STATE = ST_ULA;end
                        // DEFAULT
                        //STATE = ST_RESET;
                    endcase

                    COUNTER = 3'd0;
                end
            end
            ST_ULA:
            begin
                if(COUNTER < 5)begin   // A + B
                    M_ULAA = 1;
                    if(OPCODE==6'd0)    // TIPO R
                        M_ULAB = 2'd0;
                    else                // TIPO I
                        M_ULAB = 2'd2;
                end else begin          // PC + 4
                    M_ULAA = 1;
                    M_ULAB = 2'd1;
                end

                if(COUNTER == 0 || COUNTER == 1 || COUNTER == 2) begin       // SELECIONA A E B


                    // ZERA OUTRAS SAIDAS
                        PC_source = 1'b0;
                        can_write = 5'd0;
                    //

                    COUNTER = COUNTER + 1;
                end else if(COUNTER == 3) begin // DIRECIONA RESULTADO
                    Adress_source = 3'd1;

                    // ZERA OUTRAS SAIDAS
                        PC_source = 1'b0;
                        can_write = 5'd0;
                    //

                    COUNTER = COUNTER + 1;
                end else if(COUNTER == 4) begin // ESCREVE RESULTADO
                    can_write = 5'b01000;
                    Adress_source = 3'd1;

                    // ZERA OUTRAS SAIDAS

                    COUNTER = COUNTER + 1;
                end else if(COUNTER == 5 || COUNTER == 6) begin // PC + 4
                    //M_ULAA = 1;
                    //M_ULAB = 2'd1;
                    PC_source = 0;
                    can_write = 5'b10000;

                    // ZERA OUTRAS SAIDAS

                    COUNTER = COUNTER + 1;
                end else begin
                    can_write = 5'd0;
                    //M_ULAA = 1;
                    //M_ULAB = 2'd1;
                    PC_source = 0;

                    STATE = ST_BUSCA;
                    COUNTER = 3'd0;
                end
            end

        endcase

    end
end


endmodule