
// CONTROLE  IN  -[<1>clock, <1>reset, <6>flags, <6>opcode]
// CONTROLE  OUT -[<5>writes, <1>PC_source, <1>mux_mem_adrss, <1>mux_ULAa, <2>mux_ULAb, <2>mux_reg_adrrs, <3>mux_reg_data, <1>reset]

module unidade_controle(
    // INPUTS
        input wire clk,
        input wire reset,
        input wire [5:0] flags, // FLAGS: 0-overflow, 1-negative, 2-zero, 3-less, 4-greater
        input wire [5:0] OPCODE,
    //
    // OUTPUTS
        // CAN_WRITE ...
            output reg [6:0] can_write, 
            // 6-Append_out
            //  5-ALU_out
            //   4-Regs_AB
            //    3-Registradores
            //     2-Instrucao
            //      1-Memoria
            //       0-PC

        // MUTIPLEXADORES
            output reg [1:0] PC_source,
            output reg       M_MEM_Adress,
            output reg       M_ULAA,
            output reg [1:0] M_ULAB,
            output reg [1:0] M_REG_adress,
            output reg [2:0] M_REG_data,
    //
    // RESETA MODULOS
            output wire reset_out
    //
);


// DECLARACOES
    // VARIAVEIS 
        reg [3:0] COUNTER;
        reg [3:0] STATE;
        reg do_BRANCH;
    // 
    // Estados principais da maquina 
        parameter ST_BUSCA  = 5'd0;
        parameter ST_ULA    = 5'd1;
        parameter ST_JR     = 5'd2;
        parameter ST_RESET  = 5'd3;
        parameter ST_BRANCH = 5'd4;

        parameter ST_OUTRO  = 5'd10;
        //parameter ST_BACK = 5'd4;
    //
    // FUNCS
        parameter ADD = 5'h20;
        parameter AND = 5'h24;
        parameter SUB = 5'h22;        
    //
    // OPCODES
        parameter R     = 6'h0;
        parameter ADDI  = 6'h8;
        parameter ADDIU = 6'h9;

        parameter BEQ   = 6'h4;
        parameter BNE   = 6'h5;
        parameter BLE   = 6'h6;
        parameter BGT   = 6'h7;
        parameter LUI   = 6'hf;

        //[LOADS/STORES]
            // parameter LB = 6'h20;
            // parameter LH = 6'h21;
            // parameter LW = 6'h23;
            // parameter SB = 6'h28;
            // parameter SH = 6'h29;
            // parameter SLTI = 6'ha;
            // parameter SW = 6'h2b;

        parameter J     = 6'h2;
        parameter JAL   = 6'h3;
        parameter RESET = 6'b111111;
    //
//

