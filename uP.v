//couenter principal para todo el procesador
module pcounter (input clk,
		 						input reset,
		 						input load,
		 						input enabled,
		 						input [11:0] d,
		 						output[11:0]PC);

wire clk, reset, load, enabled;
wire [11:0]d;
reg [11:0]PC;

always@(posedge clk, posedge reset) begin
	if (reset) begin
		PC<=0;
	end
	else if (load) begin
		PC<=d;
	end
	else if (enabled && !load) begin
		PC<=PC+1;
	end
	end
endmodule



//ROM
module memoria_ROM (input wire [11:0]addres, output wire [7:0]data);
	reg [7:0]mem[0:4095];

initial begin
	$readmemh("memoria.list",mem);
end

assign data = mem[addres];
endmodule



//f.f.D
module fetch(input clk, input reset,
	     input ena,
	     input [7:0]d,
	     output [3:0]instruccion,
	     output [3:0]operando);

	reg [3:0]instruccion;
	reg [3:0]operando;

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
//f.f.D
module flag(input clk, input reset, input ena,
	     input carry, zero,
	     output reg c_flag,
			 output reg z_flag);

	always @ (posedge clk, posedge reset)begin
		if (reset)
			begin
				c_flag <= 1'b0;
				z_flag <= 1'b0;
			end
		else if (ena)
			begin
				c_flag <= carry;
				z_flag <= zero;
			end
	end
endmodule



//f.f.T
module phase(input clk, input reset, output logic q, output p);
	always @ (posedge clk, posedge reset)
		if (reset)
			q <= 0;
		else
			q <= ~q;
		assign p = ~q;
endmodule



// decode
module decode (input phase, input c_flag, input z_flag, input [3:0]instr,
							 output reg [12:0]comando);

	reg [6:0] in_decode;
	reg [12:0] out_decode;

		always @ ( * ) begin
		in_decode[0] <= phase;
		in_decode[1] <= z_flag;
		in_decode[2] <= c_flag;
		in_decode[6:3] <= instr;

		casez (in_decode)

			7'b??????0: out_decode <= 13'b1000000001000; //any
			7'b00001?1: out_decode <= 13'b0100000001000; //JC
			7'b00000?1: out_decode <= 13'b1000000001000; //JC
			7'b00011?1: out_decode <= 13'b1000000001000; //JNC
			7'b00010?1: out_decode <= 13'b0100000001000; //JNC
			7'b0010??1: out_decode <= 13'b0001001000010; //CMPI
			7'b0011??1: out_decode <= 13'b1001001100000; //CMPM
			7'b0100??1: out_decode <= 13'b0011010000010; //LIT
			7'b0101??1: out_decode <= 13'b0011010000100; //IN
			7'b0111??1: out_decode <= 13'b1000000111000; //LD
			7'b0110??1: out_decode <= 13'b1011010100000; //ST
			7'b1000?11: out_decode <= 13'b0100000001000; //JZ
			7'b1000?01: out_decode <= 13'b1000000001000; //JZ
			7'b1001?11: out_decode <= 13'b1000000001000; //JNZ
			7'b1001?01: out_decode <= 13'b0100000001000; //JNZ
			7'b1010??1: out_decode <= 13'b0011011000010; //ADDI
			7'b1011??1: out_decode <= 13'b1011011100000; //ADDM
			7'b1100??1: out_decode <= 13'b0100000001000; //JMP
			7'b1101??1: out_decode <= 13'b0000000001001; //OUT
			7'b1110??1: out_decode <= 13'b0011100000010; //NANDI
			7'b1111??1: out_decode <= 13'b1011100100000; //NANDM

			default: out_decode = 13'bxxxxxxxxxxxxx;

		endcase
		assign comando = out_decode;
	end
endmodule


module buftri(input ena, input [3:0]d, output logic [3:0]q);

	always @ (*) begin
		if (ena == 0) begin
			q <= 4'bzzzz;
		end
		else begin
			q <= d;
		end
	end
endmodule



