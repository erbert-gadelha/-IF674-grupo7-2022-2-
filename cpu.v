module cpu(
            input wire clk,
            input wire reset
            );


//  -- PC --
reg[31:0] pc;
//  -- PC --


//  -- FIOS DA MEMORIA --
wire mem_write;
wire [31:0] mem_address;
reg [31:0] mem_data_in;
reg [31:0] mem_data_out;
//  -- FIOS DA MEMORIA --

// MEMORIA [<32>address, <1>clock, <1>write, <32>datain, <32>dataout]
Memoria memoria_ (mem_address, clock, mem_write, mem_data_in, mem_data_out);



//  -- FIOS DA INSTRUCAO --
wire decode_instr;
reg [31:26]inst_31to26;
reg [25:21]inst_25to21;
reg [20:16]inst_20to16;
reg [15: 0]inst_15to0;
//  -- FIOS DA INSTRUCAO --

// INSTRUCOES [ <1>clock, <1>reset, <1>load_ir, <32>data_in, <6>31to26, <5>25to21, <5>20to16, <16>15to0]
Instr_Reg instrucao_(clock, reset, decode_instr, mem_data_out, inst_31to26, inst_25to21, inst_20to16, inst_15to0);



//  -- FIOS DA INSTRUCAO --
wire can_write;
reg [4:0]reg_to_read1;
reg [4:0]reg_to_read2;
reg [4:0]reg_to_write;
reg [31:0]reg_data_in;
reg [31:0]reg_data_out1;
reg [31:0]reg_data_out2;
//  -- FIOS DA INSTRUCAO --

// REGISTRADORES [<1>clock, <1>reset, <1>write, <5>read_1, <5>read_2, <5>writeReg, <32>data_in, <32>data_out1, <32>data_out2]
Banco_reg registradores_(clock, reset, can_write, reg_to_read1, reg_to_read2, reg_to_write, reg_data_in, reg_data_out1, reg_data_out2);

wire [31:0] extd_out;
// EXTENSOR_16bits [<16>data_in, <32>data_out]
sign_extend_16 sign_extend_B (inst_15to0, extd_out);



//  -- FIOS DO MUX-A --
wire sel_ula_A;
wire [31:0] A;
//  -- FIOS DO MUX-A --

// MUX-A [<1>seletor, <32>data_in1, <32>data_in2, <32>data_out]
Mux_2 mux_a(sel_ula_A, reg_data_out1, pc, A);

//  -- FIOS DO MUX-B --
wire sel_ula_B;
wire [31:0] sel_A;
reg [31:0] const_4 = 32'd4;
//  -- FIOS DO MUX-B --
//Mux_8 mux_b(sel_ula_B, reg_data_out2, const_4, extd_out);



//  -- FIOS DA ULA --
wire[2:0] ula_func;
wire[31:0] sel_B;//              <<--<< GAMBIARRA
wire[31:0] ula_out;
wire[5:0] ula_flags;
//  -- FIOS DA ULA --

// ULA [<32>A, <32>B, <3>seletor, <32>out, flags( 5-ovflw, 4-ngtv, 3-zero, 2-equal, 1-menor, 0-maior) ]
ula32 ula_(sel_A, sel_B, ula_func, ula_out, ula_flags[5], ula_flags[4], ula_flags[3], ula_flags[2], ula_flags[1], ula_flags[0]);

endmodule
    

