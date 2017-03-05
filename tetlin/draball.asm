	include	tetlinkh.asm

	org	$20

snakex:	ds	1
snakey:	ds	1
snakeja:	ds	38
esax:	ds	1
esay:	ds	1
esaja:	ds	2
snakev:	ds	1
tenmetuf:	ds	1
tenmetut:	ds	1
slength:	ds	1
restsnake;	ds	1

	include	gamehed.asm
	lda.b	1
	sta	!gamenohex
	sta	!gameno
	jmp	$a000

	org	$9000
	jmp	$8000

	org	$a000

draball:

	ldx.w	2
	lda.b	3
-	sta	!points,x
	dex
	bpl	-

	lda.b	4
	sta	!restsnake

draball2:

	lda	!gamenohex
	dec	a
	cmp.b	7
	bmi	@F
	inc	a
@@	rep.b	$20
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	and.w	$01c0
	sta	!tmp
	sep.b	$20
	lda	!gamenohex
	dec	a
	cmp.b	7
	bmi	@F
	inc	a
@@
	rep.b	$20
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	and.w	$00e0
	clc
	adc	!tmp
	tay
	sep.b	$20

	ldx.w	0

	lda.b	12
	sta	!tmp+1

dbstamake:
	lda.b	7
	sta	!tmp
-	lda.b	@drastage,y
	sta	@screen+24,x		;clear～
	iny
	inx
	inx
	dec	!tmp
	bpl	-

	dec	!tmp+1
	beq	dbsmend

	rep.b	$20
	txa
	clc
	adc.w	48
	tax
	sep.b	$20

	bra	dbstamake

dbsmend:

	lda.b	3
	sta	!slength
	ldy.w	769
	ldx.w	34
-	sty	!snakeja,x
	dex
	dex
	bpl	-

	lda.b	4
	sta	!snakex			;ヘビ座標～
	lda.b	11
	sta	!snakey

	lda.b	$c8
	sta	!snakeja
	lda.b	$02
	sta	!snakeja+1
	lda.b	$c6
	sta	!snakeja+2
	lda.b	$02
	sta	!snakeja+3
	lda.b	$c4
	sta	!snakeja+4
	lda.b	$02
	sta	!snakeja+5

	jsr	makeesa

	lda.b	$01
	sta	!snakev			;スネークヴェルトル

	lda.b	$02
	sta	@screen+732
	sta	@screen+734
	sta	@screen+736

	jmp	snakeme2

svk:
	lda	!snakev
	beq	snakeup
	dec	a
	beq	snakeright
	dec	a
	beq	snakeleft
	bra	snakedown

snakeup:
	dec	!snakey
	bpl	snakeup2
	jmp	sshibo
snakeup2:
	rep.b	$20
	lda	!snakeja
	sec
	sbc.w	$0040
	sta	!snakeja
	sep.b	$20
	bra	snakeme

snakeright:
	inc	!snakex
	lda	!snakex
	bit.b	$f8
	beq	snakeright2
	jmp	sshibo
snakeright2:
	rep.b	$20
	inc	!snakeja
	inc	!snakeja
	sep.b	$20
	bra	snakeme

snakedown:
	inc	!snakey
	lda	!snakey
	cmp.b	12
	bmi	snakedown2
	jmp	sshibo
snakedown2:
	rep.b	$20
	lda	!snakeja
	clc
	adc.w	$0040
	sta	!snakeja
	sep.b	$20
	bra	snakeme

snakeleft:
	dec	!snakex
	bpl	snakeleft2
	jmp	sshibo
snakeleft2:
	rep.b	$20
	dec	!snakeja
	dec	!snakeja
	sep.b	$20

snakeme:

	ldx	!snakeja
	lda	@screen+24,x
	cmp.b	$01
	beq	snakeme2
	jmp	sshibo
snakeme2:
	sep.b	$10

	lda	!slength
	asl	a
	and.b	$fe
	tax

	rep.b	$20

-	lda	!snakeja,x
	sta	!snakeja+2,x
	dex
	dex
	bpl	-

	sep.b	$20
	rep.b	$10

	lda	!snakex
	cmp	!esax
	bne	esachk
	lda	!snakey
	cmp	!esay
	bne	esachk

	rep.b	$20
	lda	!slength
	asl	a
	and.w	$01fe
	tax

	lda	!snakeja+2,x
	sta	!snakeja+4,x
	sep.b	$20

	lda	!points+2
	clc
	adc.b	5
	cmp.b	$d
	bpl	@F
	sta	!points+2
	bra	mecallend
@@	lda.b	3
	sta	!points+2

	lda	!points+1
	inc	a
	cmp.b	$d
	bpl	@F
	sta	!points+1
	bra	mecallend
@@	lda.b	3
	sta	!points+1

	lda	!points
	inc	a
	cmp.b	$d
	bpl	@F
	sta	!points
	bra	mecallend
@@	lda.b	3
	sta	!points

mecallend:

	lda	!points
	sta	@screen+192
	lda	!points+1
	sta	@screen+194
	lda	!points+2
	sta	@screen+196

	inc	!slength
	lda	!slength
	cmp.b	17
	bne	mecall
	jmp	dbclear
mecall:
	jsr	makeesa

