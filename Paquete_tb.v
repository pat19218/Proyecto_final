module testbench();

reg clk = 0;
reg reset = 0;
reg ena_load_counter = 0;
reg loadCounter = 0;
reg enabledCounter = 0;
reg enabled_fetch = 0;
reg [11:0]dato;

//ejercicio1
output wire[7:0]Program_byte;
output wire[3:0]instruccion;
output wire[3:0]operando;

preparacion part1(clk, reset,
								  loadCounter, ena_load_counter,
									enabledCounter,  enabled_fetch,
									dato,
									Program_byte, instruccion, operando );

initial begin
	$display(" ");
	$display(" LOAD COUNTER    | Program byte  |   Instruccion   |  Operando  |");
	$display("----------------|---------------|-----------------|------------|");
	$monitor("%b               |  %b     |   %b          |    %b    |", loadCounter, Program_byte, instruccion, operando);

	reset = 1; #1 reset = 0; #1 dato = 12'b000011100000;
	#1 enabledCounter = 1;
	#1 ena_load_counter = 1; #2 ena_load_counter = 0;
	#1 enabled_fetch = 1;
	#5 reset = 1; #1 reset = 0;
	#1 dato = 12'b000000111000; #1 ena_load_counter = 1; #2 ena_load_counter = 0;
end



//ejercicio2
reg [3:0]dato_a_meter = 4'b0000;
reg enabled_acumulador, enabled_datoIn, enabled_datoOut;
reg [2:0]opcion;
wire [3:0]salida;
wire carry, zero;

operacion calculos (clk, reset,
									  dato_a_meter,
									  enabled_datoIn, enabled_datoOut, enabled_acumulador,
										opcion,
										salida, carry, zero);
initial begin
  enabled_acumulador = 0; enabled_datoIn = 1; enabled_datoOut = 0; #1 enabled_acumulador = 1;

#1 dato_a_meter = 4'b0100; #1 opcion = 3'b010;
#1 dato_a_meter = 4'b0001; #1 opcion = 3'b011;
#1 enabled_datoOut = 1;
#1 dato_a_meter = 4'b0111; #1 opcion = 3'b011;
#1 dato_a_meter = 4'b0101; #1 opcion = 3'b010;
#1 dato_a_meter = 4'b1101; #1 opcion = 3'b001;

end


always@(*)begin
	#1 clk = ~clk;
end
always@(*)begin
	#1 clk = ~clk;
end
initial
	#40 $finish;

initial begin
	$dumpfile("Paquete_tb.vcd");
	$dumpvars(0, testbench);
	end
endmodule
