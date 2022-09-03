module cpu( input wire clock,
            input wire reset );

reg [32:0] pc = 32'd0;

//  INSTRUCOES [ <1>clock, <1>reset, <1>load_ir, <32>data_in, <6>31to26, <5>25to21, <5>20to16, <16>15to0]
    wire [31:26]inst_31to26;
    wire [25:21]inst_25to21;
    wire [20:16]inst_20to16;
    wire [15: 0]inst_15to0;
//
// MUX-A [<1>seletor, <32>data_in1, <32>data_in2, <32>data_out]
    wire sel_ula_A;
    wire [31:0] A;
//
// MUX_ULAB [<2>seletor, <32>data0, <32>data1, <32>data2, <32>data3, <32>data_out]
    wire [1:0]sel_ula_B;
    wire [31:0] sel_A;
    reg [31:0] const_4 = 32'd4;
    wire [31:0] B;
//

// CONTROLE  IN[<1>clock, <1>reset, <6>flags, <6>opcode] OUT[<5>writes, <1>PC_source, <1>Mem_Adress_Source, <1>mux_ULAa, <1>mux_ULAb, <1>reset]
    wire [5:0] flags; // FLAGS: 0-overflow, 1-negative, 2-zero, 3-less, 4-greater
    wire [5:0] writes;
    wire [2:0] ula_func;
    wire pc_source;
    wire mem_adress_src;
    wire mux_ulaA;
    wire mux_ulaB;
    wire reset_out;
//
    unidade_controle controle_( clock, reset, flags, inst_31to26, inst_15to0, writes, pc_source, mem_adress_src, sel_ula_A, sel_ula_B, reset_out);
//


// MEMORIA [<32>address, <1>clock, <1>write, <32>datain, <32>dataout]
    wire mem_write;
    wire [31:0] mem_address = pc;
    wire [31:0] mem_data_in;
    wire [31:0] mem_data_out;
//
    Memoria memoria_ (mem_address, clock, mem_write, mem_data_in, mem_data_out);
//


//  INSTRUCOES [ <1>clock, <1>reset, <1>load_ir, <32>data_in, <6>31to26, <5>25to21, <5>20to16, <16>15to0]
//
    Instr_Reg instrucao_(clock, reset, writes[2], mem_data_out, inst_31to26, inst_25to21, inst_20to16, inst_15to0);
//

// SIGN_EXTEND / LEFTSHIFT2
    wire [31:0] extd_out;
    wire [31:0] shift_out;
    // EXTENSOR_16bits [<16>data_in, <32>data_out]
    sign_extend_16 sign_extend_B (inst_15to0, extd_out);
    // LEFT_SHIFT2 [<32>data_in, <32>data_out]
    left_shift2 shift2_(extd_out, shift_out);
//

// REGISTRADORES [<1>clock, <1>reset, <1>write, <5>read_1, <5>read_2, <5>writeReg, <32>data_in, <32>data_out1, <32>data_out2]
    wire [4:0]reg_to_read1;
    wire [4:0]reg_to_read2;
    wire [4:0]reg_to_write;
    wire [31:0]reg_data_in;
    wire [31:0]reg_data_out1;
    wire [31:0]reg_data_out2;
//
    Banco_reg registradores_(clock, reset, writes[3], reg_to_read1, reg_to_read2, reg_to_write, reg_data_in, reg_data_out1, reg_data_out2);
//

// MUX-MEMsrc [<1>seletor, <32>data_in1, <32>data_in2, <32>data_out]
//    wire [32:0] mem_in;
//
//    mux2 mux_mem_ (mem_adress_src, pc, ul, A);
//


// MUX-ULAA [<1>seletor, <32>data_in1, <32>data_in2, <32>data_out]
//
    mux2 mux_a_ (sel_ula_A, reg_data_out1, pc, A);
//

// MUX_ULAB [<2>seletor, <32>data0, <32>data1, <32>data2, <32>data3, <32>data_out]
//
    mux_4 mux_b_ (sel_ula_B, reg_data_out2, const_4, extd_out, shift_out, B);
//


// ULA [<32>A, <32>B, <3>seletor, <32>out, flags( 0-ovflw, 1-ngtv, 2-zero, 3-equal, 4-menor, 5-maior) ]
    wire[31:0] ula_out;
    wire[5:0] ula_flags;
//
    ula32 ula_(A, B, ula_func, ula_out, ula_flags[0], ula_flags[1], ula_flags[2], ula_flags[3], ula_flags[4], ula_flags[5]);
//

// MUX-PCsource [<1>seletor, <32>data_in1, <32>data_in2, <32>data_out]
    wire [31:0]pc_out;
//
    mux2 pc_souce_ (pc_source, pc, ula_out, pc_out);
    assign pc = pc_out;
//


endmodule
    

