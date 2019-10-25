		AREA datos,DATA
;variables y constantes

;Control de interrupciones
VICIntEnable 	EQU 0xFFFFF010		;Habilita las interrupciones del VIC
VICIntEnClr 	EQU 0xFFFFF014		;Deshabilita las interrupciones del VIC

IRQ_I4			EQU 4				;Nº de IRQ del Timer 0	(reloj)
IRQ_I7			EQU 7				;Nº de IRQ de la UART 1 (teclado)
I_Bit			EQU 0x80			;bit 7 de la CPSR, a 1 inhibe las interrupciones IRQ

VICVectAddr0 	EQU 0xFFFFF100		;Guarda la direccion de la RSI_IRQ0
VICVectAddr	 	EQU 0xFFFFF030		;Registro que al escribir desactiva la petición de interrupción del periférico

IOSET			EQU 0xE0028004		;Registro de datos del GPIO. Escribiendo 1’s se activan sus bits
IOCLR			EQU 0xE002800C		;Registro de datos del GPIO. Escribiendo 1’s se desactivan los bits del IOSET
T0_IR			EQU 0xE0004000		;Registro de control del Timer0 que al escribir un 1 baja la peticion
TEC_DAT			EQU	0xE0010000		;Registro de datos del teclado, sirve para leer la tecla y bajar la peticion

;Direcciones relativas a la pantalla
MARCADOR		EQU 0x40007E00		;Direccion del marcador
UP   			EQU 0x40007E20		;Direccion de la cota superior de la pantalla
MID				EQU 0x40007EEC		;Direccion de la mitad de la pantalla
DOWN			EQU 0x40007FFF		;Direccion de la cota inferior de la pantalla
MARCVIDAS		EQU 0x40007E07		;Direccion del marcador de vidas
MARCPUNTOS		EQU 0x40007E1A		;Direccion del marcador de puntos
arrobapos1		EQU 0x40007EEF		;Direccion inicial del arroba
arrobapos2		EQU 0x40007EF0		;Direccion inicial del arroba
arrobapos3		EQU 0x40007F0F		;Direccion inicial del arroba
arrobapos4		EQU 0X40007F10		;Direccion inicial del arroba
arroba			DCD 0				;Direccion actual del arroba
fantasma1		DCD	0				;Direccion actual del fantasma 1
fantasma2		DCD	0				;Direccion actual del fantasma 2
fantasma3		DCD	0				;Direccion actual del fantasma 3
fantasma4		DCD	0				;Direccion actual del fantasma 4

;Variables auxiliares para el correcto del funcionamiento del juego
ticspacman		DCB 0				;cuenta los tics de pacman
ticsfantasma	DCB 0				;cuenta los tics del movimiento de los fantasmas
ticsnextfant	DCB 0				;cuenta los tics para el siguiente fantasma
ticsdisparo		DCB 0				;cuenta los tics de un disparo
objfant1		DCB 0				;Guarda el elemento en el que se encuentra situado
objfant2		DCB 0				;Guarda el elemento en el que se encuentra situado
objfant3		DCB 0				;Guarda el elemento en el que se encuentra situado
objfant4		DCB 0				;Guarda el elemento en el que se encuentra situado
menswin			DCB "YOU WIN!"		;Mensaje al ganar el juego
menslose		DCB "YOU LOSE"		;Mensaje al perder el juego
mensquit		DCB "YOU QUIT"		;Mensaje al abandonar el juego
mensajevidas	DCB "VIDAS"			;Mensaje del marcador
mensajepuntos	DCB "PUNTOS"		;Mensaje del marcador
tokens			DCB 0				;Numero de tokens cogidos
unidades		DCB 0				;Lleva la cuenta de puntos
decenas			DCB 0				;Lleva la cuenta de puntos
centenas		DCB 0				;Lleva la cuenta de puntos
numfantasmas	DCB 0				;Numero de fantasmas(*) actualmente en el juego
randomnextfant	DCB 0				;tiempo aleatorio para el próximo fantasma(*)
dirx			DCB	0				;mov. horizontal arroba (-1 izda.,0 stop, 1 der.)
diry			DCB	0				;mov. vertical arroba (-1 arriba,0 stop,1 abajo)
tecla	 		DCB 0				;guarda la tecla pulsada en la interrupcion del teclado
mask9			EQU 0x1FF			;mascara que habilita solo los 9 bits menos significativos
	
fin				DCB	0				;indicador fin de programa (si vale 1)

;Variables que se pueden modificar para cambiar los requisitos del juego
velpacman		DCB 1				;Velocidad inicial del pacman(@)		(1-128)
velfantasmas	DCB 16				;Velocidad inicial de los fantasmas(*)	(1-128)

vidas			DCB 3				;Numero de vidas
tokens2win		DCB 100				;Numero de tokens para ganar(maximo 255)

;CODIGO
		AREA codigo,CODE
		EXPORT inicio			; forma de enlazar con el startup.s
		IMPORT srand			; para poder invocar SBR srand
		IMPORT rand				; para poder invocar SBR srand
			
