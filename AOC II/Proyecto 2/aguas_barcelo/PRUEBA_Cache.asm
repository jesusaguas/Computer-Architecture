CODIGO PRUEBA
ini:
    LW R1, 0(R0)                //R1=@0 (read miss)
    LW R2, 4(R0)                //R2=@4 (read hit + load uso)
    ADD R3, R2, R1              //R3= @0+@4 (load uso)

    SW R3, 32(R0)               //@32 = @0 + @4 (write miss)
    SW R3, 8(R0)                //@8 = @0 + @4 (write hit)

EN Binario:
ini:
000010 	00000	00001 	0000000000000000 		LW  R1, 0(R0)  @0
000010 	00000	00010 	0000000000000100 		LW  R2, 4(R0)  @4
000001  00001   00010  00011 00000000000        ADD R3, R2, R1

000011  00000  00011  0000000000100000          SW R3, 32(R0)
000011  00000  00011  0000000000001000          SW R3, 8(R0)


En hexadecimal:
ini:
    08010000        LW  R1, 0(R0)
    08020004        LW  R2, 4(R0)
    04221800        ADD R3, R2, R1

    0C030020        SW R3, 32(R0)
    0C030008        SW R3, 8(R0)


// MEMORIA DE INSTRUCCIONES -> Fichero "memoriaRAM_I_ejemplo_noms.vhd"
