//	REGISTRADOR DE EXCECOES
module EPC (
		input wire flag0, //opcode inexistente
		input wire flag1, //overflow
		input wire flag2, //div por zero
		input wire reset,
		input wire [31:0]PC_in,
		output reg [31:0]PC_out,
		output reg excecao
		); 



reg [31:0] PC;


always @(flag0 or flag1 or flag2 or reset) begin
	
	if(flag0 || flag1 || flag2) begin
		PC <= PC_in;
		excecao <= 1'b1;
	end

	if(reset) begin
		PC_out <= 32'd0;
		excecao <= 1'b0;
	end

end

endmodule
 