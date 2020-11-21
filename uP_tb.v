module testbench();

    reg clock, reset;
    reg [3:0] pushbuttons;
    wire phase, c_flag, z_flag;
    wire [3:0] instr, oprnd, accu, data_bus, FF_out;
    wire [7:0] program_byte;
    wire [11:0] PC, address_RAM;

    integer nota = 0;
    integer immediateDelay = 16;
    integer jumpDelay = 656;
    integer memoryDelay = 276;

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
        #1000 $finish;

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
        #immediateDelay
        if (PC === 12'h001 && accu === 4'hF) begin
            nota = nota + 70;
            $display("LIT funciona bien. Su nota es: %d/900", nota);
        end
        else
            $display("LIT NO funciona bien. Su nota es: %d/900", nota);
    end

    initial begin
        #(immediateDelay+20*1)
        if (PC === 12'h002 && accu === 4'hF && FF_out === 4'hF) begin
            nota = nota + 33;
            $display("OUT parece funcionar bien. Su nota es: %d/900", nota);
        end
        else
            $display("OUT NO funciona bien. Su nota es: %d/900", nota);
    end

    initial begin
        #(immediateDelay + 20 * 2)
        if (PC === 12'h003 && accu === 4'h6) begin
            nota = nota + 33;
            $display("IN parece funcionar bien. Su nota es: %d/900", nota);
        end
        else
            $display("IN NO funciona bien. Su nota es: %d/900", nota);
    end

    initial begin
        #(immediateDelay + 20 * 3)
        if (PC === 12'h004 && accu === 4'h0 && z_flag === 1'b1) begin
            $display("La bandera zero se encendió al colocar 4'b0000 en la salida de la ALU.");
        end
        else
            $display("La bandera zero NO se encendió al colocar 4'b0000 en la salida de la ALU.", nota);
    end

    initial begin
        #(immediateDelay + 20 * 5)
        if (PC === 12'h006 && accu === 4'h9 && c_flag === 1'b1) begin
            nota = nota + 33;
            $display("ADDI y la bandera carry funcionan bien. Su nota es: %d/900", nota);
        end
        else
            $display("ADDI y/o la bandera carry NO funcionan bien. Su nota es: %d/900", nota);
    end

    initial begin
        #(immediateDelay + 20 * 6)
        if (PC === 12'h007 && accu === 4'h9 && c_flag === 1'b0) begin
            nota = nota + 33;
            $display("CMPI de A > B hace que la bandera carry esté en 0 (como debería estar). Su nota es %d/900", nota);
        end
        else
            $display("CMPI de A > B causa que la bandera carry esté en 1 o modificó el valor del Accu. Su nota es %d/900", nota);
    end

    initial begin
        #(immediateDelay + 20 * 8)
        if (PC === 12'h009 && accu === 4'hA && c_flag === 1'b1) begin
            nota = nota + 33;
            $display("CMPI de A < B hace que la bandera carry esté en 1 (como debería estar). Su nota es %d/900", nota);
        end
        else
            $display("CMPI de A > B causa que la bandera carry esté en 1 o modificó el valor del Accu.  Su nota es %d/900", nota);
    end

    initial begin
        #(immediateDelay + 20 * 9)
        if (PC === 12'h00A && accu === 4'hB && c_flag === 1'b0 && z_flag === 1'b0) begin
            nota = nota + 33;
            $display("ADDI sin overflow no levanta las banderas (como debería estar). Su nota es %d/900", nota);
        end
        else
            $display("ADDI sin overflow levantó alguna de las banderas o no realizó bien la suma.  Su nota es %d/900", nota);
    end

    initial begin
        #(immediateDelay + 20 * 10)
        if (PC === 12'h00B && accu === 4'h4 && c_flag === 1'b0 && z_flag === 1'b0) begin
            nota = nota + 66;
            $display("NANDI funciona bien. Su nota es %d/900", nota);
        end
        else
            $display("NANDI NO funciona bien.  Su nota es %d/900", nota);
    end

    initial begin
        #(immediateDelay + 20 * 11)
        if (PC === 12'h00C && accu === 4'h4 && c_flag === 1'b0 && z_flag === 1'b0 && FF_out === 4'h4) begin
            nota = nota + 33;
            $display("OUT funciona bien (la verificación de OUT se hizo en 2 partes). Su nota es %d/900", nota);
        end
        else
            $display("OUT NO funciona bien (la verificación de OUT se hizo en 2 partes).  Su nota es %d/900", nota);
        pushbuttons = 4'hE;
    end

    initial begin
        #(immediateDelay + 20 * 12)
        if (PC === 12'h00D && accu === 4'hE && c_flag === 1'b0 && z_flag === 1'b0 && FF_out === 4'h4) begin
            nota = nota + 33;
            $display("IN funciona bien (la verificación de IN se hizo en 2 partes). Su nota es %d/900", nota);
        end
        else
            $display("IN NO funciona bien (la verificación de IN se hizo en 2 partes).  Su nota es %d/900", nota);

        $display("\n-----------------------------------------------------------------------------------------------------------------------------");
        $display("Hasta este punto se han verificado todas las instrucciones con inmediatos. Ahora se verificarán las instrucciones con memoria RAM.");
        $display("La nota máxima (hasta este punto) es 400.\n");
    end

    initial begin
        #(memoryDelay - 2)//274
        if (PC === 12'h00E && accu === 4'hE && address_RAM === 12'h000) begin
            $display("ST parece funcionar bien, pero no hemos probado si realmente almacenó datos la RAM. PC = 12'h00E, accu = 4'hE y address_RAM = 12'h000. Su nota es %d/900", nota);
        end
        else
            $display("ST NO parece funcionar bien. Hay algún problema con el PC, accu o la address_RAM.  Su nota es %d/900", nota);
    end

    initial begin
        #(memoryDelay + (20 * 6) - 2)//394
        if (PC === 12'h017 && accu === 4'h1 && address_RAM === 12'h333) begin
            $display("ST parece funcionar bien, pero no hemos probado si realmente almacenó datos la RAM. PC = 12'h017, accu = 4'h1 y address_RAM = 12'h333. Su nota es %d/900", nota);
        end
        else
            $display("ST NO parece funcionar bien. Hay algún problema con el PC, accu o la address_RAM.  Su nota es %d/900", nota);
    end

    initial begin
        #(memoryDelay + 20 * 7)//416
        if (PC === 12'h01A && accu === 4'hE) begin
            $display("LD parece funcionar bien. PC = 12'h01A, accu = 4'hE. Su nota es %d/900", nota);
        end
        else
            $display("LD parece NO funcionar bien. Puede ser un problema con el PC o con el accu. Su nota es %d/900", nota);
    end

    initial begin
        #(memoryDelay + 20 * 10)//476
        if (PC === 12'h020 && accu === 4'h1) begin
            nota = nota + 80;
            $display("LD parece funcionar bien. PC = 12'h020, accu = 4'h1. Su nota es %d/900", nota);
            $display("Se hicieron 4 ST y LD para determinar si realmente se estaban almacenando datos.");
        end
        else
            $display("LD parece NO funcionar bien. Puede ser un problema con el PC o con el accu. Su nota es %d/900", nota);
    end

    initial begin
        #(memoryDelay + 20 * 12)//516
        if (PC === 12'h023 && accu === 4'h5) begin
            nota = nota + 40;
            $display("NANDM funciona bien. PC = 12'h023, accu = 4'h5. Su nota es %d/900", nota);
        end
        else
            $display("NANDM NO funciona bien. El PC no está en el valor correcto o el accu no tiene el valor correcto. Su nota es %d/900", nota);
    end

    initial begin
        #(memoryDelay + 20 * 14)//556
        if (PC === 12'h026 && accu === 4'h0 && c_flag === 1 && z_flag === 1) begin
            nota = nota + 40;
            $display("ADDM funciona bien. PC = 12'h026, accu = 4'h0, ambas banderas están encendidas. Su nota es %d/900", nota);
        end
        else
            $display("ADDM NO funciona bien. El PC no está en el valor correcto, el accu no tiene el valor correcto o alguna de las banderas está en 0. Su nota es %d/900", nota);
    end

    initial begin
        #(memoryDelay + 20 * 16)//596
        if (PC === 12'h029 && accu === 4'h8 && c_flag === 1 && z_flag === 0) begin
            nota = nota + 20;
            $display("CMPM funciona bien con A < B (1/2). PC = 12'h029, accu = 4'h8, c_flag = 1, z_flag = 0. Su nota es %d/900", nota);
        end
        else
            $display("CMPM NO funciona bien para A < B (1/2). El PC no está en el valor correcto, el accu no tiene el valor correcto, c_flag = 0 ó z_flag = 1. Su nota es %d/900", nota);
    end

    initial begin
        #(memoryDelay + 20 * 18)//636
        if (PC === 12'h02C && accu === 4'hC && c_flag === 0 && z_flag === 0) begin
            nota = nota + 20;
            $display("CMPM funciona bien con A > B (2/2). PC = 12'h02C, accu = 4'hC, c_flag = 0, z_flag = 0. Su nota es %d/900", nota);
        end
        else
            $display("CMPM NO funciona bien para A > B (2/2). El PC no está en el valor correcto, el accu no tiene el valor correcto, c_flag = 1 ó z_flag = 1. Su nota es %d/900", nota);

        $display("\n-----------------------------------------------------------------------------------------------------------------------------");
        $display("Hasta este punto se han verificado todas las instrucciones con inmediatos y memoria RAM. Ahora se verificarán las instrucciones de saltos.");
        $display("La nota máxima (hasta este punto) es 600.\n");

    end

    initial begin
        #(jumpDelay)//276
        if (PC === 12'hA01) begin
            nota = nota + 60;
            $display("JMP funciona bien. Ahora estamos en PC = 12'hA01. Su nota es %d/900", nota);
        end
        else
            $display("JMP NO funciona bien. El PC no está en la localidad 12'HA01.  Su nota es %d/900", nota);
    end

    initial begin
        #(jumpDelay + 20 * 3) //336
        if (PC === 12'h050 && c_flag === 1'b1) begin
            nota = nota + 30;
            $display("JC parece funcionar bien con carry = 1 (1/2). Ahora estamos en PC = 12'h050. Su nota es %d/900", nota);
        end
        else
            $display("JC NO funciona bien. El PC no está en la localidad 12'HA01 ó carry no es 1.  Su nota es %d/900", nota);
    end

    initial begin
        #(jumpDelay + 20 * 6)//396
        if (PC === 12'hF49 && z_flag === 1'b1) begin
            nota = nota + 30;
            $display("JZ parece funcionar bien con zero = 1 (1/2). Ahora estamos en PC = 12'hF49. Su nota es %d/900", nota);
        end
        else
            $display("JZ NO funciona bien. El PC no está en la localidad 12'hA01 ó zero no es 1.  Su nota es %d/900", nota);
    end

    initial begin
        #(jumpDelay + 20 * 9)//456
        if (PC === 12'hF4D && z_flag === 1'b0 && c_flag === 1'b0 && accu === 4'h6) begin
            nota = nota + 30;
            $display("JC parece funcionar bien con carry = 0 (2/2). El PC aumento en +1 en vez de saltar. Su nota es %d/900", nota);
        end
        else
            $display("JC NO funciona bien. El PC saltó a otra localidad ó zero = 1 ó carry =1 ó por alguna razón su accu cambió de valor.  Su nota es %d/900", nota);
    end

    initial begin
        #(jumpDelay + 20 * 10)//476
        if (PC === 12'hF4F && z_flag === 1'b0 && c_flag === 1'b0 && accu === 4'h6) begin
            nota = nota + 30;
            $display("JZ parece funcionar bien con zero = 0 (2/2). El PC aumento en +1 en vez de saltar. Su nota es %d/900", nota);
        end
        else
            $display("JZ NO funciona bien. El PC saltó a otra localidad ó zero = 1 ó carry =1 ó por alguna razón su accu cambió de valor.  Su nota es %d/900", nota);
    end

    initial begin
        #(jumpDelay + 20 * 11)//496
        if (PC === 12'h223 && z_flag === 1'b0 && c_flag === 1'b0 && accu === 4'h6) begin
            nota = nota + 30;
            $display("JNC parece funcionar bien con carry = 0 (1/2). El PC = 12'h223, c_flag = 0, z_flag = 0, accu = 4'h6. Su nota es %d/900", nota);
        end
        else
            $display("JNC NO funciona bien (1/2). El PC no está en 12'h223, alguna bandera está encendida o el accu cambió por alguna razón. Su nota es %d/900", nota);
    end

    initial begin
        #(jumpDelay + 20 * 13)//536
        if (PC === 12'h225 && z_flag === 1'b0 && c_flag === 1'b1 && accu === 4'hA) begin
            nota = nota + 30;
            $display("JNC parece funcionar bien con carry = 1 (2/2). El PC = 12'h225, c_flag = 1, z_flag = 0, accu = 4'hA. Su nota es %d/900", nota);
        end
        else
            $display("JNC NO funciona bien (2/2). El PC sí cambió con la bandera carry encendida o el accu cambió por alguna razón. Su nota es %d/900", nota);
    end

    initial begin
        #(jumpDelay + 20 * 15)//576
        if (PC === 12'h543 && z_flag === 1'b0 && c_flag === 1'b1 && accu === 4'hA) begin
            nota = nota + 30;
            $display("JNZ parece funcionar bien con zero = 0 (1/2). El PC = 12'h543, c_flag = 1, z_flag = 0, accu = 4'hA. Su nota es %d/900", nota);
        end
        else
            $display("JNZ NO funciona bien (1/2). El PC no cambió con la bandera zero apagada o el accu cambió por alguna razón. Su nota es %d/900", nota);
    end

    initial begin
        #(jumpDelay + 20 * 17)//616
        if (PC === 12'h546 && z_flag === 1'b1 && c_flag === 1'b0 && accu === 4'h0) begin
            nota = nota + 30;
            $display("JNZ parece funcionar bien con zero = 0 (2/2). El PC = 12'h546, c_flag = 0, z_flag = 1, accu = 4'h0. Su nota es %d/900", nota);
        end
        else
            $display("JNZ NO funciona bien (2/2). El PC sí cambió con la bandera zero encendida o el accu cambió por alguna razón. Su nota es %d/900", nota);

        $display("\n-----------------------------------------------------------------------------------------------------------------------------");
        $display("Esta última sección de pruebas verificó las instrucciones con saltos. Este es el final del testbench y de su proyecto");
        $display("Su nota final es: %d/900.\n", nota);
    end

    initial begin
        #999
        if (nota == 900) begin
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8i.  .,ifG@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@0,       .;L8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@G.          i0@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@f            :0@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@i             1@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@0,             .0@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@L               L@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8;               L@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@L                C@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@G,               ,0@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@G:                t@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8f,                ;8@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8L;                 :0@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Gt:                  :0@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Ci.                   :0@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@81.                    :0@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8i                     ,G@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@t                     .L@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@L.                     i@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@C.                      f@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@C,                       iCCLLLLLLLLLLLLLLLLLLCCCGG088@@@@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@G,                                               ....,:iL8@@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@C,                                                        :L@@@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@L,                                                          .10@");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8t.                                                             ;0");
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@G;                                                                ;");
        $display("@@@888888888888888@@@@@@@@@@@@@0t,                                                                 ,");
        $display("0f;,,,,,,,,,,,,,,,;f8@@@@8880C1,                                                                  ;G");
        $display(":                   i8@@8i,,.                                                                   .f8@");
        $display(":                   ,8@@8:                                                                      i@@@");
        $display(":                   ,8@@8:                                                                      ,C@@");
        $display(":                   ,8@@8:                                                                       ,L@");
        $display(":                   ,8@@8:                                                                        .t");
        $display(":                   ,8@@8:                                                                         ,");
        $display(":                   ,8@@8:                                                                       .iG");
        $display(":                   ,8@@8:                                                                      :L@@");
        $display(":                   ,8@@8:                                                                     ;8@@@");
        $display(":                   ,8@@8:                                                                     i@@@@");
        $display(":                   ,8@@8:                                                                     .f@@@");
        $display(":                   ,8@@8:                                                                      .C@@");
        $display(":                   ,8@@8:                                                                       i@@");
        $display(":                   ,8@@8:                                                                      ,L@@");
        $display(":                   ,8@@8:                                                                    .1G@@@");
        $display(":                   ,8@@8:                                                                  .1G@@@@@");
        $display(":                   ,8@@8:                                                                 ,C@@@@@@@");
        $display(":                   ,8@@8:                                                                 ;@@@@@@@@");
        $display(":                   ,8@@8:                                                                 ;@@@@@@@@");
        $display(":                   ,8@@8:                                                                 1@@@@@@@@");
        $display(":                   ,8@@8:                                                               .t8@@@@@@@@");
        $display(":                   i8@@@Lt1i;:,..                                                     .1G@@@@@@@@@@");
        $display("0f;,,,,,,,,,,,,,,:;f8@@@@@@@@@800GCLfti;::,..                                       .;f0@@@@@@@@@@@@");
        $display("@@@800000000000008@@@@@@@@@@@@@@@@@@@@@@880GCLft11ii;;::,,,.....           ...,::i1fG8@@@@@@@@@@@@@@");
        end
    end

endmodule
