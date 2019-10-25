CODIGO PRUEBA PREDICCIÓN SALTOS(FORZANDO SIEMPRE ERROR DE SALTO)

ini:
    LW R1, 0(R0)                //R1=0x1
    LA R2, 0(R1)                //R2=0x1
    LA R5, 8(R0)                //R5=8

buc:
    BEQ R1, R5, endbuc
    ADD R1, R2, R1
    SW  R1, 4(R1)
    BNE R5, R5, buc
endbuc:
        //R1= 0x8

EN Binario:

000010 	00000	00001 	0000000000000000 		LW  R1, 0(R0)  @0
001000  00001   00010   0000000000000000 		LA R2, 0(R1)
001000  00000   00101   0000000000001000 		LA R5, 8(R0)

000100  00001   00101   0000000000000100        BEQ R1, R5, endbuc
000001  00010   00001   00001 00000000000       ADD R1, R2, R1
000011  00001   00001   0000000000000000        SW  R1, 0(R1)
000101  00010   00101   1111111111111100        BNE R2, R5, buc

En hexadecimal:

08010000        LW  R1, 0(R0)
20220000        LA R2, 0(R1)
20050008        LA R5, 8(R0)
buc:
10250004        BEQ R1, R5, endbuc
04410800        ADD R1, R2, R1
0c210000        SW  R1, 0(R1)
1445FFFC        BNE R2, R5, buc
endbuc:


CODIGO PRUEBA PREDICCIÓN SALTOS(SUMA LOS N PRIMEROS NUMEROS. INTRODUCIR N EN LA DIRECCIÓN @4 DE MEMORIA)
ini:
    LW R1, 0(R0)                //R1=0x1
    LA R3, 0(R0)                //R3=0x0; R3->Iterador
    LW R2, 4(R0)                //R2=@4 Número a introducir para hacer la suma.
    BEQ R3, R2, endbuc          //R0=Resultado

buc:
    ADD R3, R3, R1              //R3=R3+1
    ADD R0, R0, R3              //R0=resultado hasta la iteración "r3"
    BNE R3, R2, buc             //Si R2=R3 acaba la ejecucion
endbuc:
    SW R0, 0(R4)                //@0=resultado

EN Binario:

000010 	00000	00001 	0000000000000000 		LW  R1, 0(R0)  @0
001000  00000   00011   0000000000000000        LA R3, 0(R0)
000010  00000   00010   0000000000000100        LW R2, 4(R0)
000100  00011   00010   0000000000000100        BEQ R3, R2, endbuc

000001  00011  00001  00011 00000000000         ADD R3, R3, R1
000001  00000  00011  00000 00000000000         ADD R0, R0, R3
000101  00011  00010  1111111111111101          BNE R3, R2, buc

000011  00100  00000  0000000000000000          SW R0, 0(R4)

En hexadecimal:
ini:
    08010000        LW  R1, 0(R0)
    20030000        LA R3, 0(R0)
    08020004        LW R2, 4(R0)
    10620004        BEQ R3, R2, endbuc
buc:
    04611800        ADD R3, R3, R1
    04030000        ADD R0, R0, R3
    1462FFFD        BNE R3, R2, buc
endbuc:
    0C800000        SW R0, 0(R4)
