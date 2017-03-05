	include tetlinkh.asm

	org	$20

carscroll:	ds	1
cari:		ds	2
atari:		ds	3
carkisu:	ds	1
yakanf:		ds	1
cardatadd:	ds	2
maincounter:	ds	1
speed:		ds	1
jspeed:		ds	1
maxspeed:	ds	1

	include	gamehed.asm
	lda.b	15
	sta	!gamenohex
	sta	!gameno

	jmp	$b000

	org	$9000
	jmp	$8000

	org	$b000

	ldx.w	2
	lda.b	3
-	sta	!points,x
	dex
	bpl	-

	lda.b	4
	sta	!carkisu

	lda	!gamenohex
	sec
	sbc.b	15
	cmp.b	7
	bpl	@f
	stz	!yakanf
	bra	@@f
@@	pha
	lda.b	$03
	sta	!yakanf
	pla
	sec
	sbc.b	7
@@
	rep.b	$20
	and.w	$00ff
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	!cardatadd
	sep.b	$20

carres:
	jsr	screenclear2
	jsr	carhoten

	stz	!blanktimer
	stz	!cari
	stz	!cari+1
	stz	!carscroll
	stz	!maincounter
	lda.b	10
	sta	!maxspeed
	lda.b	20
	sta	!speed

	ldy.w	0
	jsr	carido

scrr:
	lda	!speed
	cmp	!maxspeed
	beq	@f
	dec	!speed
@@
	ldy	!cari
	jsr	carido
	jsr	hyosc

	lda	!speed
	sta	!jspeed

	lda	!pado
	bpl	@f

	lda.b	2
	sta	!jspeed
@@
--	lda	!pad+1
	bit.b	$01
	bne	carright
	bit.b	$02
	bne	carleft
-
	lda	!maincounter
	cmp	!jspeed
	bmi	@@F

	stz	!maincounter

	jsr	scrollhon

	inc	!carscroll
	lda	!carscroll
	cmp.b	$08
	bne	@f

	jsr	carhoten
@@
	jmp	scrr
@@
	jsr	v_blank
	inc	!maincounter
	bra	--

carright:
	lda	!cari
	bne	-

	ldy.w	6
	tya
	sta	!cari
	jsr	carido2
	jsr	carido
	bra	carido3

carleft:
	lda	!cari
	beq	-

	ldy.w	0
	tya
	sta	!cari
	jsr	carido2
	jsr	carido
	bra	carido3

carido3:
	lda	!maincounter
	cmp	!jspeed
	bpl	-
	jsr	hyosc
	bra	-

carido:
	lda.b	0
	xba
	lda	!gamenohex
	sec
	sbc.b	15
	rep.b	$20
	and.w	$00ff
	asl	a
	asl	a
	asl	a
	asl	a
	tax
	sep.b	$20

	lda	@cardat,x
	sta	@screen+538,y
	lda	@cardat+1,x
	sta	@screen+540,y
	lda	@cardat+2,x
	sta	@screen+542,y
	lda	@cardat+3,x
	sta	@screen+602,y
	lda	@cardat+4,x
	sta	@screen+604,y
	lda	@cardat+5,x
	sta	@screen+606,y
	lda	@cardat+6,x
	sta	@screen+666,y
	lda	@cardat+7,x
	sta	@screen+668,y
	lda	@cardat+8,x
	sta	@screen+670,y
	lda	@cardat+9,x
	sta	@screen+730,y
	lda	@cardat+10,x
	sta	@screen+732,y
	lda	@cardat+11,x
	sta	@screen+734,y

	lda	!carscroll
	cmp.b	4
	beq	@@f
	cmp.b	3
	beq	@@f
	bmi	@f

	lda	!cari
	cmp	!atari+1
	bne	@@f

	jmp	sini
@@
	lda	!cari
	cmp	!atari+2
	bne	@f

	jmp	sini

@@
	rts

carido2:
	lda.b	0
	xba
	lda	!gamenohex
	sec
	sbc.b	15
	asl	a
	asl	a
	asl	a
	asl	a
	tax

	tya
	eor.b	$06
	tay

	lda.b	$01
	eor	!yakanf
	sta	@screen+538,y
	sta	@screen+540,y
	sta	@screen+542,y
	sta	@screen+602,y
	sta	@screen+604,y
	sta	@screen+606,y
	sta	@screen+666,y
	sta	@screen+668,y
	sta	@screen+670,y
	sta	@screen+730,y
	sta	@screen+732,y
	sta	@screen+734,y

	tya
	eor.b	$06
	tay

	rts

screenclear2:
	php
	sep.b	$20
	rep.b	$10

	phx
	phy

	lda.b	$20
	sta	!tmp

	ldy.w	768

	jsr	tekicarhyo

	lda.b	$20
	sta	!tmp

	ldy.w	512

	jsr	tekicarhyo

	lda.b	$06
	sta	!atari
	lda.b	$01
	sta	!atari+1

	ply
	plx

	plp

	rts

carhoten:

	stz	!carscroll

	jsr	rand
	lda	!randtmp
	asl	a
	asl	a
	and.b	$20
	sta	!tmp

	lda	!atari+1
	sta	!atari+2
	lda	!atari
	sta	!atari+1
	lda	!tmp
	lsr	a
	lsr	a
	lsr	a
	sta	!tmp+1
	lsr	a
	ora	!tmp+1
	sta	!atari

	ldy.w	0

	jsr	tekicarhyo

	rts

sini:
	jsr	bakuhatu
	dec	!carkisu
	bne	@f

	ldy.w	16
	sty	!tmp+1
	jsr	lineclear
	jsr	v_blank
	jmp	$9000

@@
	jmp	carres

;------------------

tekicarhyo:
;tmp‚Æy‚ğİ’è‚µ‚Æ‚¯

	phy

	lda	!tmp
	ora	!cardatadd
	sta	!tmp
	lda	!cardatadd+1
	sta	!tmp+1

	ldx	!tmp

	lda.b	4
	sta	!tmp+1

--	lda.b	7
	sta	!tmp
-	lda	@tekicar,x
	eor	!yakanf
	sta	@screenp+24,y
	inx
	iny
	iny
	dec	!tmp
	bpl	-

	dec	!tmp+1
	beq	@f

	rep.b	$20
	tya
	clc
	adc.w	48
	tay

	sep.b	$20

	bra	--

@@	ldx.w	0
	ply

	lda.b	4
	sta	!tmp+1

--	lda.b	7
	sta	!tmp
-	lda	@doro,x
	eor	!yakanf
	sta	@screenp+24+256,y
	inx
	iny
	iny
	dec	!tmp
	bpl	-

	dec	!tmp+1
	beq	@f

	rep.b	$20
	tya
	clc
	adc.w	48
	tay

	sep.b	$20

	bra	--

@@

	rts

;-------------

scrollhon:

	lda.b	20
	sta	!tmp+1

	ldx.w	1216

--	ldy.w	7
-	lda	@screenp+24-64,x
	sta	@screenp+24,x
	inx
	inx
	dey
	bpl	-

	dec	!tmp+1
	beq	@f

	rep.b	$20
	txa
	sec
	sbc.w	80
	tax

	sep.b	$20

	bra	--

@@
	rts

	include	subs.asm

cardat:
	bin	cargra.bin

tekicar:
	bin	tekicar.bin
doro:
	bin	doro.bin