inicio
;Generamos numeros aleatorios
		ldr r0,=T0_IR				;crearemos la semilla con T0_IR
		PUSH {r0}					;parametro por pila a srand
		bl srand
		sub sp, sp,#4				;reservamos espacio para el resultado
		bl rand
		POP {r0}					;obtenemos el primer numero aleatorio
		ldr r1,=randomnextfant
		and r0,r0,#0x7F
		add r0,r0,#8
		strb r0,[r1]

;Dibujamos la pantalla inicial	
;Rellenamos toda la pantalla
		LDR r0,=UP
		LDR r1,=DOWN
		mov r2,#'.'
screen	cmp r0,r1					;Desde UP hasta DOWN escribimos '.'
		bgt marcadr
		strb r2,[r0],#1
		b screen
;Añadimos un marcador
marcadr	LDR r0,=MARCADOR
		LDR r1,=UP
		mov r2,#' '
bucmarc	cmp r0,r1					;Desde MARCADOR hasta UP escribimos ' '
		bge vd
		strb r2,[r0],#1
		b bucmarc
		
vd		LDR r0,=MARCADOR
		LDR r1,=mensajevidas
		mov r3,#0
printvd	cmp r3,#5					;Escribimos 'VIDAS'
		beq numvds
		ldrb r2,[r1],#1
		strb r2,[r0],#1
		add r3,r3,#1
		b printvd
numvds	LDR r0,=MARCVIDAS
		LDR r1, =vidas				;Numero de vidas
		ldrb r1,[r1]
		add r1,r1,#48				;pasamos a codigo ASCII
		strb r1,[r0]
		b pts
		
pts		LDR r0,=MARCADOR
		LDR r1,=mensajepuntos
		add r0,r0,#0x10
		mov r3,#0
printpt	cmp r3,#6					;Escribimos 'PUNTOS'
		beq numpts
		ldrb r2,[r1],#1
		strb r2,[r0],#1
		add r3,r3,#1
		b printpt
numpts	LDR r0,=MARCPUNTOS
		LDR r1,=unidades		;Numero de unidades(puntos)
		ldrb r1,[r1]
		add r1,r1,#48			;pasamos a codigo ASCII
		strb r1,[r0],#-1
		LDR r1,=decenas			;Numero de decenas(puntos)
		ldrb r1,[r1]
		add r1,r1,#48			;pasamos a codigo ASCII
		strb r1,[r0],#-1
		LDR r1,=centenas		;Numero de centenas(puntos)
		ldrb r1,[r1]
		add r1,r1,#48			;pasamos a codigo ASCII
		strb r1,[r0]
		LDR r1,=unidades
		ldrb r1,[r1]
		add r1,r1,#48			;pasamos a codigo ASCII
		strb r1,[r0]
		b start
		
start
;Insertamos el @ en el juego
		sub sp,sp,#4
		bl rand
		POP {r0}
		and r0,r0,#0x3				;numero aleatorio del 0 al 3
		mov r1,#'@'
		cmp r0,#0					;Si es 0
		ldreq r2,=arrobapos1
		strbeq r1,[r2]
		ldreq r1,=arroba
		streq r2,[r1]
		cmp r0,#1					;Si es 1
		ldreq r2,=arrobapos2
		strbeq r1,[r2]
		ldreq r1,=arroba
		streq r2,[r1]
		cmp r0,#2					;Si es 2
		ldreq r2,=arrobapos3
		strbeq r1,[r2]
		ldreq r1,=arroba
		streq r2,[r1]
		cmp r0,#3					;Si es 3
		ldreq r2,=arrobapos4
		strbeq r1,[r2]
		ldreq r1,=arroba
		streq r2,[r1]