initial begin
    // Tambem deve resetar pilha
    M_MEM_Adress = 3'd0;
    PC_source = 1'b0;
    can_write = 6'd0;
    COUNTER = 4'd0;
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
        COUNTER = 4'd0;
    end
    
    else begin // FORA DO reset


        if (STATE == ST_BUSCA)  // #0 - BUSCA E DECODIFICACAO
        begin
            // BUSCA
            if (COUNTER == 0 || COUNTER == 1 || COUNTER == 2)    
            begin
                COUNTER = COUNTER + 1;
                M_MEM_Adress = 0;      // LE PC
                can_write = 7'b000100;   // LIBERA instr PARA ESCRITA

                // ZERA OUTRAS SAIDAS
                    PC_source = 1'b0;
                    M_ULAB = 2'd0;
                    M_ULAA = 1'b0;
                //                    
            end else
            //
            // TROCA DE ESTADO
            if (COUNTER == 3)
            begin
                COUNTER = 4'd0;
                STATE = ST_OUTRO;
                
                case(OPCODE)
                        RESET:  STATE = ST_RESET;
                            R:  STATE = ST_ULA;
                         ADDI:  STATE = ST_ULA;
                        ADDIU:  STATE = ST_ULA;

                          BEQ:  STATE = ST_BRANCH;
                          BNE:  STATE = ST_BRANCH;
                          BLE:  STATE = ST_BRANCH;
                          BGT:  STATE = ST_BRANCH;
                endcase
            end
        end else
        
        if (STATE == ST_ULA)    // #1 - ADD, AND, SUB, ADDI, ADDIU
        begin
                // CHOSE A/B
                if(COUNTER == 0 || COUNTER == 1 || COUNTER == 2) begin
                    COUNTER = COUNTER + 1;
                    can_write = 7'b0100000; // WRITE ALUout

                    // SELECT A/B  
                        M_ULAA = 1;
                        if(OPCODE == 6'd0) begin    // TIPO R
                            M_ULAB = 2'd0;              // SELECT REG2
                        end else begin              // TIPO I
                            M_ULAB = 2'd2;              // SELECT SIGN_EXTEND
                        end
                    //
                //
                // SEND ALUOUT TO REG_IN
                end else if(COUNTER == 3) begin 
                    COUNTER = COUNTER + 1;
                    can_write = 7'b0100000; // WRITE ALUout  
                    M_REG_data = 3'd1;      // SELECT ALUout

                    // SELECT A/B  
                        M_ULAA = 1;
                        if(OPCODE == 6'd0) begin    // TIPO R
                            M_ULAB = 2'd0;              // SELECT REG2
                            M_REG_adress = 2'd1;        // SELECT REG TO WRITE 
                        end else begin              // TIPO I
                            M_ULAB = 2'd2;              // SELECT SIGN_EXTEND
                            M_REG_adress = 2'd0;        // SELECT REG TO WRITE 
                        end
                    //
                //
                // WRITE RESULT
                end else if(COUNTER == 4 || COUNTER == 5) begin 
                    COUNTER = COUNTER + 1;
                    can_write = 7'b0001000; // WRITE REGs

                    // SELECT REG TO WRITE
                        M_REG_data = 3'd1;      // SELECT ALUout

                        if(OPCODE == 6'd0) begin    // TIPO R
                            M_REG_adress = 2'd1;        // SELECT 15to11
                        end else begin              // TIPO I
                            M_REG_adress = 2'd0;        // SELECT 25to21
                        end
                    //
                    // SELECT A/B  
                        M_ULAA = 1;
                        if(OPCODE == 6'd0) begin    // TIPO R
                            M_ULAB = 2'd0;              // SELECT REG2
                            M_REG_adress = 2'd1;        // SELECT REG TO WRITE 
                        end else begin              // TIPO I
                            M_ULAB = 2'd2;              // SELECT SIGN_EXTEND
                            M_REG_adress = 2'd0;        // SELECT REG TO WRITE 
                        end
                //
                // PC + 4
                end else if(COUNTER == 6 || COUNTER == 7) begin
                    COUNTER = COUNTER + 1;
                    can_write = 7'b0100000; // WRITE ALUOUT
                    // SELECT PC SOURCES
                        PC_source = 0;  //ALUOUT
                        M_ULAA = 0;     //PC
                        M_ULAB = 2'd1;  //+4
                    //
                //
                // WRITE PC + 4
                end else if(COUNTER == 8) begin
                    COUNTER = COUNTER + 1;
                    can_write = 7'b0000001; // WRITE PC

                    // SELECT PC SOURCES
                        PC_source = 0;  //ALUOUT
                        M_ULAA = 0;     //PC
                        M_ULAB = 2'd1;  //+4
                    //
                //
                // GO TO INITIAL_STATE
                end else begin
                    STATE = ST_BUSCA;   // INITIAL STATE
                    can_write = 7'd0;   // CANT WRITE
                    COUNTER = 4'd0;     // RESET
                end
        
        end else

        if (STATE == ST_BRANCH) // #4 - BRANCHES
        begin

            // CHOSE A/B
            if(COUNTER == 0 || COUNTER == 1 || COUNTER == 2)
            begin
                COUNTER = COUNTER + 1;
                can_write = 7'b0100000; // WRITE ALUout
                do_BRANCH = 0;

                // SELECT A/B  
                    M_ULAA = 1;
                    if(OPCODE == 6'd0) begin    // TIPO R
                        M_ULAB = 2'd0;              // SELECT REG2
                    end else begin              // TIPO I
                        M_ULAB = 2'd2;              // SELECT SIGN_EXTEND
                    end
                //
            end else
            //
            // VALIDA BRANCH
            if(COUNTER == 3)
            begin
                COUNTER = COUNTER + 1;
                can_write = 7'd0;
                do_BRANCH = 0;
                
                //  FLAGS - <[0]OVERFLOW -  [1]NEGATIVE - [2]ZERO - [3]EQUAL - [4]MENOR [5]MAIOR>
                case(OPCODE)
                    5'h4:   do_BRANCH =  flags[3]; //BEQ 0x4 -  flag[3] [rs == rt]
                    5'h5:   do_BRANCH = !flags[3]; //BNE 0x5 - !flag[3] [rs != rt]
                    5'h6:   do_BRANCH = !flags[5]; //BLE 0x6 - !flag[5] [rs <= rt]
                    5'd7:   do_BRANCH =  flags[5]; //BGT 0x7 -  flag[5] [rs > rt]
                endcase
            end else
            //
            // PC + [4/OFFSET]
            if(COUNTER == 4 || COUNTER == 5) begin
                COUNTER = COUNTER + 1;
                can_write = 7'b0100000; // WRITE ALUOUT
                // SELECT PC SOURCES
                    PC_source = 0;  //ALUOUT
                    M_ULAA = 0;     //PC
                    
                    M_ULAB = {do_BRANCH? 2'd2 : 2'd1 };  //[ OFFSET | 4 ]
                //
            //
            // WRITE PC + [4/OFFSET]
            end else if(COUNTER == 6) begin
                COUNTER = COUNTER + 1;
                can_write = 7'b0000001; // WRITE PC

                // SELECT PC SOURCES
                    PC_source = 0;  //ALUOUT
                    M_ULAA = 0;     //PC
                    M_ULAB = {do_BRANCH? 2'd2 : 2'd1 };  //[ OFFSET | 4 ]
                //
            //
            // GO TO INITIAL_STATE
            end else begin
                STATE = ST_BUSCA;   // INITIAL STATE
                can_write = 7'd0;   // CANT WRITE
                COUNTER = 4'd0;     // RESET
            end
        end else


        if(OPCODE == LUI)       // OPCODE [0x2] -  LUI
        begin            
            // GET EXTEND SIGN
            if(COUNTER == 0 || COUNTER == 1 || COUNTER == 2) begin
                COUNTER = COUNTER + 1;
                can_write = 7'b0001000; // WRITE REG

                //  SELECT REG TO WRITE
                    M_REG_adress = 2'd0;    // SELECT REG TO WRITE 
                    M_REG_data = 3'd6;      // SELECT SIGN EXTEND
                //
            //
            // PC + 4
            end else if(COUNTER == 3 || COUNTER == 4) begin
                COUNTER = COUNTER + 1;
                can_write = 7'b0100000; // WRITE ALUOUT
                // SELECT PC SOURCES
                    PC_source = 0;  //ALUOUT
                    M_ULAA = 0;     //PC
                    M_ULAB = 2'd1;  //+4
                //
            //
            // WRITE PC + 4
            end else if(COUNTER == 5) begin
                COUNTER = COUNTER + 1;
                can_write = 7'b0000001; // WRITE PC

                // SELECT PC SOURCES
                    PC_source = 0;  //ALUOUT
                    M_ULAA = 0;     //PC
                    M_ULAB = 2'd1;  //+4
                //
            //
            // GO TO INITIAL_STATE
            end else begin
                STATE = ST_BUSCA;   // INITIAL STATE
                can_write = 7'd0;   // CANT WRITE
                COUNTER = 4'd0;     // RESET
            end
        end

        // SE NÃO ENCONTRAR FUNCAO
        /*
        if (COUNTER == 0 || COUNTER == 1) begin
            STATE = ST_BUSCA;
            can_write = 8'd0;
            COUNTER = 3'd0;
                        // PC + 4
            end else if(COUNTER == 3 || COUNTER == 4) begin
                COUNTER = COUNTER + 1;
                can_write = 7'b0100000; // WRITE ALUOUT
                // SELECT PC SOURCES
                    PC_source = 0;  //ALUOUT
                    M_ULAA = 0;     //PC
                    M_ULAB = 2'd1;  //+4
                //
            //
            // WRITE PC + 4
            end else if(COUNTER == 5) begin
                COUNTER = COUNTER + 1;
                can_write = 7'b0000001; // WRITE PC

                // SELECT PC SOURCES
                    PC_source = 0;  //ALUOUT
                    M_ULAA = 0;     //PC
                    M_ULAB = 2'd1;  //+4
                //
            //
            // GO TO INITIAL_STATE
            end else begin
                STATE = ST_BUSCA;   // INITIAL STATE
                can_write = 7'd0;   // CANT WRITE
                COUNTER = 4'd0;     // RESET
            end
        end*/

    end
end


endmodule