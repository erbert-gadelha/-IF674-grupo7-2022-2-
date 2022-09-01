module ctrl_unit( 
    input wire      clk,
    input wire    reset,// reset de entrada
        // flags da ULA
    input wire    Of, // fio de overflow
    input wire    Ng, // negacao
    input wire    Zr, // zero
    input wire    Eq, // igual
    input wire    Gt, // maior
    input wire    Lt, // menor
        // fim   
    // parte importante da instrucao
    input wire  [5:0]    OPCODE, // opcode
        // sinais de controle pra todos os muxs e todas as unidades do controle
    // Controladores com 1 bit
    // Registradores de variaveis 
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
    output reg  [1:0]    M_ULAB,

    // controle de reset de saida
    // Controles especiais pra instrucao de reset
    // Funciona de acordo com o Clock - sincronamente com o clock
    output reg    reset_out

);

// Variaveis 

// Toda instrucao tem um certa qtd de vezes pra acontecer, então eu preciso de um contador pra ele ser um número que eu fico olhando. 
// Uma variavel interna . Os reg
// Eu preciso de um contador de estado pra saber em qual estado eu estou
reg [2:0] COUNTER;
reg [1:0] STATE; 

// Parametros (constantes)
// Estados principais da maquina 
parameter ST_COMMON = 2'b00;
parameter ST_ADD = 2'b01;
parameter ST_ADDI = 2'b10;
parameter ST_RESET = 2'b11;

// Opcode
parameter ADD = 6'b000000;
parameter ADDI = 6'b001000;
parameter RESET = 6'b111111;



// O initial dá um reset em toda UC
// Aqui vc coloca tb o valor 227 no registrador 29
initial begin
    // dá o reset inicial na maquina , coloca no estado de reset 
    // o reset_out é o mesmo fio do reset_in 
    reset_out = 1'b1;
end


// 1) Defina um bloco que será sempre executado quando vc ver em relacao ao clock. 

// Observador que espera um sinal e quando atingi certo ponto executa o bloco de instrucoes dentro dele
// posedge - na subida de clock - 0 pra o 1
// negedge - 1 pra o 0 - descida do clock