;Actualiza el vector de interrupciones para que @IRQ4 -> RSI_reloj
		ldr r0, =VICVectAddr0
		ldr r1, =RSI_reloj
		mov r2, #IRQ_I4
		str r1, [r0,r2,LSL#2]

;Actualiza el vector de interrupciones para que @IRQ7 -> RSI_teclado
		ldr r0, =VICVectAddr0
		ldr r1, =RSI_teclado
		mov r2, #IRQ_I7
		str r1, [r0,r2,LSL#2]

;Habilita las interrupciones IRQ4,IRQ7
		ldr r0, =VICIntEnable
		ldr r1, [r0]
		orr r1, r1, #1<<IRQ_I4
		orr r1, r1, #1<<IRQ_I7
		str r1, [r0]
		
		
;codigo a ejecutar
bucle	
;Refrescamos los numeros aleatorios, para que no se repita la misma secuencia.
		sub sp,sp,#4
		bl rand
		add sp,sp,#4
;Miramos si hay que añadir un fantasma
		ldr r0,=ticsnextfant
		ldrb r0,[r0]
		ldr r1,=randomnextfant
		ldrb r1,[r1]
		cmp r0,r1					;NUEVO FANTASMA si tics=nextfantasma 
		blt pacmove
		ldr r0,=numfantasmas
		ldrb r0,[r0]
		cmp r0,#4
		bllt newfantasma
		b pacmove
		
;Subrutina para añadir un fantasma al juego
newfantasma
		PUSH {lr}
		PUSH {r0-r4}
	;Incrementamos el numero de fantasmas
		LDR r0,=numfantasmas			
		ldrb r1,[r0]
		add r1,r1,#1
		strb r1,[r0]
	;Posicion inicial aleatoria
repeat	sub sp,sp,#4
		bl rand
		POP {r0}
		ldr r1,=mask9						;r1=mascara que habilita los 9 primeros bits
		and r0,r0,r1						;r0=offset aleatorio entre 0-512 (9 bits)
		cmp r0,#480
		bge repeat
		ldr r1,=UP							;r1=direccion base de la pantalla
		add r1,r1,r0						;posicion del nuevo fantasma(base+offset)
		ldrb r2,[r1]						;Cargamos el contenido que hay
		mov r3,#'.'							;¿Habia un punto anteriormente?
		cmp r3,r2							;Comparamos
		moveq r4,r3							;Guardamos en r4 el contenido anterior a colocar el fantasma
		mov r3,#' '							;¿Habia un espacio anteriormente?
		cmp r3,r2							;Comparamos
		moveq r4,r3							;Guardamos en r3 el contenido anterior a colocar el fantasma
		mov r3,#'*'							;r2=asterisco
		strb r3,[r1]						;añadimos el fantasma en la pantalla
		ldr r0,=numfantasmas
		ldrb r0,[r0]
		cmp r0,#1							;Si newfantasma = 1
		ldreq r2,=fantasma1					;Guardamos la direccion actual del fantasma 1
		streq r1,[r2]
		ldreq r2,=objfant1					;Guardamos el contenido anterior
		strbeq r4,[r2]
		cmp r0,#2							;Si newfantasma = 2
		ldreq r2,=fantasma2					;Guardamos la direccion actual del fantasma 2
		streq r1,[r2]
		ldreq r2,=objfant2					;Guardamos el contenido anterior
		strbeq r4,[r2]
		cmp r0,#3							;Si newfantasma = 3
		ldreq r2,=fantasma3					;Guardamos la direccion actual del fantasma 3
		streq r1,[r2]
		ldreq r2,=objfant3					;Guardamos el contenido anterior
		strbeq r4,[r2]
		cmp r0,#4							;Si newfantasma = 4
		ldreq r2,=fantasma4					;Guardamos la direccion actual del fantasma 4
		streq r1,[r2]
		ldreq r2,=objfant4					;Guardamos el contenido anterior
		strbeq r4,[r2]
	;Preparo al siguiente fantasma
		LDR r0,=ticsnextfant
		mov r1,#0							;Reinicio el numero de tics para el siguiente fantasma
		strb r1,[r0]
		sub sp, sp,#4						;reservamos espacio para el resultado
		bl rand
		POP {r0}							;obtenemos el numero aleatorio
		LDR r1,=randomnextfant
		and r0,r0,#0x7F
		add r0,r0,#8
		strb r0,[r1]
	;Volvemos
		POP {r0-r4}
		POP {pc}
		
		
;¿Movemos a @?
pacmove	LDR r0,=ticspacman
		ldrb r0, [r0]
		LDR r1,=velpacman
		ldrb r1,[r1]
		cmp r0, r1
		blt fantmov
		LDR r0,=dirx
		ldrb r0,[r0]
		cmp r0,#0
		blne mover
		LDR r0,=diry
		ldrb r0,[r0]
		cmp r0,#0
		blne mover
		b fantmov


;Subrutina que mueve el pacman(@)
mover 	PUSH {lr}
		PUSH {r0-r3}
	;Comprobamos si hay movimiento horizontal
		LDR r0,=dirx
		ldrb r0,[r0]
		cmp r0,#0
		beq vertical			;si NO hay movimiento horizontal, salto a mirar el vertical
		cmp r0,#-1				;SI hay,
		beq izq						;¿Se mueve a la izquierda?
		cmp r0,#1					;¿Se mueve a la derecha?
		beq der		
	;Movimiento a la izquierda
izq		LDR r0,=arroba
		ldr r1,[r0]
		LDR r2,=UP					;Que no se escape por arriba
		cmp r1,r2
		beq finmov
		mov r3,#' '					;Pongo un espacio en la posicion del arroba
		strb r3,[r1],#-1			;y actualizo a la nueva posicion
		mov r3,#'.'
		ldrb r2,[r1]
		cmp r3,r2					;Miro si a donde voy hay un token
		PUSH {r0,r1}
		bleq addtok					;Si lo hay, salto a 'añadir token'
		POP	{r0,r1}
		mov r3,#'@'					;Pongo @ en la nueva posicion
		strb r3,[r1]					
		str r1,[r0]					;Guardo la nueva posicion de @
		b finmov
	;Movimiento a la derecha
der		LDR r0,=arroba
		ldr r1,[r0]
		ldr r2,=DOWN				;Que no se escape por abajo
		cmp r1,r2
		beq finmov
		mov r3,#' '					;Pongo un espacio en la posicion del arroba
		strb r3,[r1],#1
		mov r3,#'.'
		ldrb r2,[r1]
		cmp r3,r2					;Miro si a donde voy hay un token
		PUSH {r0,r1}
		bleq addtok					;Si lo hay, salto a 'añadir token'
		POP	{r0,r1}
		mov r3,#'@'					;Pongo @ en la nueva posicion
		strb r3,[r1]					
		str r1,[r0]					;Guardo la nueva posicion de @
		b finmov	
	;Comprobamos si hay movimiento vertical
vertical
		LDR r0,=diry
		ldrb r0,[r0]
		cmp r0,#0
		beq finmov				;si NO hay movimiento vertical salto a finalizar
		cmp r0,#-1				;SI hay,	
		beq arriba					;¿Se mueve arriba?
		cmp r0,#1
		beq abajo					;¿Se mueve abajo?
	;Movimiento hacia arriba
arriba	LDR r0,=arroba
		ldr r1,[r0]
		ldr r2,=UP					;Que no se escape por arriba
		add r2,r2,#0x20
		cmp r1,r2
		blt finmov
		mov r3,#' '					;Pongo un espacio en la posicion del arroba
		strb r3,[r1],#-0x20
		mov r3,#'.'
		ldrb r2,[r1]
		cmp r3,r2					;Miro si a donde voy hay un token
		PUSH {r0,r1}
		bleq addtok					;Si lo hay, salto a 'añadir token'
		POP	{r0,r1}
		mov r3,#'@'					;Pongo @ en la nueva posicion
		strb r3,[r1]				;Escribo el @					
		str r1,[r0]					;Guardo la nueva posicion de @
		b finmov
	;Movimiento hacia abajo
abajo	LDR r0,=arroba
		ldr r1,[r0]
		ldr r2,=DOWN				;Que no se escape por abajo
		sub r2,r2,#0x20
		cmp r1,r2
		bgt finmov
		mov r3,#' '					;Pongo un espacio en la posicion del arroba
		strb r3,[r1],#0x20
		mov r3,#'.'
		ldrb r2,[r1]
		cmp r3,r2					;Miro si a donde voy hay un token
		PUSH {r0,r1}
		bleq addtok					;Si lo hay, salto a 'añadir token'
		POP	{r0,r1}
		mov r3,#'@'					;Pongo @ en la nueva posicion
		strb r3,[r1]					
		str r1,[r0]					;Guardo la nueva posicion de @
		b finmov
	;Finalizacion del movimiento
finmov	mov r1,#0
		LDR r0,=ticspacman			;Reinicializamos los tics
		strb r1,[r0]
		LDR r0,=dirx
		strb r1,[r0]				;Reinicializamos el movimiento
		LDR r0,=diry
		strb r1,[r0]
		LDR r0,=tokens				;Miro si al movernos hemos conseguido
		ldrb r0,[r0]				;el numero máximo de tokens
		LDR r1,=tokens2win
		ldrb r1,[r1]
		cmp r0,r1
		bleq dofinal
	;Volvemos
		POP {r0-r3}
		POP {pc}

;Subrutina que suma un token y actualiza las variables que controlan el marcador de puntos
addtok	PUSH {lr}
		PUSH {r0-r5}
	;Actualizamos variable 'numero de tokens'
		LDR r0,=tokens
		ldrb r1,[r0]
		add r1,r1,#1				;token++
		strb r1,[r0]
	;Actualizamos unidades, decenas y centenas
		LDR r0,=unidades
		ldrb r1,[r0]
		LDR r2,=decenas
		ldrb r3,[r2]
		LDR r4,=centenas
		ldrb r5,[r4]
		add r1,r1,#1				;Sumamos +1 a unidades
		cmp r1,#9
		movgt r1,#0					;Si unidades desbordan (>9)
		addgt r3,r3,#1
		cmp r3,#9
		movgt r3,#0					;Si decenas desbordan (>9)
		addgt r5,r5,#1
		strb r1,[r0]				;Guardamos unidades
		strb r3,[r2]				; decenas
		strb r5,[r4]				; y centenas
	;Volvemos
		POP {r0-r5}
		POP {pc}
		
;¿Movemos a los asteriscos?
fantmov	LDR r0,=ticsfantasma
		ldrb r0,[r0]
		LDR r1,=velfantasmas
		ldrb r1,[r1]
		cmp r0, r1					;¿TOCA MOVER?-- tics = vel??
		blt cuidado
		LDR r4,=numfantasmas		;Numero de fantasmas a mover
		ldrb r4,[r4]
	;Movemos al fantasma 1
		cmp r4,#1					;Existe fantasma 1??
		blt finf
		LDR r0,=fantasma1
		ldr r0,[r0]
		LDR r1,=objfant1
		ldrb r1,[r1]				;Cargamos el contenido anterior
		sub sp,sp,#8				;Reservamos espacio para el resultado
		PUSH {r0,r1}				;Paso de parámetros por pila
		bl movfant					;movemos el fantasma1
		add sp,sp,#8				;Eliminamos los parámetros
		POP {r0,r1}					;Recogemos los resultados
		LDR r2,=fantasma1
		str r0,[r2]					;Guardamos el nuevo contenido anterior
		LDR r3,=objfant1
		strb r1,[r3]				;Guardamos el nuevo contenido anterior
	;Movemos al fantasma 2
		cmp r4,#2					;Existe fantasma 2??
		blt finf
		LDR r0,=fantasma2
		ldr r0,[r0]
		LDR r1,=objfant2
		ldrb r1,[r1]				;Cargamos el contenido anterior
		sub sp,sp,#8				;Reservamos espacio para el resultado
		PUSH {r0,r1}				;Paso de parámetros por pila
		bl movfant					;movemos el fantasma2
		add sp,sp,#8				;Eliminamos los parámetros
		POP {r0,r1}					;Recogemos los resultados
		LDR r2,=fantasma2
		str r0,[r2]					;Guardamos el nuevo contenido anterior
		LDR r3,=objfant2
		strb r1,[r3]				;Guardamos el nuevo contenido anterior
	;Movemos al fantasma 3
		cmp r4,#3					;Existe fantasma 3??
		blt finf
		LDR r0,=fantasma3
		ldr r0,[r0]
		LDR r1,=objfant3
		ldrb r1,[r1]				;Cargamos el contenido anterior
		sub sp,sp,#8				;Reservamos espacio para el resultado
		PUSH {r0,r1}				;Paso de parámetros por pila
		bl movfant					;movemos el fantasma3
		add sp,sp,#8				;Eliminamos los parámetros
		POP {r0,r1}					;Recogemos los resultados
		LDR r2,=fantasma3
		str r0,[r2]					;Guardamos el nuevo contenido anterior
		LDR r3,=objfant3
		strb r1,[r3]				;Guardamos el nuevo contenido anterior
	;Movemos al fantasma 4
		cmp r4,#4					;Existe fantasma 4??
		blt finf
		LDR r0,=fantasma4
		ldr r0,[r0]
		LDR r1,=objfant4
		ldrb r1,[r1]				;Cargamos el contenido anterior
		sub sp,sp,#8				;Reservamos espacio para el resultado
		PUSH {r0,r1}				;Paso de parámetros por pila
		bl movfant					;movemos el fantasma4
		add sp,sp,#8				;Eliminamos los parámetros
		POP {r0,r1}					;Recogemos los resultados
		LDR r2,=fantasma4
		str r0,[r2]					;Guardamos el nuevo contenido anterior
		LDR r3,=objfant4
		strb r1,[r3]				;Guardamos el nuevo contenido anterior
		
finf	mov r1,#0
		LDR r0,=ticsfantasma			;Reinicializamos los tics
		strb r1,[r0]
		b cuidado

;Subrutina que dado un fantasma(*) lo mueve aleatoriamente
;Recibe 2 parámetros por pila y devuelve los 2 resultados por pila
movfant PUSH {lr,fp}
		mov fp,sp
		PUSH {r0-r3}
	;Para todos los fantasmas
		sub sp,sp,#4
		bl rand
		POP {r0}
		and r0,r0,#3					;Numero aleatorio de 0 a 3, 0->izq, 1->der, 2->arriba, 3->abajo
		cmp r0,#0
		beq movleft						;0->izq
		cmp r0,#1
		beq movrigt						;1->der
		cmp r0,#2
		beq movup						;2->arriba
		cmp r0,#3
		beq movdown						;3->abajo
	;Movemos el fantasma a la izquierda
movleft	ldr r0,[fp,#8]					;Cargamos la direccion del fantasma
		ldrb r1,[fp,#12]				;Cargamos el contenido anterior
		LDR r2,=UP
		cmp r0,r2						;Que no se escape por arriba
		strbeq r1,[fp,#20]				;Y lo guardamos como resultado
		streq r0,[fp,#16]				;También guardamos la nueva direccion
		beq endmov
		mov r3,#'@'
		cmp r1,r3						;Si anteriormente habia estba pacman(@) pones un espacio
		moveq r1,#' '
		mov r3,#'*'
		cmp r1,r3						;Si anteriormente habia un fantasma(*) pones un espacio
		moveq r1,#' '
		strb r1,[r0],#-1				;Escribimos el contenido anterior y actualizamos la nueva posicion
		ldrb r1,[r0]					;Cargamos el contenido de la nueva direccion
		strb r1,[fp,#20]				;Y lo guardamos como resultado
		str r0,[fp,#16]					;También guardamos la nueva direccion
		mov r3,#'*'
		strb r3,[r0]					;Escribimos al fantasma(*) en la nueva posicion
		b endmov
	;Movemos el fantasma a la derecha
movrigt	ldr r0,[fp,#8]					;Cargamos la direccion del fantasma
		ldrb r1,[fp,#12]				;Cargamos el contenido anterior
		LDR r2,=DOWN
		cmp r0,r2						;Que no se escape por abajo
		strbeq r1,[fp,#20]				;Y lo guardamos como resultado
		streq r0,[fp,#16]				;También guardamos la nueva direccion
		beq endmov
		mov r3,#'@'
		cmp r1,r3						;Si anteriormente habia estba pacman(@) pones un espacio
		moveq r1,#' '
		mov r3,#'*'
		cmp r1,r3						;Si anteriormente habia un fantasma(*) pones un espacio
		moveq r1,#' '
		strb r1,[r0],#1					;Escribimos el contenido anterior y actualizamos la nueva posicion
		ldrb r1,[r0]					;Cargamos el contenido de la nueva direccion
		strb r1,[fp,#20]				;Y lo guardamos como resultado
		str r0,[fp,#16]					;También guardamos la nueva direccion
		mov r3,#'*'
		strb r3,[r0]					;Escribimos al fantasma(*) en la nueva posicion
		b endmov
	;Movemos el fantasma arriba
movup	ldr r0,[fp,#8]					;Cargamos la direccion del fantasma
		ldrb r1,[fp,#12]				;Cargamos el contenido anterior
		ldr r2,=UP
		add r2,r2,#0x20
		cmp r0,r2						;Que no se escape por arriba
		strblt r1,[fp,#20]				;Y lo guardamos como resultado
		strlt r0,[fp,#16]				;También guardamos la nueva direccion
		blt endmov
		mov r3,#'@'
		cmp r1,r3						;Si anteriormente habia estba pacman(@) pones un espacio
		moveq r1,#' '
		mov r3,#'*'
		cmp r1,r3						;Si anteriormente habia un fantasma(*) pones un espacio
		moveq r1,#' '
		strb r1,[r0],#-0x20				;Escribimos el contenido anterior y actualizamos la nueva posicion
		ldrb r1,[r0]					;Cargamos el contenido de la nueva direccion
		strb r1,[fp,#20]				;Y lo guardamos como resultado
		str r0,[fp,#16]					;También guardamos la nueva direccion
		mov r3,#'*'
		strb r3,[r0]					;Escribimos al fantasma(*) en la nueva posicion
		b endmov
	;Movemos el fantasma abajo
movdown	ldr r0,[fp,#8]					;Cargamos la direccion del fantasma
		ldrb r1,[fp,#12]				;Cargamos el contenido anterior
		ldr r2,=DOWN
		sub r2,r2,#0x20
		cmp r0,r2						;Que no se escape por abajo
		strbgt r1,[fp,#20]				;Y lo guardamos como resultado
		strgt r0,[fp,#16]				;También guardamos la nueva direccion
		bgt endmov
		mov r3,#'@'
		cmp r1,r3						;Si anteriormente habia estba pacman(@) pones un espacio
		moveq r1,#' '
		mov r3,#'*'
		cmp r1,r3						;Si anteriormente habia un fantasma(*) pones un espacio
		moveq r1,#' '
		strb r1,[r0],#0x20				;Escribimos el contenido anterior y actualizamos la nueva posicion
		ldrb r1,[r0]					;Cargamos el contenido de la nueva direccion
		strb r1,[fp,#20]				;Y lo guardamos como resultado
		str r0,[fp,#16]					;También guardamos la nueva direccion
		mov r3,#'*'
		strb r3,[r0]					;Escribimos al fantasma(*) en la nueva posicion
		b endmov
	;Finalizacion del movimiento
endmov
	;Volvemos
		POP {r0-r3}
		POP {pc,fp}



;Miro si un fantasma ha pillado a pacman
cuidado LDR r0,=arroba
		ldr r0,[r0]
	;Compruebo fantasma 1
		LDR r1,=fantasma1
		ldr r1,[r1]
		cmp r0,r1
		bleq pillado
	;Compruebo fantasma 2
		LDR r1,=fantasma2
		ldr r1,[r1]
		cmp r0,r1
		bleq pillado
	;Compruebo fantasma 3
		LDR r1,=fantasma3
		ldr r1,[r1]
		cmp r0,r1
		bleq pillado
	;Compruebo fantasma 4
		LDR r1,=fantasma4
		ldr r1,[r1]
		cmp r0,r1
		bleq pillado
		b teclas

;Upss.. El fantasma te ha pillado
	;Una vida menos
pillado PUSH {lr}
		PUSH {r0-r2}
		LDR r0,=vidas
		ldrb r1,[r0]
		sub r1,r1,#1
		strb r1,[r0]
		cmp r1,#0
	;Si es la última FIN DEL JUEGO
		bleq dofinal
	;Sino reinicio el pacman y los fantasmas
		;Borramos el @ de su posicion actual
		LDR r0,=arroba
		ldr r0,[r0]
		mov r1,#' '
		strb r1,[r0]
		;Insertamos el @ en el juego
		sub sp,sp,#4
		bl rand
		POP {r0}
		and r0,r0,#0x3				;numero aleatorio del 0 al 3
		mov r1,#'@'
		cmp r0,#0					;Si es 0
		ldreq r2,=arrobapos1
		strbeq r1,[r2]
		ldreq r1,=arroba
		streq r2,[r1]
		cmp r0,#1					;Si es 1
		ldreq r2,=arrobapos2
		strbeq r1,[r2]
		ldreq r1,=arroba
		streq r2,[r1]
		cmp r0,#2					;Si es 2
		ldreq r2,=arrobapos3
		strbeq r1,[r2]
		ldreq r1,=arroba
		streq r2,[r1]
		cmp r0,#3					;Si es 3
		ldreq r2,=arrobapos4
		strbeq r1,[r2]
		ldreq r1,=arroba
		streq r2,[r1]
	;Volvemos
		POP	{r0-r2}
		POP {pc}
		
			
		
;Comprubo si se ha pulsado alguna tecla
teclas	LDR r0,=tecla
		ldrb r0,[r0]
 		cmp r0,#0
		blne newtecl
		b update
		
		
;Subrutina que analiza la tecla pulsada
newtecl PUSH {lr}
		PUSH {r0-r2}
	;Miro que tecla se ha pulsado
		LDR r0,=tecla				;Cargo la tecla pulsada
		ldrb r0,[r0]
a		cmp r0,#'A'					;Si es A
		bne d
		mov r1,#-1						;dirx = -1
		LDR r2,=dirx
		strb r1,[r2]
		b fintecl
d		cmp r0,#'D'					;Si es D
		bne w
		mov r1,#1						;dirx = 1
		LDR r2,=dirx
		strb r1,[r2]
		b fintecl
w		cmp r0,#'W'					;Si es W
		bne s
		mov r1,#-1						;diry = -1
		LDR r2,=diry
		strb r1,[r2]
		b fintecl
s		cmp r0,#'S'					;Si es S
		bne mas
		mov r1,#1						;diry = 1
		LDR r2,=diry
		strb r1,[r2]
		b fintecl
mas		cmp r0,#'+'					;Si es +
		bne menos
		LDR r1,=velpacman				;velpacman++
		ldrb r2,[r1]
		cmp r2,#1
		beq fintecl
		mov r2,r2,LSR#1
		strb r2,[r1]
		b fintecl	
menos	cmp r0,#'-'					;Si es -
		bne plus
		LDR r1,=velpacman				;velpacman--
		ldrb r2,[r1]
		cmp r2,#128
		beq fintecl
		mov r2,r2,LSL#1
		strb r2,[r1]
		beq fintecl
plus	cmp r0,#'P'					;Si es P
		bne minus
		LDR r1,=velfantasmas			;velfantasmas++
		ldrb r2,[r1]
		cmp r2,#1
		beq fintecl
		mov r2,r2,LSR#1
		strb r2,[r1]
		b fintecl
minus	cmp r0,#'M'					;Si es M
		bne q
		LDR r1,=velfantasmas			;velfantasmas--
		ldrb r2,[r1]
		cmp r2,#128
		beq fintecl
		mov r2,r2,LSL#1
		strb r2,[r1]
		b fintecl
q		cmp r0,#'Q'					;Si es Q
		beq dofinal						;fin=1
		b fintecl
fintecl
		mov r1,#0
		LDR r0,=tecla			;Miro la tecla pulsada
		strb r1,[r0]
	;Volvemos
		POP {r0-r2}
		POP {pc}

;Subrutina que finaliza la partida (fin=1)
dofinal	PUSH {lr}
		PUSH {r0-r1}
		LDR r0,=fin				;fin = 1
		mov r1,#1
		strb r1,[r0]
	;Volvemos
		POP {r0-r1}
		POP {pc}

;Actualizamos el marcador de vidas y puntos
update	LDR r0,=MARCVIDAS
		LDR r1,=vidas
		ldrb r1,[r1]
		add r1,r1,#48			;pasamos a codigo ASCII
		strb r1,[r0]
		LDR r0,=MARCPUNTOS
		LDR r1,=unidades
		ldrb r1,[r1]
		add r1,r1,#48			;pasamos a codigo ASCII
		strb r1,[r0],#-1
		LDR r1,=decenas
		ldrb r1,[r1]
		add r1,r1,#48			;pasamos a codigo ASCII
		strb r1,[r0],#-1
		LDR r1,=centenas
		ldrb r1,[r1]
		add r1,r1,#48			;pasamos a codigo ASCII
		strb r1,[r0]
		b finbuc
;Fin del bucle, ¿Repetimos?
finbuc
		LDR r0,=fin				;si fin=0 salto a bucle
		ldrb r1,[r0]			;sino
		cmp r1,#0				;
		beq bucle				

;Mensaje de finalizacion
	;Borramos toda la pantalla de juego
		LDR r0,=UP
		LDR r1,=DOWN
		mov r2,#' '
clear	cmp r0,r1
		bgt mensaje
		strb r2,[r0],#1
		b clear
	;Mostramos el mensaje por pantalla
mensaje	LDR r0,=MID
	;VICTORIA
win		LDR r1,=tokens
		ldrb r1,[r1]
		LDR r2,=tokens2win
		ldrb r2,[r2]
		cmp r1,r2
		blt lose
		LDR r1,=menswin
		mov r3,#0
print	cmp r3,#8
		beq ggwp
		ldrb r2,[r1],#1
		strb r2,[r0],#1
		add r3,r3,#1
		b print
	;DERROTA
lose	LDR r1,=vidas
		ldrb r2,[r1]
		cmp r2,#0
		bne quit
		ldr r1,=menslose
		mov r3,#0
print2	cmp r3,#8
		beq ggwp
		ldrb r2,[r1],#1
		strb r2,[r0],#1
		add r3,r3,#1
		b print2
	;ABANDONO
quit	ldr r1,=mensquit
		mov r3,#0
print3	cmp r3,#8
		beq ggwp
		ldrb r2,[r1],#1
		strb r2,[r0],#1
		add r3,r3,#1
		b print3
		
		
	
;Deshabilitar interrupciones
ggwp	ldr r0,=VICIntEnClr	
		ldr r1,[r0]							;desactivar IRQ4,IRQ7
		orr r1,r1,#1<<IRQ_I4				;desactivar RSI_reloj
		orr r1,r1,#1<<IRQ_I7				;desactivar RSI_boton
		str r1,[r0]		

bfin		b bfin


RSI_reloj		;Rutina de servicio de la interrupcion IRQ4 (timer 0) 
				;Cada 0,01 s. llega una peticion de interrupcion
;guarda direccion de retorno y palabra de estado
		sub lr,lr,#4
		PUSH {lr}
		mrs r14,spsr
		PUSH {r14}
;salva registros a usar
		PUSH {r0-r1}
;activa IRQ's
		mrs r1,cpsr
		bic r1,r1,#I_Bit			;pone a 0 el bit de las IRQ
		msr cpsr_c,r1
;desactiva del VIC la peticion
		LDR r0,=T0_IR				;bajar peticion HW IRQ [4]
		mov r1,#1 			
	   	str r1,[r0]
;tratamiento de la interrupcion					
		ldr r0,=ticspacman			; +1 tics @
		ldrb r1,[r0]
		add r1,r1,#1
		strb r1,[r0]
		ldr r0,=ticsfantasma		;+1 tics *
		ldrb r1,[r0]
		add r1,r1,#1
		strb r1,[r0]
		ldr r0,=ticsnextfant		;+1 tics para siguiente fantasma
		ldrb r1,[r0]
		add r1,r1,#1
		strb r1,[r0]
		ldr r0,=ticsdisparo			;+1 tics disparo
		ldrb r1,[r0]
		add r1,r1,#1
		strb r1,[r0]
;desactiva IRQ's
		mrs r1,cpsr
		orr r1,r1,#I_Bit
		msr cpsr_c,r1
;restaura registros
		POP {r0-r1}
;desapila spsr y retorna al programa principal		
		POP {r14}
		msr spsr_cxfs,r14			;restaura el spsr de la pila
		ldr r14,=VICVectAddr
		str r14,[r14]
		POP {pc}^


RSI_teclado 			;Rutina de servicio a la interrupcion IRQ 7 (teclado)
						;al pulsar cada tecla llega peticion de interrupcion IRQ7
;guarda direccion de retorno y palabra de estado
		sub lr,lr,#4
		PUSH {lr}
		mrs r14,spsr
		PUSH {r14}
;salva registros a usar
		PUSH {r0-r1}
;activa IRQ's
		mrs r1,cpsr
		bic r1,r1,#I_Bit			;pone a 0 el bit de las IRQ
		msr cpsr_c,r1
;transferencia de datos
		LDR r1,=TEC_DAT				;r1=@R_DATOS tec. virtual
		ldrb r0,[r1]				;r0 codigo ASCII tecla
;tratamiento de la interrupcion					
		LDR r1,=tecla 
	;teclas especiales
		cmp r0,#'+'					;si es + lo pongo en tecla y salgo -> Velocidad asterisco +
		strbeq r0,[r1]
		beq fintec
		cmp r0,#'-'					;si es - lo pongo en tecla y salgo -> Velocidad asterisco -
		strbeq r0,[r1]
		beq fintec	
		cmp r0,#' '					;si es espacio lo pongo en tecla y salgo -> Disparar
		strbeq r0,[r1]
		beq fintec	
	;teclas alfabeticas
	   	bic r0,r0,#2_100000			;la convierto a mayuscula
		cmp r0,#'A'			   		;si es A lo pongo en tecla y salgo -> Izquierda
		strbeq r0,[r1]
		beq fintec
		cmp r0,#'D'			  	 	;si es D lo pongo en tecla y salgo -> Derecha
		strbeq r0,[r1]
		beq fintec
		cmp r0,#'S'			   		;si es S lo pongo en tecla y salgo -> Abajo
		strbeq r0,[r1]
		beq fintec
		cmp r0,#'W'			  	 	;si es W lo pongo en tecla y salgo -> Arriba
		strbeq r0,[r1]
		beq fintec
		cmp r0, #'P'				;si es P lo pongo en tecla y salgo -> Velocidad enemigos plus
		strbeq r0, [r1]
		beq fintec
		cmp r0, #'M'				;si es M lo pongo en tecla y salgo -> Velocidad enemigos minus
		strbeq r0, [r1]
		beq fintec
		cmp r0, #'Q'				;si es Q lo pongo en tecla y salgo -> Quit
		strbeq r0, [r1]
		beq fintec
		;strbeq r0, [r1]
		;LDR r1,=fin
		;moveq r0,#1
		;strbeq r0,[r1]
		
fintec
;desactiva IRQ's
		mrs r1,cpsr
		orr r1,r1,#I_Bit
		msr cpsr_c,r1
;restaura registros
		POP {r0-r1}
;desapila spsr y retorna al programa principal		
		POP {r14}
		msr spsr_cxfs,r14			;restaura el spsr de la pila
		ldr r14,=VICVectAddr
		str r14,[r14]
		POP {pc}^


		END