esachk:

	rep.b	$20
	lda	!slength
	asl	a
	and.w	$01fe
	tax

	lda	!snakeja+2,x
	tax
	sep.b	$20
	lda.b	$01
	sta	@screen+24,x

	lda.b	1
	sta	!tenmetuf

	lda.b	$03
	sta	!tenmetut

	lda	!gamenohex
	bit.b	$08
	beq	@F

	ldy.w	15
	bra	@@F

@@
	ldy.w	30

@@

-	ldx	!snakeja
	lda	!tenmetuf
	sta	@screen+24,x

	ldx	!esaja
	lda	!tenmetuf
	sta	@screen+24,x

	dec	!tenmetut
	bne	tenmetuc
	lda	!tenmetuf
	eor.b	3
	sta	!tenmetuf
	lda.b	10
	sta	!tenmetut
tenmetuc:

	jsr	hyosc

	lda	!pad+1
	bit.b	$41
	beq	svk2
	lda	!snakev
	cmp.b	2
	beq	svk2
	lda.b	1
	sta	!snakev
	bra	svkj
svk2:
	bit.b	2
	beq	svk3
	lda	!snakev
	cmp.b	1
	beq	svk3
	lda.b	2
	sta	!snakev
	bra	svkj
svk3:
	bit.b	4
	beq	svk4
	lda	!snakev
	beq	svk4
	lda.b	3
	sta	!snakev
	bra	svkj
svk4:
	lda	!pad
	bpl	svke
	lda	!snakev
	cmp.b	3
	beq	svke
	stz	!snakev
	bra	svkj

svke:

	dey
	beq	svkj

	jmp	-

svkj:

	ldx	!snakeja
	lda.b	2
	sta	@screen+24,x

	ldx	!esaja
	lda.b	1
	sta	@screen+24,x

	lda	!snakex
	pha
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and.b	$0f
	inc	a
	inc	a
	inc	a
	sta	@screen+64
	pla
	and.b	$0f
	inc	a
	inc	a
	inc	a
	sta	@screen+66

	lda	!snakey
	pha
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and.b	$0f
	inc	a
	inc	a
	inc	a
	sta	@screen+70
	pla
	and.b	$0f
	inc	a
	inc	a
	inc	a
	sta	@screen+72

	jmp	svk

sshibo:

	ldx	!esaja
	lda.b	2
	sta	@screen+24,x

	sep.b	$10
	ldx.b	0

	jsr	bakuhatu

	dec	!restsnake
	beq	snakegameover

	jmp	draball2

snakegameover:

	ldy.w	16
	sty	!tmp+1
	jsr	lineclear
	jsr	v_blank
	jmp	$9000

makeesa:
	jsr	rand
	lda	!randtmp		;エサ座標～
	and.b	$07			;11で割ったほうがよかったかな
	sta	!esax			;ぐへへ
	jsr	rand
	lda	!randtmp+1
	and.b	$07
	sta	!tmp
	jsr	rand
	lda	!randtmp+1
	lsr	a
	lsr	a
	lsr	a
	and.b	$03
	clc
	adc	!tmp
	sta	!tmp
	jsr	rand
	lda	!randtmp
	lsr	a
	lsr	a
	lsr	a
	and.b	$01
	clc
	adc	!tmp
	sta	!esay

;	lda	!esay
	rep.b	$20
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	and.w	$1fe0
	sta	!tmp
	lda	!esax
	and.w	$00ff
	clc
	adc	!tmp
	asl	a
	and.w	$2ffe
	sta	!esaja

	tax
	sep.b	$20
	lda	@screen+24,x
	cmp.b	1
	beq	makeesaret

	jmp	makeesa

makeesaret:

	ldx	!esaja
	cpx	!snakeja
	beq	makeesa

	rts

;	tax
;	sep.b	$20
;-	lda	@screen+24,x
;	cmp.b	1
;	beq	makeesaendpre
;
;	inx
;	inx
;
;	inc	!esax
;	lda	!esax
;	cmp.b	$8
;	bmi	@F
;
;	stz	!esax
;	inc	!esay
;	lda	!esay
;	rep.b	$20
;	asl	a
;	asl	a
;	asl	a
;	asl	a
;	asl	a
;	asl	a
;	and.w	$3fc0
;	tax
;	sep.b	$20
;	lda	!esay
;	cmp.b	12
;	bmi	@F
;
;	stz	!esay
;	ldx.w	$0
;
;@@
;
;	bra	-
;
;makeesaendpre:
;
;	stx	!esaja
;
;makeesaend:
;
;	sep.b	$20

;	lda	!esax
;	pha
;	lsr	a
;	lsr	a
;	lsr	a
;	lsr	a
;	and.b	$0f
;	inc	a
;	inc	a
;	inc	a
;	sta	@screen
;	pla
;	and.b	$0f
;	inc	a
;	inc	a
;	inc	a
;	sta	@screen+2
;
;	lda	!esay
;	pha
;	lsr	a
;	lsr	a
;	lsr	a
;	lsr	a
;	and.b	$0f
;	inc	a
;	inc	a
;	inc	a
;	sta	@screen+6
;	pla
;	and.b	$0f
;	inc	a
;	inc	a
;	inc	a
;	sta	@screen+8
;
;	rts

dbclear:

	ldx	!esaja
	lda.b	2
	sta	@screen+24,x

	ldy.w	10
	sty	!tmp+1
	jsr	lineclear
	jmp	draball2

	include	subs.asm

drastage:
	bin	drastage.bin