// A maquina de estados fica aqui dentro
always @(posedge clk) begin
    // 2 situacoes - vindo da instrucao reset (estado reset por causa de uma instrucao)OU o sinal que veio de fora alguem apertou o botao

    // Apertei o botao de reset
    if (reset == 1'b1) begin
      if (STATE != ST_RESET) begin // se o estado for diferente do estado de reset
            STATE = ST_RESET; // eu coloco o estado atual no estado de reset
            
            // zero todos os sinais de saida pq nada pode ser escrito no Breg ou na Memoria
            // zero tudo. Tudo fica pra modo de escrita
            PC_w = 1'b0;
            MEM_w = 1'b0;
            IR_w = 1'b0;
            RB_w = 1'b0;
            AB_w = 1'b0;
            ULA_c = 3'b000;
            M_WREG = 1'b0;
            M_ULAA = 1'b0;
            M_ULAB = 2'b00;


            // eu garanto que o reset vai continuar sendo apertado pra terminar o processo
            // a saida de reset é colocada pra 1
            reset_out = 1'b1;

            COUNTER = 3'b000; // seta o contador pra proxima operacao - coloca ele pra 0  

        end

        else begin
            // Nesse estado como é o próximo clock eu posso supor que todas as unidades que precisam do reset pra funiconar foram resetadas. Dai eu jogo o estado pra o estado comun, que é o qual eu busco a instrucao e gravo em R e dou load em A e B e seto reset_out pra 0 
                STATE = ST_COMMON; // eu coloco o estado atual no estado de reset
                
                // zero todos os sinais de saida pq nada pode ser escrito no Breg ou na Memoria
                // zero tudo. Tudo fica pra modo de escrita
                PC_w = 1'b0;
                MEM_w = 1'b0;
                IR_w = 1'b0;
                RB_w = 1'b0;
                AB_w = 1'b0;
                ULA_c = 3'b000;
                M_WREG = 1'b0;
                M_ULAA = 1'b0;
                M_ULAB = 2'b00;
            
                
                // a saida de reset é colocada pra 0
                reset_out = 1'b0; // MEXEU AQUI
    
                COUNTER = 3'b000; // seta o contador pra proxima operacao
            
        end
    end
     //agora que eu lidei com o reset eu lido quando eu n estou no  reset
    // que é todos os outros estados que é quando o reset não tá precionado
    else begin
        // switch case pra meus estados 
        // dentro vou colocar o estaod que eu quero
        case (STATE)
            //posso colocar ST_COMMON pra lidar com os paraemtros ou 2'b00 
            ST_COMMON: begin
                // Os 3 primeiros ciclos de clock que eu preciso repetir.  
                // o contador começa no 0
                if(COUNTER == 3'b000 || COUNTER == 3'b001 || COUNTER == 3'b010) begin
                    // Aqui eu somo PC + 4 e espero a memoria sair enquanto eu n tenho certeza que tá saindo da memoria eu continuo fazendo a soma, mas n salvo em pc e nem em ir 
                    STATE = ST_COMMON; 
                    PC_w = 1'b0;
                    MEM_w = 1'b0; // ve se a memoria tá sendo escrita ou lida 
                    IR_w = 1'b0;
                    RB_w = 1'b0;
                    AB_w = 1'b0;
                    // Ver o controle da ULA que nesse caso fica sendo 001
                    ULA_c = 3'b001; // somo PC + 4 
                    M_WREG = 1'b0;
                    // Ver a entrada da ULA A e B
                    M_ULAA = 1'b0;
                    M_ULAB = 2'b01; // MUDOU PRA 1  
                    reset_out = 1'b0; 
                    COUNTER = COUNTER + 1; // seta o contador pra proxima operacao
                end
                // No 4° clock eu faço um else if pra o contador == 3 pra entrar no 4° clck
                else if(COUNTER == 3'b011) begin
                    STATE = ST_COMMON; 
                    // Eu altero PC pq eu sei que o que sai da memoria é o que eu quero e salvo isso em PC
                    PC_w = 1'b1;

                    MEM_w = 1'b0; 
                    
                    IR_w = 1'b1; // Mando salvar em IR
                    
                    RB_w = 1'b0;
                    AB_w = 1'b0;
                    ULA_c = 3'b001; // mexo na ula
                    M_WREG = 1'b0;
                    M_ULAA = 1'b0;
                    M_ULAB = 2'b01; 
                    reset_out = 1'b0; 
                    COUNTER = COUNTER + 1; // seta o contador pra proxima operacao
                end
                // Agora, a fase do 5° e 6° clock
                else if(COUNTER == 3'b100) begin
                    /*
                    Neste ciclo eu vou mandar gravar em A e em B. 
                    Como?
                    Eu n garanto que o conteudo de A e B está saindo corretamente pq o Breg demora 1 ciclos pra sair o sinal de dentro dele

                    Quando COUNTER = 100 - 5° estado
                    Manda escrever em A e B

                    E no 6 estado vc manda para de escrever em A e B, pq como eu já escrevi em A e B, eu já terminei meu ciclo comum e posso ir pra os ciclos específicos

                    Separo em 2
                    */
                    STATE = ST_COMMON; 
                    // Seto o PC pra 0 pq eu já considero que ele foi escrito, ai volta pra 0
                    PC_w = 1'b0;

                    // A memoria continua pra leitura  
                    MEM_w = 1'b0; 
                    
                    // Considero que o IR já foi escrito, então volta pra 0
                    IR_w = 1'b0; 
                    
                    RB_w = 1'b0;
                    AB_w = 1'b1; // estou escrevendo 
               
                    // Como eu n mexo com a ULA neste ciclo pq eu vou carregar A e B, ela vai pra 0  
                    ULA_c = 3'b000;

                    M_WREG = 1'b0;
                    M_ULAA = 1'b0; // vai pra 0
                    M_ULAB = 2'b00; // vai pra 0
                    reset_out = 1'b0; 
                    COUNTER = COUNTER + 1; // seta o contador pra proxima operacao
                    
                end
                /*              
                    No 6° estado vc para de escrever em A e B e pula pra o próximo estado a partir do OPCODE.
                    Pq como eu já escrevi em A e B, eu já terminei o meu ciclo comum. 
                    Agora, eu vou pra os ciclos específicos.
                */
                else if(COUNTER == 3'b101) begin
                    // Primeiro define o proximo estado através do OPCODE
                    case (OPCODE)
                        ADD: begin
                            STATE = ST_ADD;
                        end
                        ADDI: begin
                            STATE = ST_ADDI;
                        end
                        RESET: begin
                            STATE = ST_ADD;
                        end

                        // O DEFAULT É PRA QUANDO N ACHA NENHUMA AI GERA EXECECAO
                    endcase

                    PC_w = 1'b0;
                    MEM_w = 1'b0; 
                    IR_w = 1'b0; 
                    RB_w = 1'b0;
                    AB_w = 1'b0; // estou escrevendo 
                    ULA_c = 3'b000;
                    M_WREG = 1'b0;
                    M_ULAA = 1'b0; // vai pra 0
                    M_ULAB = 2'b00; // vai pra 0
                    reset_out = 1'b0; 
                    COUNTER = 3'b000; 
                    
                end
            end
            // O Banco de Registradores demora 2 ciclos pra escrever dentro dele, daí eu devo manter os sinais do ciclo anterior no 6° ciclo 2 clock
            // Por isso que o add tem 2 ciclos pq ele demora 2 ciclos pra escrever no banco de registadores, dai eu matenho os 2 estados 

            // PULA PRA O ESTADO DE ADD
            ST_ADD: begin
                // o estado de add tem 2 clocks 
                
                if (COUNTER == 3'b000) begin
                    // 1 - se o contador for 000 pq eu ainda vou entrar no 2° clock
                    STATE = ST_ADD; 
                    PC_w = 1'b0;
                    MEM_w = 1'b0; 
                    IR_w = 1'b0; 
                    // Vou escrever no Banco de Registradores pq minha ULA é instantanea, daí quando eu mando somar e a unica entrada do Breg pra ecrita é a ULA, então eu posso mandar escrever no Breg  
                    RB_w = 1'b1;
                    AB_w = 1'b0; 
                    // Eu mando escrever ao mesmo tempo que eu coloco a ULA pra fazer soma   
                    ULA_c = 3'b001;
                    // aciono o MUX de escrita no registrador 
                    M_WREG = 1'b1; 
                    // Comando o mux de entrada da ULA A e da B
                    M_ULAA = 1'b1;
                    M_ULAB = 2'b00; 
                    reset_out = 1'b0; 
                    COUNTER = COUNTER + 1; // adiciono 1 no contador
                    
                end
                 // Ai eu passo pra o 2 estado considerando que a soma já foi feita e meu Breg tá no ultimo ciclo pra salvar 
                    // Eu seto ele pra o estado comum e depois eu seleciono o contaaddor pra 0 pq no primerio estado do estado comum ele zera quase tudo e faz a soma do PC + 4
                // Logo, se eu tiver no 2° ciclo de clock vai fazer o seguinte: 
                // O Banco de Registradores demora 2 ciclos pra escrever dentro dele, daí eu devo manter os sinais do ciclo anterior no 6° ciclo 2 clock
            // Por isso que o add tem 2 ciclos pq ele demora 2 ciclos pra escrever no banco de registadores, dai eu matenho os 2 estados 

                else if(COUNTER == 3'b001) begin
                    
                    STATE = ST_COMMON; // estado é o comum
                    PC_w = 1'b0;
                    MEM_w = 1'b0; 
                    IR_w = 1'b0; 
                    RB_w = 1'b1;
                    AB_w = 1'b0; // estou escrevendo 
                    ULA_c = 3'b001;
                    M_WREG = 1'b1;
                    M_ULAA = 1'b1; // vai pra 0
                    M_ULAB = 2'b00; // vai pra 0
                    reset_out = 1'b0; 
                    COUNTER = 3'b000; 
                end
            end
            
            // INICIO DO ESTADO ADDI 

            ST_ADDI: begin
                // o estado de add tem 2 clocks 
                
                if (COUNTER == 3'b000) begin
                    // 1 - se o contador for 000 pq eu ainda vou entrar no 2° clock
                    STATE = ST_ADDI; 
                    PC_w = 1'b0;
                    MEM_w = 1'b0; 
                    IR_w = 1'b0; 
                    // Vou escrever no Banco de Registradores pq minha ULA é instantanea, daí quando eu mando somar e a unica entrada do Breg pra ecrita é a ULA, então eu posso mandar escrever no Breg  
                    RB_w = 1'b1;
                    AB_w = 1'b0; 
                    // Eu mando escrever ao mesmo tempo que eu coloco a ULA pra fazer soma   
                    ULA_c = 3'b001;
                    // aciono o MUX de escrita no registrador 
                    M_WREG = 1'b0; 
                    // Comando o mux de entrada da ULA A e da B
                    M_ULAA = 1'b1;
                    M_ULAB = 2'b10; // muda pra 10 
                    reset_out = 1'b0; 
                    COUNTER = COUNTER + 1; // adiciono 1 no contador
                    
                end
                 // Ai eu passo pra o 2 estado considerando que a soma já foi feita e meu Breg tá no ultimo ciclo pra salvar 
                    // Eu seto ele pra o estado comum e depois eu seleciono o contaaddor pra 0 pq no primerio estado do estado comum ele zera quase tudo e faz a soma do PC + 4
                // Logo, se eu tiver no 2° ciclo de clock vai fazer o seguinte: 
                // O Banco de Registradores demora 2 ciclos pra escrever dentro dele, daí eu devo manter os sinais do ciclo anterior no 6° ciclo 2 clock
            // Por isso que o add tem 2 ciclos pq ele demora 2 ciclos pra escrever no banco de registadores, dai eu matenho os 2 estados 

                else if(COUNTER == 3'b001) begin
                    
                    STATE = ST_COMMON; // estado é o comum
                    PC_w = 1'b0;
                    MEM_w = 1'b0; 
                    IR_w = 1'b0; 
                    RB_w = 1'b1;
                    AB_w = 1'b0; // estou escrevendo 
                    ULA_c = 3'b001;
                    M_WREG = 1'b0; // vai pra 0
                    M_ULAA = 1'b1; 
                    M_ULAB = 2'b10; // vai pra1
                    reset_out = 1'b0; 
                    COUNTER = 3'b000; 
                end
            end

            ST_RESET: begin
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