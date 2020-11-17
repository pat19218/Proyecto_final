//couenter
module counter #(parameter N=12)
		(input logic clk,
		 input logic reset,
		 input logic load,
		 input logic enabled,
		 input [11:0] d,
		 output logic [N-1:0]q);

always@(posedge clk, posedge reset)
	if(reset)
		q<=0;
	else if (load)
		q<=d;
	else if (enabled && !load)
		q<=q+1;

endmodule

//ROM
module memoria_ROM (input wire [11:0]addres, output wire [7:0]data);

	reg [7:0]mem[0:4095];

initial begin
	$readmemb("memoria.list",mem);
end

assign data = mem[addres];

endmodule


//f.f.D
module fetch(input clk, input reset,
	     input ena,
	     input [7:0]d,
	     output reg [3:0]instruccion,
	     output reg [3:0]operando);


	always @ (posedge clk, posedge reset)begin

		if (reset)
			begin
				operando <= 4'b0;
				instruccion <= 4'b0;
			end
		else if (ena)
			begin
				operando <= d[3:0];
				instruccion <= d[7:4];
			end
	end
endmodule



//preparacion de control

module preparacion(input clk, input reset,
		   input logic load_counter, input logic ena_load_counter,
		   input logic enabled_ct, input logic enabled_fetch,
		   input logic [11:0]in_dato,
		   output wire [7:0]program_byte, output wire [3:0]intsr, output wire [3:0]oprnd);


	output wire [11:0]out_counter;

	counter co1(.clk(clk), .reset(reset),
		    .load(ena_load_counter), .enabled(enabled_ct),
		    .d(in_dato),
		    .q(out_counter) );




	wire [7:0]out_ROM;

	memoria_ROM r1(.addres(out_counter), .data(out_ROM) );



	output wire [3:0]fetch_instruccions;
	output wire [3:0]fetch_operando;

	fetch ftc(.clk(clk), .reset(reset),
		  .ena(enabled_fetch),
		  .d(out_ROM),
		  .instruccion(fetch_instruccions), .operando(fetch_operando) );

assign program_byte = out_ROM;
assign intsr = fetch_instruccions;
assign oprnd = fetch_operando;

endmodule





//parte 2
module buftri(input ena, input [3:0]d, output logic [3:0]q);

	always @ (*)
		if (ena == 0)
			q <= 1'bz;
		else
			q <= d;
endmodule


module accu(input clk, input reset, input ena, input [3:0]d, output logic [3:0]q);

	always @ (posedge clk, posedge reset)
		if (reset)
			q <= 4'b0;
		else if (ena)
			q <= d;
endmodule


module ALU (input wire [3:0] A,B,
	    input wire [2:0] funcion,
	    output logic[3:0] resul,
			output reg carry, zero);

reg[4:0] Alu_resultado;
parameter f1 = 3'b000;
parameter f2 = 3'b001;
parameter f3 = 3'b010;
parameter f4 = 3'b011;
parameter f5 = 3'b100;

always@(*) begin
	case(funcion)
		f1:
			Alu_resultado = A;
		f2:
			Alu_resultado = A - B;
		f3:
			Alu_resultado = B;
		f4:
			Alu_resultado = A + B;
		f5:
			Alu_resultado = ~(A & B);

		default: Alu_resultado = A + B;
	endcase

	assign resul = Alu_resultado;
	assign carry = Alu_resultado[4];
	assign zero = (Alu_resultado == 4'b0)? 4'd1:4'd0;

end
endmodule



module operacion(input clk, input reset,
								 input [3:0]dato_in,
								 input enabled_tri_1, input enabled_tri_2, input enabled_acu,
								 input [2:0] funcion,
								 output [3:0]dato_out,
								 output carry, zero);

	wire [3:0]salida_bufer_in;

	buftri datos_entrada(enabled_tri_1, dato_in, salida_bufer_in);


	wire [3:0]salida_alu;
	wire [3:0]salida_accu;

	accu acumulador(clk, reset, enabled_acu, salida_alu,	salida_accu);


	ALU	alu1(salida_accu, salida_bufer_in, funcion, salida_alu, carry, zero);


	buftri datos_salida(enabled_tri_2, salida_alu, dato_out);

endmodule
