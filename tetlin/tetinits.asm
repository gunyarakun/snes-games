	include	tetlinkh.asm

	org	$8000

	jmp	reallys
gradat:		bin	tetgra.bin
pal:		bin	tetgra.pal
	include	subs.asm
reallys:
	sei
	clc
	xce				;65816 - - -
	sep.b	$20			;m=8 x=16
	rep.b	$10
	stz	@$420c			;make (h-)dma stop
	stz	@$420b

	lda.b	$80			;force PPU to be BLANKING
	sta	@$2100

	rep.b	$20
	lda.w	$1ff0			;stack pointer
	tcs
	lda.w	$0000			;DR=$0000
	pha
	pld
	sta	!blanktimer
	sep.b	$20
	pha
	plb

	include init.asm		;ppu init

;title

	lda.b	$8f			;キョウブラ
	sta	@$2100

	lda.b	$80			;2119書き込み〜の1inc
	sta	@$2115

	stz	@$2121

	ldx.w	$0			;palette init
-	lda	@pal,x
	sta	@$2122
	lda	@pal+1,x
	sta	@$2122
	inx
	inx
	cpx.w	$0020
	bne	-

	ldx.w	$2000			;graphic 転送
	stx	@$2116

	ldx.w	$1801
	stx	@$4300
	ldx.w	gradat
	stx	@$4302
	stz	@$4304
	ldx.w	$400
	stx	@$4305

	lda.b	$01			;dma実
	sta	@$420b

	ldx.w	$0000			;tile initの
	stx	@$2116

	ldx.w	$0400			;実
-	stz	@$2118
	stz	@$2119
	dex
	bpl	-

	lda.b	$01			;画面モーヅ１
	sta	@$2105

	lda.b	$22			;bg1,2 = $2000(gra)
	sta	@$210b

	stz	@$2107			;bg1 = $0000(tile)

	lda.b	$01
	sta	@$212c			;表示：bg1
	sta	@$420c			;FAST MODE

	ldx.w	4567
	stx	!randtmp

	db	$5c
	dw	FASTJMP
	db	$80

FASTJMP:

	lda.b	$81
	sta	@$4200			;pad read and nmi

	jsr	v_blank

	lda.b	$0f
	sta	@$2100			;表示

	lda.b	0			;ゲーム画面初期化
	ldx.w	1279
-	sta	@screenp,x
	dex
	bpl	-
