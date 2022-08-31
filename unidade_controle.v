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

    // Apertei o botao de reset
    if (reset == 1'b1)
    begin
      if (STATE != ST_RESET) begin
            STATE = ST_RESET;

            PC_w = 1'b0;
            MEM_w = 1'b0;
            IR_w = 1'b0;
            RB_w = 1'b0;
            AB_w = 1'b0;
            ULA_c = 3'b000;
            M_WREG = 1'b0;
            M_ULAA = 1'b0;
            M_ULAB = 2'b00;

            reset_out = 1'b1;
            COUNTER = 3'b000;
        end

        else begin
                STATE = ST_COMMON;
                
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
                COUNTER = 3'b000;
            
        end
    end


    // OUTROS ESTADOS QUE O NAO O [reset]
    else begin

        case (STATE)
            ST_COMMON:
            begin // ZERA TUDO
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

            ST_ULA:
            begin
                if(COUNTER == 2'd1) begin //Read A e B
                    PC_w = 1'b0;    
                    MEM_w = 1'b0;   
                    IR_w = 1'b0;    
                    RB_w = 1'b0;    
                    AB_w = 1'b0;    // AB?
                    ULA_c = 3'b000; // ULAcontrol? se sim pode ser passado aqui o OPCODE
                    M_WREG = 1'b0;  
                    M_ULAA = 1'b1;  
                    M_ULAB = 2'b00; 
                    reset_out = 1'b0; 
                    COUNTER = COUNTER + 1;
                end else
                if(COUNTER == 2'd2) begin //Roda ULA
                    PC_w = 1'b0;    
                    MEM_w = 1'b0;   
                    IR_w = 1'b0;    
                    RB_w = 1'b0;    
                    AB_w = 1'b0;    // AB?
                    ULA_c = 3'b000; // ULAcontrol? se sim pode ser passado aqui o OPCODE
                    M_WREG = 1'b0;  
                    M_ULAA = 1'b1;  
                    M_ULAB = 2'b00; 
                    reset_out = 1'b0; 
                    COUNTER = COUNTER + 1;
                end else
                if(COUNTER == 2'd3) begin //Write reg
                    PC_w = 1'b0;    
                    MEM_w = 1'b0;   
                    IR_w = 1'b0;    
                    RB_w = 1'b1;    // libera pra escria
                    AB_w = 1'b0;    // AB?
                    ULA_c = 3'b001; // manda saida da ULA pro bancoReg
                    M_WREG = 1'b1;  // escolhe o reg pra escrita [rd]
                    M_ULAA = 1'b1;  
                    M_ULAB = 2'b00; 
                    reset_out = 1'b0;
                    COUNTER = COUNTER + 1;
                end
            end


            ST_RESET:
            begin
                // opcode de reset
                STATE = ST_RESET; // estado é o comum
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