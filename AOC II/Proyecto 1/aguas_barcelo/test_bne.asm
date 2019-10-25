CODIGO PRUEBA INSTRUCCIÓN BNE(SIN RIESGOS)

ini:
    LW R1, 0(R0);               //R1=0x1
    LW R2, 4(R0);               //R2=0xF
    NOP
    NOP
    BNE R1,R2,ini

EN Binario:

000010 	00000	00001 	0000000000000000 		LW  R1, 0(R0)  @0
000010 	01000	00010 	0000000000000100 		LW  R2, 4(R0)  @4
000000  00000   00000   0000000000000000        NOP
000000  00000   00000   0000000000000000        NOP
000101  00001   00010   1111111111111011        BNE R1,R2,ini


En hexadecimal:

		08010000      LW  R1, 0(R0)
		09020004      LW  R2, 0(r0)
        00000000      NOP
        00000000      NOP
        1422FFFB      BEQ R1, R2, ini


CODIGO PRUEBA INSTRUCCIÓN BNE(CON RIESGOS)
ini:
    LW R1, 0(R0);               //R1=0x1
    LW R2, 4(R0);               //R2=0xF
    BNE R1,R2,ini

EN Binario:

000010 	00000	00001 	0000000000000000 		LW  R1, 0(R0)  dir 0
000010 	01000	00010 	0000000000000100 		LW  R2, 4(R8)  dir 4
000101  00001   00010   1111111111111101        BNE R1,R2,ini

En hexadecimal:

		08010000      LW  R1, 0(R0)
		09020004      LW  R2, 0(r0)
        1422FFFD      BEQ R1, R2, ini
