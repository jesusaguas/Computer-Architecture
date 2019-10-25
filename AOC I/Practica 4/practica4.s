	AREA codigo, CODE
	EXPORT ordena

ordena
	mov r2,r0				;iz=T[0]
	sub r3,r1,#1			;r3=N-1
	add r3,r0,r3,lsl#2		;de=T[N-1]
	PUSH {lr}				;guardo direccion de retorno
	PUSH {r2,r3}			;parametros para qksort
	bl qksort
	add sp,sp,#8			;adios parametros
	POP {pc}				;vuelvo al main
	
qksort
	PUSH {fp,lr}
	mov fp,sp				;fp=sp
	PUSH {r0-r3,r12}		;Guardo los registros a usar
	ldr r0,[fp,#8]			;i=iz
	ldr r1,[fp,#12]			;j=de
	sub r2,r1,r0			;de-iz
	lsr r2,r2,#1			;(de-iz)/2
	bic r2,r2,#0x2			;fuerzo el alineamiento
	ldr r2,[r0,r2]			;x=T[(iz+de)/2]
	
dow	ldr r12,[r0]			;utilizamos el scrath register para almacenar T[i]
	cmp r12,r2
	bge buc					;¿T[i]<x?
	add r0,r0,#4			;i=i+1
	b dow

buc	ldr r12,[r1]			;utilizamos el scrath register para almacenar T[j]
	cmp r2,r12
	bge iff					;¿x<T[j]?
	sub r1,r1,#4			;j=j-1
	b buc
	
iff	cmp r0,r1
	bgt go					;¿i<=j?
	ldr r3,[r0]				;w=T[i]
	ldr r12,[r1]			;utilizamos el scrath register para almacenar T[j]
	str r12,[r0]			;T[i]=T[j]
	str r3,[r1]				;T[j]=w
	add r0,r0,#4			;i=i+1
	sub r1,r1,#4			;j=j-1
	
go	cmp r0,r1
	bgt rec1				;¿i<=j?
	b	dow
	
rec1
	ldr r3,[fp,#8]			;r3=iz
	cmp r3,r1
	bge rec2				;¿iz<j?
	PUSH {r0}				;necesario preservarlo
	PUSH {r1}				;pasamos los parametros (j)
	PUSH {r3}				;por la pila			(iz)
	bl qksort
	add sp,sp,#8			;nos saltamos los parametros
	POP {r0}				;lo recuperamos, lo necesitamos para rec2
	
rec2
	ldr r3,[fp,#12]			;r3=de
	cmp r0,r3
	bge bye					;¿i<de?
	PUSH {r0,r3}			;pasamos parametros por pila(r0=i,r3=de)
	bl qksort
	add sp,sp,#8			;nos saltamos los parametros

bye
	POP {r0-r3,r12}		;Recupero los registros utilizados
	POP {fp,pc}				;volvemos
	
    END 