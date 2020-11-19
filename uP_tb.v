module testbench();

    reg clock, reset;
    reg [3:0] pushbuttons;
    wire phase, c_flag, z_flag;
    wire [3:0] instr, oprnd, accu, data_bus, FF_out;
    wire [7:0] program_byte;
    wire [11:0] PC, address_RAM;

    integer nota = 0;

    uP uPmodule(.clock(clock),
                .reset(reset),
                .pushbuttons(pushbuttons),
                .phase(phase),
                .c_flag(c_flag),
                .z_flag(z_flag),
                .instr(instr),
                .oprnd(oprnd),
                .accu(accu),
                .data_bus(data_bus),
                .FF_out(FF_out),
                .program_byte(program_byte),
                .PC(PC),
                .address_RAM(address_RAM));

    initial
        #500 $finish;

    always
        #5 clock = ~clock;

    initial begin
        clock = 0; reset = 0; pushbuttons = 4'b0110; nota = 0;
        #2 reset = 1;
        #1 reset = 0;
        $display("\n");
        $display("Bienvenido al testbench de su proyecto");
        $display("\n");
        $display("Para facilitar el código del testbench la nota se ha");
        $display("multplicado por 10. Es decir, la nota máxima de esta");
        $display("prueba es de 900. Obviamente su nota en Canvas no será de");
        $display("ese valor sino que se dividirá dentro de 10.");
        $display("Es decir, su nota es sobre 9.0 puntos netos.");
        $display("\n");
    end

    initial begin
        $dumpfile("uP_tb.vcd");
        $dumpvars(0, testbench);
    end

    initial begin
        #16
        if (PC === 12'h001 && accu === 4'h4) begin
            nota = nota + 70;
            $display("LIT funciona bien. Su nota es: %d/900\n", nota);
        end
        else
            $display("LIT NO funciona bien. Su nota es: %d/900\n", nota);
    end

    initial begin
        #36
        if (PC === 12'h002 && accu === 4'h4 && FF_out === 4'h4) begin
            nota = nota + 66;
            $display("OUT funciona bien. Su nota es: %d/900\n", nota);
        end
        else
            $display("OUT NO funciona bien. Su nota es: %d/900\n", nota);
    end

    initial begin
        #56
        if (PC === 12'h003 && accu === 4'h6 && FF_out === 4'h4) begin
            nota = nota + 66;
            $display("IN funciona bien. Su nota es: %d/900\n", nota);
        end
        else
            $display("IN NO funciona bien. Su nota es: %d/900\n", nota);
    end

    initial begin
        #76
        if (PC === 12'h004 && accu === 4'h0 && z_flag === 1'b1) begin
            $display("La bandera zero se encendió al colocar 4'b0000 en la salida de la ALU.\n");
        end
        else
            $display("La bandera zero NO se encendió al colocar 4'b0000 en la salida de la ALU.\n", nota);
    end

    initial begin
        #116
        if (PC === 12'h006 && accu === 4'h9 && c_flag === 1'b1) begin
            nota = nota + 33;
            $display("ADDI y la bandera carry funcionan bien. Su nota es: %d/900\n", nota);
        end
        else
            $display("ADDI y/o la bandera carry NO funcionan bien. Su nota es: %d/900\n", nota);
    end

    initial begin
        #136
        if (PC === 12'h007 && accu === 4'h9 && c_flag === 1'b0) begin
            nota = nota + 33;
            $display("CMPI de A > B hace que la bandera carry esté en 0 (como debería estar). Su nota es %d/900\n", nota);
        end
        else
            $display("CMPI de A > B causa que la bandera carry esté en 1 o modificó el valor del Accu. Su nota es %d/900\n", nota);
    end

    initial begin
        #176
        if (PC === 12'h009 && accu === 4'hA && c_flag === 1'b1) begin
            nota = nota + 33;
            $display("CMPI de A < B hace que la bandera carry esté en 1 (como debería estar). Su nota es %d/900\n", nota);
        end
        else
            $display("CMPI de A > B causa que la bandera carry esté en 1 o modificó el valor del Accu.  Su nota es %d/900\n", nota);
    end

    initial begin
        #196
        if (PC === 12'h00A && accu === 4'hB && c_flag === 1'b0 && z_flag === 1'b0) begin
            nota = nota + 33;
            $display("ADDI sin overflow no levanta las banderas (como debería estar). Su nota es %d/900\n", nota);
        end
        else
            $display("ADDI sin overflow levantó alguna de las banderas o no realizó bien la suma.  Su nota es %d/900\n", nota);
    end

    initial begin
        #216
        if (PC === 12'h00B && accu === 4'h4 && c_flag === 1'b0 && z_flag === 1'b0) begin
            nota = nota + 66;
            $display("NANDI funciona bien. Su nota es %d/900\n", nota);
        end
        else
            $display("NANDI NO funciona bien.  Su nota es %d/900\n", nota);
    end

    initial begin
        #276
        if (PC === 12'hA01) begin
            nota = nota + 60;
            $display("JMP funciona bien. Ahora estamos en PC = 12'hA01. Su nota es %d/900\n", nota);
        end
        else
            $display("JMP NO funciona bien. El PC no está en la localidad 12'HA01.  Su nota es %d/900\n", nota);
    end


endmodule
