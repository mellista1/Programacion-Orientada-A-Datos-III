section .rodata

duplica4veces: dd 0x00, 0x00, 0x00, 0x00




section .text


; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 3A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3a
global EJERCICIO_3A_HECHO
EJERCICIO_3A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej3a
ej3a:




	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = int32_t* dst_depth [rdi]
	; r/m64 = uint8_t* src_depth [rsi]
	; r/m32 = int32_t  scale     [rdx]
	; r/m32 = int32_t  offset    [rcx]
	; r/m32 = int      width     [r8]
	; r/m32 = int      height    [r9]

	push rbp
	mov rbp, rsp

	movd xmm8, edx 
	movd xmm9, ecx
	pshufd xmm8, xmm8, 0x0
	pshufd xmm9, xmm9, 0x0
	

	mov rax, r8 ;obs que muls afecta rax y rdx :o
	mul r9 ;rax = rax * r9 (width * height)
	mov r8, rax

	

ciclo:

	pmovzxbd xmm0, [rsi] ;| p1 | p2 | p3 | p4 |
	pmulld xmm0, xmm8    ;| p1*scale | p2*scale |...
	paddd xmm0,xmm9    ;| p1*scale + offset| p2*scale + offset |...
	
	movdqu [rdi], xmm0
	
	sub r8, 4
	add rsi, 4
	add rdi, 16

	cmp r8, 0
	jnz ciclo
	
	pop rbp
	ret

; Marca el ejercicio 3B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3b
global EJERCICIO_3B_HECHO
EJERCICIO_3B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.
global ej3b
ej3b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = rgba_t*  dst 		[rdi]
	; r/m64 = rgba_t*  a		[rsi]
	; r/m64 = int32_t* depth_a	[rdx]
	; r/m64 = rgba_t*  b		[rcx]
	; r/m64 = int32_t* depth_b	[r8]
	; r/m32 = int      width	[r9]
	; r/m32 = int      height	[rbp + 0x10]


	push rbp
	mov rbp, rsp
	push rdx

	mov rax, [rbp + 0x10] 
	mul r9 ; rax = width * length

	mov r9, rax
	pop rdx



ciclo2:
	;procesamos depth
	movdqu xmm0, [rdx]
	movdqu xmm1, [r8]

	movdqu xmm3, xmm0 ;Depth a
	movdqu xmm4, xmm1 ;Depth b
	movdqu xmm5, xmm1 ;Depth b

	pcmpgtd xmm3,xmm1 ;a > b
	pcmpgtd xmm4,xmm0 ;b > a
	pcmpeqd xmm5,xmm0 ;b = a

	por xmm3,xmm5 ;a > b & b = a

	movdqu xmm6,[rsi] ;a
	movdqu xmm7,[rcx] ;b

	pand xmm6,xmm4 ;a
	pand xmm7,xmm3 ;b

	por xmm6,xmm7

	movdqu [rdi], xmm6

	sub r9, 4
	add rdx, 16
	add r8,  16
	add rsi, 16
	add rcx, 16
	add rdi, 16

	cmp r9, 0
	jnz ciclo2
	
	pop rbp

	ret
