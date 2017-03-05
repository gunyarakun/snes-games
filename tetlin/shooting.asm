	include tetlinkh.asm

	org	$20
jibunx:		ds	1
ttamamc:	ds	1
scrollc:	ds	1
hyoscc:		ds	1
ttamax:		ds	1
ttamay:		ds	1
ttamaxo:	ds	1
ttamayo:	ds	1
ttamatai:	ds	1
tekil:		ds	1

	include	gamehed.asm
	lda.b	29
	sta	!gamenohex
	sta	!gameno

	jmp	$c000

	org	$9000
	jmp	$8000

	org	$c000

	ldx.w	2
	lda.b	3
-	sta	!points,x
	dex
	bpl	-

	jsr	screenclear

	lda	!gamenohex
	sec
	sbc.b	29
	sep.b	$10
	tax
	lda	@stekiline,x
	sta	!tekil
	rep.b	$10

	stz	!ttamamc
	stz	!scrollc
	lda.b	8
	sta	!ttamax

	lda	!gamenohex
	sec
	sbc.b	29
	rep.b	$20
	and.w	$0007
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	tax
	sep.b	$20

	ldy.w	0

	lda.b	4
	sta	!tmp

--	lda.b	7
	sta	!tmp+1
-	lda	@stekidat,x
	sta	@screen+24,y
	inx
	iny
	iny
	dec	!tmp+1
	bpl	-

	dec	!tmp
	beq	@f

	rep.b	$20
	tya
	clc
	adc.w	48
	tay
	sep.b	$20

	jmp	--

@@
	lda.b	3
	sta	!jibunx
	lda.b	2
	sta	@screen+734

	jsr	hyosc
smainsta:
	stz	!hyoscc
	lda	!pad+1
	bit.b	$01
	bne	jibunright
	bit.b	$02
	bne	jibunleft
achk:
	lda	!pad
	bpl	@f
	jsr	tamah
@@
	inc	!scrollc
	lda	!scrollc
	cmp.b	128
	bne	@f
	stz	!scrollc
	jsr	scrollhon
@@
	inc	!ttamamc
	lda	!ttamamc
	cmp.b	19
	bne	@f
	stz	!ttamamc
	jsr	ttamam
@@
	lda	!hyoscc
	beq	@f
	jsr	hyosc
	bra	smainsta
@@	jsr	v_blank
	bra	smainsta

jibunright:
	lda	!jibunx
	cmp.b	7
	beq	@f
	sep.b	$10
	tay
	asl	a
	tax
	lda.b	1
	sta	@screen+728,x
	iny
	tya
	inx
	inx
	sta	!jibunx
	lda.b	02
	sta	@screen+728,x
	rep.b	$10
	inc	!hyoscc
	jsr	ttamaatari
@@
	jmp	achk

jibunleft:
	lda	!jibunx
	beq	@f
	sep.b	$10
	tay
	asl	a
	tax
	lda.b	1
	sta	@screen+728,x
	dey
	tya
	dex
	dex
	sta	!jibunx
	lda.b	2
	sta	@screen+728,x
	rep.b	$10
	inc	!hyoscc
	jsr	ttamaatari
@@
	jmp	achk

tamah:
	lda	!jibunx
	cmp	!ttamax
	bne	@@f
	dec	!ttamatai
	bne	@f
	lda.b	8
	sta	!ttamax
	;“G‹ÊŽ€‚É
	bra	@@f
@@
	rts
@@
	lda	!jibunx
	rep.b	$20
	and.w	$00ff
	asl	a
	clc
	adc.w	640
	tay
	sep.b	$20

-	lda	@screen+24,y
	cmp.b	2
	bne	@f
	lda.b	1
	sta	@screen+24,y
	inc	!hyoscc
	bra	@@f
@@
	rep.b	$20
	tya
	sec
	sbc.w	64
	bmi	@f
	tay
	sep.b	$20

	bra	-

@@
	sep.b	$20
	rts

scrollhon:

	lda.b	12
	sta	!tmp+1

	ldx.w	704

--	ldy.w	7
-	lda	@screen+24-64,x
	sta	@screen+24,x
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
	ldx.w	14

	lda.b	$01
-	sta	@screen+24,x
	dex
	dex
	bpl	-

	sep.b	$10
	lda	!jibunx
	asl	a
	tax
	lda.b	2
	sta	@screen+728,x
	rep.b	$10

	inc	!hyoscc
	inc	!tekil
	inc	!ttamayo

	jsr	ttamakyosc

	rts

ttamam:
	lda	!ttamax
	cmp.b	8
	bne	@f

	jsr	ttamah

	rts

@@
	lda	!ttamax
	cmp	!jibunx
	bmi	@f
	beq	@@f
;plus
	dec	!ttamax
	bra	@@f
@@
	inc	!ttamax
@@
ttamakyosc:
	lda	!ttamax
	cmp.b	8
	bne	@f
	jsr	ttamah
	rts
@@
	inc	!ttamay
	lda	!ttamay
	cmp.b	12
	bne	@f

	lda	!ttamayo
	rep.b	$20
	and.w	$00ff
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	!tmp
	lda	!ttamaxo
	and.w	$00ff
	clc
	adc	!tmp
	asl	a
	tax
	sep.b	$20
	lda.b	1
	sta	@screen+24,x

	lda.b	8
	sta	!ttamax

	rts
@@
	jsr	ttamaatari
	jsr	ttamahyo

	rts

ttamaatari:

	lda	!ttamay
	cmp.b	11
	bne	@f
	lda	!ttamax
	cmp	!jibunx
	bne	@f
	jmp	sibo
@@

	rts

ttamah:
	jsr	rand
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	!ttamax
	sta	!ttamaxo

	lda	!tekil
	sta	!ttamay
	sta	!ttamayo
	lda.b	4
	sta	!ttamatai

	jsr	ttamahyo

	rts

ttamahyo:
	lda	!ttamayo
	rep.b	$20
	and.w	$00ff
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	!tmp
	lda	!ttamaxo
	and.w	$00ff
	clc
	adc	!tmp
	asl	a
	tax
	sep.b	$20
	lda.b	1
	sta	@screen+24,x

	lda	!ttamay
	rep.b	$20
	and.w	$00ff
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	!tmp
	lda	!ttamax
	and.w	$00ff
	clc
	adc	!tmp
	asl	a
	tax
	sep.b	$20
	lda.b	2
	sta	@screen+24,x

	inc	!hyoscc

	lda	!ttamay
	sta	!ttamayo
	lda	!ttamax
	sta	!ttamaxo

	rts

sibo:	jsr	v_blank
	jsr	v_blank
	bra	sibo

	include	subs.asm

stekidat:
	bin	shoteki.bin
stekiline:
	bin	shotekil.bin
