;deka - tetlin ver.-3+2i
;TOBU kikaku / Twinkle Stars' Palette !

	include tetlinkh.asm

	org	$8000

Reset:

	bin	tetinits.rom

	jmp	restart

	org	$9000

restart:
	lda.b	0			;ゲーム画面初期化
	ldx.w	767
-	sta	@screen,x
	dex
	bpl	-

ts:

	lda.b	$0
	sta	!tmp+1
	sta	!tmp+2

titles:

	lda.b	0
	sta	!tmp

	xba

	ldx.w	0

	lda	!tmp+1
	tay

titles2:
	lda.b	8
	sta	!tmp+3
-	lda	@tetlint,y
	sta	@screen+24,x
	inx
	inx
	iny
	dec	!tmp+3
	bne	-

	inc	!tmp
	lda	!tmp
	cmp.b	12
	beq	titlee

	rep.b	$20
	asl
	asl
	asl
	asl
	asl
	asl
	and.w	$03c0
	tax
	clc
	adc	!tmp+1
	tay
	sep.b	$20

	bra	titles2

titlee:

	jsr	hyosc
	ldx.w	25
-	jsr	v_blank
	rep.b	$20
	lda	!pad
	bit.w	$8680
	bne	selectg
	sep.b	$20
	dex
	bpl	-

	inc	!tmp+1
	lda	!tmp+1
	cmp.b	40
	bne	titles

	bra	ts

;注意：スクロールは1inter1行づつ、ハードでしちゃダメっす。

selectg:

;	あ～、ゲームナンバーは擬似10進だからよろしく～。

	sep.b	$20

	lda.b	$01
	sta	!gameno
	sta	!gamenohex

selectg2:
	rep.b	$20
	pha

	and.w	$00f0

	asl	a
	asl	a

	tay

	sep.b	$20

	stz	!tmp+1

	ldx.w	0

selectg4:
	lda.b	$07
	sta	!tmp

-	lda	@titno,y
	sta	@screen+24,x
	inx
	inx
	iny
	dec	!tmp
	bpl	-

	inc	!tmp+1
	lda	!tmp+1
	cmp.b	6
	beq	selectg3

	rep.b	$20
	txa
	clc
	adc.w	48
	tax
	sep.b	$20

	bra	selectg4

selectg3:

	rep.b	$20
	pla

	and.w	$000f

	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a

	tay

	sep.b	$20

	stz	!tmp+1

	ldx.w	0

selectg5:
	lda.b	$07
	sta	!tmp

-	lda	@titno,y
	sta	@screen+408,x
	inx
	inx
	iny
	dec	!tmp
	bpl	-

	inc	!tmp+1
	lda	!tmp+1
	cmp.b	6
	beq	selectg6

	rep.b	$20
	txa
	clc
	adc.w	48
	tax
	sep.b	$20

	bra	selectg5

selectg6:

	jsr	hyosc

	lda	!pad
	bpl	selectgz

	lda	!gameno

	cmp.b	$15
	bpl	gss2
	jmp	draball
gss2:	cmp.b	$29
	bpl	gss3
	jmp	carrace
gss3:	cmp.b	$43
	bpl	gss4
	jmp	shooting
gss4:
	jmp	blockgame

selectgz:

	lda	!pad+1
	bit.b	$02
	beq	sepad

	lda	!gameno
	cmp.b	$15
	bpl	sepad1_2

	lda.b	$15
	sta	!gameno
	lda.b	15
	sta	!gamenohex

	bra	sepad

sepad1_2:
	cmp.b	$29
	bpl	sepad1_3

	lda.b	$29
	sta	!gameno
	lda.b	29
	sta	!gamenohex

	bra	sepad
sepad1_3:
	cmp.b	$43
	bpl	sepad1_4

	lda.b	$43
	sta	!gameno
	lda.b	43
	sta	!gamenohex

	bra	sepad
sepad1_4:
	lda.b	$01
	sta	!gameno
	sta	!gamenohex

sepad:

	lda	!pad+1
	bit.b	$04
	beq	sepad2

	jsr	sepadinc
	lda	!gameno
	cmp.b	$56
	bne	sepad2
	lda.b	$01
	sta	!gameno
	sta	!gamenohex

sepad2:

	lda	!gameno
	jmp	selectg2

sepadinc:

	lda	!gameno
	and.b	$0f
	cmp.b	9
	bne	sepadinc2
	lda	!gameno
	and.b	$f0
	clc
	adc.b	$10
	sta	!gameno
	inc	!gamenohex

	rts
sepadinc2:
	inc	!gameno
	inc	!gamenohex
	rts

	include	subs.asm

tetlint:
	bin	tetlint.chr
titno:
	bin	numbers.chr

;dragon and ball

	org	$a000

draball:

	bin	draball.rom

;car race

	org	$b000

carrace:

	bin	carrace.rom

;shooting

shooting:

;block game

blockgame:

softreset:
-	jsr	v_blank
	lda	!pado
	bit.w	$0040
	bne	-

	sep.b	$20

	jmp	restart

Nmi:	phb
	phd
	rep.b	$30
	pha
	phx
	phy
	sep.b	$20
	lda.b	$00
	pha
	plb

	lda	@$4210

-	lda	@$4212
	bit.b	$01
	bne	-

	rep.b	$20
	lda	@$4218
	pha
	eor	!pado
	and	@$4218
	sta	!pad
	pla
	sta	!pado
	sec				;必ず１たしちゃうもんねー！
	adc	!randtmp
	sta	!randtmp
	inc	!randtmp
	inc	!blanktimer

	lda	!pado
	bit.w	$0040
	bne	softreset

	ply
	plx
	pla
	pld
	plb
	rti

	org	$00ffc0
	db	'Deka-Tetlin by TSP!  '
	org	$00ffea
	dw	Nmi
	org	$00fffc
	dw	Reset

;	ldx.w	0
;-
;	lda	@screen,x
;	eor.b	$01
;	sta	@screen,x
;
;	jsr	hyosc
;
;	inx
;	inx
;	cpx.w	768
;	bne	-
;
;	ldx.w	0
;
;	bra	-
