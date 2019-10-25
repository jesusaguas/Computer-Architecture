    AREA datos, DATA, READWRITE
long    EQU 7*4   
serie   DCD 1, 2, 4, 6, 8, 7, 9
resul	DCB 0
    AREA prog, CODE, READONLY

    ENTRY
    mov r0, #0
    eor r1, r1, r1  ;result variable
    
    ldr r2, =serie
bum	ldr r3, [r2, r0]
    add r1, r1, r3
    add r0, r0, #4
    cmp r0, #long
    bne bum
    
    ldr r2, =resul
    str r1, [r2]
       
fid	b fid

    END 