module accu(input clk, input reset, input ena, input [3:0]d, output logic [3:0]q);

	always @ (posedge clk, posedge reset)
		if (reset)
			q <= 4'b0;
		else if (ena)
			q <= d;
endmodule



module ALU(input [3:0] A, B,
           input [2:0] funcion,
           output carry, zero,
           output [3:0] resul);

    reg [4:0] regresul;

    always @ (A, B, funcion)
        case (funcion)
            3'b000: regresul = A;
            3'b001: regresul = A - B;
            3'b010: regresul = B;
            3'b011: regresul = A + B;
            3'b100: regresul = {1'b0, ~(A & B)};
            default: regresul = 5'b10101;
        endcase

    assign resul = regresul[3:0];
    assign carry = regresul[4];
    assign zero = ~(regresul[3] | regresul[2] | regresul[1] | regresul[0]);
endmodule


module RAM (input csRAM, weRAM,
            input [11:0] address,//in
            inout [3:0] data);

            reg [3:0] memory [0:4095]; //ram
            reg [3:0] data_out;


            always @ ( csRAM or weRAM or address or data) begin
              if ((csRAM == 1) && (weRAM == 1)) begin
                memory[address] <= data;
              end
              else if ((csRAM == 1) && (weRAM == 0)) begin
                data_out <= memory[address];
              end
            end

            assign data = (csRAM && !weRAM) ? data_out : 4'bzzzz;
endmodule

module addRam (input [7:0]program_byte, input [3:0]oprnd, output [11:0]address_RAM);
reg [11:0] address_RAM;

always @ ( * ) begin
	address_RAM [7:0] <= program_byte;
	address_RAM [11:8] <= oprnd;
end

endmodule // addRam


module uP (input clock, reset,
					 input [3:0] pushbuttons,
					 output phase, c_flag, z_flag,
					 output [3:0] instr,
					 output [3:0] oprnd,
					 output [3:0] data_bus,
					 output [3:0] FF_out,
					 output [3:0] accu,
					 output [7:0] program_byte,
					 output [11:0] PC,
					 output [11:0] address_RAM);

	wire clock, reset;
	wire carry, zero;
	wire phase, c_flag, z_flag, z_in, phaseN;
	wire [3:0]out_alu;
	wire [3:0]pushbuttons;
	wire [3:0] instr;
	wire [3:0] oprnd;
	wire [3:0] data_bus;
	wire [3:0] FF_out;
	wire [3:0] accu;
	wire [7:0] program_byte;
	wire [11:0] PC;
	wire [11:0] address_RAM;
	wire [12:0]comand;

	addRam addresram (.program_byte(program_byte), .oprnd(oprnd), .address_RAM(address_RAM) );

	pcounter prco(clock, reset, comand[11], comand[12], address_RAM, PC);

	memoria_ROM rom(.addres(PC), .data(program_byte) );

	fetch Fetch(.clk(clock), .reset(reset), .ena(phaseN), .d(program_byte), .instruccion(instr), .operando(oprnd) );

	phase p(.clk(clock), .reset(reset), .q(phase), .p(phaseN) );

	flag Flags(.clk(clock), .reset(reset), .ena(comand[9]), .carry(carry), .zero(zero), .c_flag(c_flag), .z_flag(z_flag) );

	decode Deco(.phase(phase), .c_flag(c_flag), .z_flag(z_flag), .instr(instr), .comando(comand) );

	buftri in_oprnd(.ena(comand[1]), .d(oprnd), .q(data_bus) );

	ALU alu(.A(accu), .B(data_bus), .funcion(comand[8:6]), .resul(out_alu), .carry(carry), .zero(zero) );

	accu acumu (.clk(clock), .reset(reset), .ena(comand[10]), .d(out_alu), .q(accu) );

	buftri OutALU(.ena(comand[3]), .d(out_alu), .q(data_bus) );

	RAM memram(.csRAM(comand[5]), .weRAM(comand[4]), .address(address_RAM), .data(data_bus) );

	buftri InPush(.ena(comand[2]), .d(pushbuttons), .q(data_bus)  );

	buftri OutSi(.ena(comand[0]), .d(data_bus), .q(FF_out)  );

endmodule
