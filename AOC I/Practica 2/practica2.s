    AREA datos, DATA, READWRITE
long    EQU 1024   
tabla	SPACE long*2
	
    AREA prog, CODE, READONLY
    ENTRY
	
    mov r0, #0			;Del 1 al 1024
    
    ldr r2, =tabla		;direccion base
buc	strh r0, [r2], #2
    add r0, r0, #1
    cmp r0, #long
    bne buc
    
       
fin	b fin

    END 