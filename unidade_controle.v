module unidade_controle( 
    input wire      clk,
    input wire    reset,// reset de entrada

    // flags da ULA
    input wire    Of, // fio de overflow
    input wire    Ng, // negacao
    input wire    Zr, // zero
    input wire    Eq, // igual
    input wire    Gt, // maior
    input wire    Lt, // menor

    input wire  [5:0]    OPCODE,

    output reg    PC_w, 
    output reg    MEM_w,
    output reg    IR_w, 
    output reg    RB_w, 
    output reg    AB_w, 

    // Controladores com mais de 1 bit
    output reg [2:0]    ULA_c,

    // Controlador pra os multiplexadores  
    output reg    M_WREG,
    output reg    M_ULAA,
    output reg  [3:0] M_ULAB,

    // controle de reset de saida
    // Controles especiais pra instrucao de reset
    // Funciona de acordo com o Clock - sincronamente com o clock
    output reg    reset_out

);

// Variaveis 
reg [2:0] COUNTER;
reg [1:0] STATE; 

// Estados principais da maquina 
parameter ST_COMMON = 2'b00;
parameter ST_ULA = 2'b01;
parameter ST_RESET = 2'b11;

// Opcode
parameter ADD = 6'b000000;
parameter ADDI = 6'b001000;
parameter RESET = 6'b111111;

// Tambem deve resetar pilha
initial begin
    reset_out = 1'b1;
end




always @(posedge clk) begin

    if (reset == 1'b1) begin // ENQUANTO reset ESTIVER PRESSIONADO
        if (STATE != ST_RESET) begin
            STATE = ST_RESET;
            reset_out = 1'b1;
        end else begin
            STATE = ST_COMMON;
            reset_out = 1'b0;
        end

        // MANTEM VALORES ZERADOS
        PC_w = 1'b0;
        MEM_w = 1'b0;
        IR_w = 1'b0;
        RB_w = 1'b0;
        AB_w = 1'b0;
        ULA_c = 3'b000;
        M_WREG = 1'b0;
        M_ULAA = 1'b0;
        M_ULAB = 2'b00;
        COUNTER = 3'b000;
    end
    
    
    
    else begin // FORA DO reset

        case (STATE)
            ST_COMMON: begin // ZERA TUDO
                PC_w = 1'b0;    
                MEM_w = 1'b0;   
                IR_w = 1'b0;    
                RB_w = 1'b0;    
                AB_w = 1'b0;
                ULA_c = 3'b000;
                M_WREG = 1'b0;  
                M_ULAA = 1'b0;  
                M_ULAB = 2'b00; 
                reset_out = 1'b0; 
                COUNTER = 0;
            end

            ST_ULA: begin
                if(COUNTER == 2'd1 & COUNTER == 2'd2 & COUNTER == 2'd3) begin //Read A e B - Seleciona mux
                    PC_w = 1'b0;
                    MEM_w = 1'b0;   
                    IR_w = 1'b0;    
                    RB_w = 1'b0;    
                    AB_w = 1'b0;
                    ULA_c = 3'b000;
                    
                    if(OPCODE == 6'd0)
                    begin
                        M_ULAB = 2'd00;

                        //case ()
                        //    2'h2:
                        //endcase
                        
                    end
                    else
                        M_ULAB = 2'd02;
                    
                    M_WREG = 1'b0;  
                    M_ULAA = 1'b1;
                    reset_out = 1'b0; 
                    COUNTER = COUNTER + 1;
                end else
                if(COUNTER == 2'd4 & COUNTER == 2'd5 & COUNTER == 2'd6) begin // write reg
                    PC_w = 1'b0;
                    MEM_w = 1'b0;   
                    IR_w = 1'b0;
                    AB_w = 1'b0;
                    ULA_c = 3'b000;
                    M_ULAA = 1'b0;
                    M_ULAB = 2'b00;
                    
                    //  -- DIRECIONAR RESULTADO DA ULA PRA [rt]
                    RB_w = 1'b1;
                    M_WREG = 3'd1;
                    //  --  --  --

                    reset_out = 1'b0; 
                    COUNTER = COUNTER + 1;
                end else
                begin   // VOLTAR PARA O ESTADO DE BUSCA E DECODIFICACAO
                    PC_w = 1'b0;
                    MEM_w = 1'b0;   
                    IR_w = 1'b0;
                    AB_w = 1'b0;
                    ULA_c = 3'b000;
                    M_ULAA = 1'b0;
                    M_ULAB = 2'b00;
                    RB_w = 1'b0;
                    M_WREG = 3'd0;

                    COUNTER = 0;
                    reset_out = 1'b0; 
                    STATE = ST_COMMON;
                end
            end



            ST_RESET: begin // FALTA RESETAR A pilha
                STATE = ST_COMMON; // estado é o comum
                PC_w = 1'b0;
                MEM_w = 1'b0; 
                IR_w = 1'b0; 
                RB_w = 1'b0;
                AB_w = 1'b0; // estou escrevendo 
                ULA_c = 3'b000;
                M_WREG = 1'b0; // vai pra 0
                M_ULAA = 1'b0; 
                M_ULAB = 2'b00; // vai pra1
                reset_out = 1'b1; 
                COUNTER = 3'b000;  
            end
        
        endcase 
    end
end


endmodule