
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
        output reg [5:0] can_write, // CAN_WRITE: 0-pc, 1-memoria, 2-instrucao, 3-registradores, 4- regs_AB

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
        reg [3:0] STATE;
    // 
    // Estados principais da maquina 
        parameter ST_BUSCA  = 5'd0;
        parameter ST_ULA    = 5'd1;
        parameter ST_JUMP   = 5'2d;
        parameter ST_RESET  = 5'd3;
        parameter ST_BACK   = 5'd4;
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
    can_write = 6'd0;
    COUNTER = 3'd0;
    M_ULAB = 2'd1;
    M_ULAA = 1'b0;
    STATE = ST_BUSCA;
end

assign reset_out = ((STATE != ST_RESET) & (reset == 1'b1));

always @(posedge clk) begin

    if ((reset == 1'b1) || (STATE == ST_RESET)) begin //  BOTAO RESET PRESSIONADO
        // DA 1 PULSO DE RESET PARA OS OUTROS MODULOS
            STATE = {(reset == 1'b1)?ST_RESET:ST_BUSCA};
        //
        // SAIDAS SAO MANTIDAS ZERADAS
        PC_source = 1'b0;
        can_write = 6'd0;
        M_ULAA = 1'b0;
        M_ULAB = 2'b00;
        COUNTER = 3'd0;
    end
    
    else begin // FORA DO reset


        if (STATE == ST_BUSCA)  // #0
        begin
            if (COUNTER == 0 || COUNTER == 1 || COUNTER == 2)    // BUSCA
            begin
                COUNTER = COUNTER + 1;
                Adress_source = 0;      // LE PC
                can_write = 6'b00100;   // LIBERA instr PARA ESCRITA

                // ZERA OUTRAS SAIDAS
                    PC_source = 1'b0;
                    M_ULAB = 2'd0;
                    M_ULAA = 1'b0;
                //                    
            end else if (COUNTER == 3)  // TROCA DE ESTADO
            begin
                COUNTER = 3'd0;
                case(OPCODE)
                        RESET:  STATE = ST_RESET;
                        ADDI:   STATE = ST_ULA;
                        ADD:    STATE = ST_ULA;
                        default:STATE = ST_ULA;
                endcase                    
            end
        end else
        
        if (STATE == ST_ULA)    // #1
        begin

                if(COUNTER == 0 || COUNTER == 1 || COUNTER == 2) // SELECIONA A E B
                begin       
                    COUNTER = COUNTER + 1;

                    // ZERA OUTRAS SAIDAS
                        PC_source = 1'b0;
                        can_write = 6'd0;
                    //
                    M_ULAA = 1;
                    if(OPCODE == 6'd0)    // TIPO R
                        M_ULAB = 2'd0;
                    else                // TIPO I
                        M_ULAB = 2'd2;
                        
                
                //
                end else if(COUNTER == 3) begin // DIRECIONA RESULTADO
                    COUNTER = COUNTER + 1;
                    Adress_source = 3'd1;

                    // ZERA OUTRAS SAIDAS
                        PC_source = 1'b0;
                        can_write = 6'd0;
                    //
                    M_ULAA = 1;
                    if(OPCODE==6'd0)    // TIPO R
                        M_ULAB = 2'd0;
                    else                // TIPO I
                        M_ULAB = 2'd2;
                end else if(COUNTER == 4) begin // ESCREVE RESULTADO
                    can_write = 6'b000010;
                    Adress_source = 3'd1;

                    M_ULAA = 1;
                    if(OPCODE==6'd0)    // TIPO R
                        M_ULAB = 2'd0;
                    else                // TIPO I
                        M_ULAB = 2'd2;

                    // ZERA OUTRAS SAIDAS

                    COUNTER = COUNTER + 1;
                end else if(COUNTER == 5) begin // PC + 4 CALCULADO
                    COUNTER = COUNTER + 1;
                    PC_source = 1;
                    can_write = 6'd100000;
                    // ZERA OUTRAS SAIDAS
                    //
                    M_ULAA = 1;
                    M_ULAB = 2'd1;
                end else if( COUNTER == 6) begin// PC + 4 ESCRITO
                    COUNTER = COUNTER + 1;
                    PC_source = 1;
                    can_write = 6'b000001;
                    // ZERA OUTRAS SAIDAS
                    //
                    M_ULAA = 1;
                    M_ULAB = 2'd1;
                end else begin                  // MUDA O ESTADO
                    can_write = 6'd0;
                    COUNTER = 3'd0;
                    
                    PC_source = 0;
                    STATE = ST_BUSCA;
                end
        end else

        if(STATE == ST_JUMP)    // #2
        begin
            if(COUNTER == 0 || COUNTER == 1) begin

                COUNTER = COUNTER + 1;
            end
        end else

        IF(STATE == ST_BACK)    // #4
        begin
            if(COUNTER == 0)
        end



    end
end


endmodule