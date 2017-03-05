lineclear:

	ldx.w	728

	lda.b	12
	sta	!tmp

--	ldy.w	8
	lda.b	2
-	sta	@screen,x
	inx
	inx
	dey
	bne	-

	rep.b	$20
	txa
	sec
	sbc.w	$0050
	tax
	sep.b	$20

	jsr	hyosc

	ldy	!tmp+1
-	jsr	v_blank
	dey
	bne	-

	dec	!tmp
	bne	--

	ldx.w	24

	lda.b	12
	sta	!tmp

--	ldy.w	8
	lda.b	1
-	sta	@screen,x
	inx
	inx
	dey
	bne	-

	rep.b	$20
	txa
	clc
	adc.w	$0030
	tax
	sep.b	$20

	jsr	hyosc
	ldy	!tmp+1
-	jsr	v_blank
	dey
	bne	-

	dec	!tmp
	bne	--

	rts

hyosc:

	php
	rep.b	$10
	phx

	jsr	v_blank

	ldx.w	$0100
	stx	@$2116

	ldx.w	$1801
	stx	@$4300
	ldx.w	screen
	stx	@$4302
	stz	@$4304
	ldx.w	768
	stx	@$4305

	lda.b	$01
	sta	@$420b

	plx
	plp

	rts

v_blank:

	php
	sep.b	$20
	pha

-	lda	@\$004212		;V_blank取り
	bmi	-
-	lda	@\$004212
	bpl	-

	pla
	plp

	rts

screenclear:
	php
	sep.b	$20
	rep.b	$10

	phx
	phy

	ldx.w	0

	lda.b	12
	sta	!tmp+1

@@
	ldy.w	7
	lda.b	1
-	sta	@screen+24,x		;clear～
	inx
	inx
	dey
	bpl	-

	dec	!tmp+1
	beq	@F

	rep.b	$20
	txa
	clc
	adc.w	48
	tax
	sep.b	$20

	bra	@B

@@
	ply
	plx

	plp

	rts

rand:
	php
	rep.b	$30
	pha
	phx

	lda	!randtmp
	sep.b	$20
	xba
	rep.b	$20

	ldx.w	$0017			;23倍
-	clc
	adc	!randtmp
	dex
	bne	-

	lda	!randtmp
	clc
	adc.w	$11d7
	sta	!randtmp

	plx
	pla
	plp

	rts

bakuhatu:

	ldx.w	0

@@

	lda.b	@shiniani,x		;適当ループ展開
	sta	@screen+536		;ループ作りがめんどくさかったから
	lda.b	@shiniani+1,x		;との説あり。
	sta	@screen+538
	lda.b	@shiniani+2,x
	sta	@screen+540
	lda.b	@shiniani+3,x
	sta	@screen+542

	lda.b	@shiniani+4,x
	sta	@screen+600
	lda.b	@shiniani+5,x
	sta	@screen+602
	lda.b	@shiniani+6,x
	sta	@screen+604
	lda.b	@shiniani+7,x
	sta	@screen+606

	lda.b	@shiniani+8,x
	sta	@screen+664
	lda.b	@shiniani+9,x
	sta	@screen+666
	lda.b	@shiniani+$a,x
	sta	@screen+668
	lda.b	@shiniani+$b,x
	sta	@screen+670

	lda.b	@shiniani+$c,x
	sta	@screen+728
	lda.b	@shiniani+$d,x
	sta	@screen+730
	lda.b	@shiniani+$e,x
	sta	@screen+732
	lda.b	@shiniani+$f,x
	sta	@screen+734

	jsr	hyosc
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank

	txa
	clc
	adc.b	$10
	tax

	cmp.b	$90
	beq	sshiboend

	jmp	@b

sshiboend:

	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank

	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank
	jsr	v_blank

	rep.b	$10

	rts

shiniani:
	bin	bakupat.chr
