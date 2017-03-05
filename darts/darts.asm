;ダーツ 製作：Ｔwinkle Ｓtars' Ｐalette ！

	org	$008000

arrowx:		ds	2		;矢スプライトX座標
arrowy:		ds	2		;            Y
arrowxadd:	ds	2		;矢スプライトX座標増分
arrowyadd:	ds	2		;            Y
mousex:		ds	1		;マウスX方向増分(最上位bitは符号)
mousey:		ds	1		;      Y
mouserx:	ds	1		;マウス計算用
mousery:	ds	1		;     〃
mouserx2:	ds	1		;     〃
mousery2:	ds	1		;     〃
randtmp:	ds	2		;乱数
pad:		ds	2		;パッド（2p）
pado:		ds	2		;１つ前のパッド（2p）
tmp:		ds	10		;テンポラリ
spriteb:	ds	1		;スプライト座標を格納しているバンク
spritea:	ds	2		;                            アドレス
vcount:		ds	2		;VBlankの回数
hcount:		ds	1		;HBlankの回数(VBlank１回ごとにclear)
red:		ds	1		;rgb変換ルーチン用
green:		ds	1		;      〃
blue:		ds	1		;      〃

Reset:

	sei				;IRQ禁止
	clc
	xce				;6502 to 65816
	stz	@$420c			;Stop H-DMA and DMA
	stz	@$420b

	lda.b	$8f			;Make sfc Blanking mode
	sta	@$2100
	lda.b	$01			;No NMI and IRQ
	sta	@$4200

	rep.b	$30			;M=16bit,X=16bit
	lda.w	$1ff0			;stack pointer
	tcs
	lda.w	$0000			;data register
	tcd
	sep.b	$20			;M=8bit
	pha				;data bank
	plb

	ldx.w	4567			;乱数初期値
	stx	!randtmp

restart:

	include	init.asm		;初期化

	lda.b	$11			;表示はbg1とスプライト
	sta	@$212c
	lda.b	$04			;bg3を重ねる。
	sta	@$212d
	lda.b	$02			;重ねる（透明に）よ。
	sta	@$2130
	lda.b	$81			;bg1に重ねる。
	sta	@$2131
	lda.b	$03			;スプライトは$6000(VRAM)から
	sta	@$2101
	lda.b	$11			;mode1でbg1は16x16
	sta	@$2105
	lda.b	$50			;$5000(VRAM)からbg1キャラクタマップ
	sta	@$2107
	lda.b	$54			;$5400(VRAM)からbg3キャラクタマップ
	sta	@$2109
	lda.b	$66			;$6000(VRAM)からbg1,2キャラクタデーター
	sta	@$210b
	lda.b	$44			;$4000(VRAM)からbg3キャラクタデーター
	sta	@$210c

	lda.b	$e8			;スプライトを表示区域外にとりあえず...
	ldx.w	$01ff
-	sta	@\$7e3000,x
	dex
	bpl	-

	ldx.w	$001f			;スプライトサイズは最小
	tdc
-	sta	@\$7e3200,x
	dex
	bpl	-

	lda.b	$7e			;$7e3000からスプライトの座標データー
	sta	!spriteb
	ldx.w	$3000
	stx	!spritea

	lda.b	$80			;$2119に書き込んで初めてインクリメント
	sta	@$2115

	ldx.w	$6000			;VRAM $6000に書き込み準備
	stx	@$2116

	ldx.w	$1801			;DMA
	stx	@$4300			;$01bankのグラフィックデーターを
	ldx.w	dartsg			;VRAMに転送するね。
	stx	@$4302
	lda.b	$01
	sta	@$4304
	ldx.w	dartsgend-dartsg
	stx	@$4305

	lda.b	$01			;実行
	sta	@$420b

	ldx.w	$5000			;今度はVRAM $5000に書き込む準備
	stx	@$2116

	ldx.w	$1801			;DMA
	stx	@$4300			;$01bankのキャラクタマップデーターを
	ldx.w	dartsban		;VRAMに転送するね
	stx	@$4302
	stz	@$4304
	ldx.w	$0400
	stx	@$4305

	lda.b	$01			;実行
	sta	@$420b

	ldx.w	$4000			;VRAM $4000に書き込みだ。
	stx	@$2116

	ldy.w	$0008			;８キャラクタ分処理
	tdc				;Acc=0
	tax				;X=0
bg3trans:				;16色グラフィックを4色に落とす処理。
	lda.b	$07			;8line分
	sta	!tmp			;カウンター設定
-	lda	@\dartsg+$2000,x	;変換してVRAMに書き込む
	sta	@$2118
	lda	@\dartsg+$2001,x
	sta	@$2119
	inx
	inx
	dec	!tmp			;カウンタデクリ
	bpl	-
	rep.b	$20			;M=16bit
	txa				;Xに$10を足す
	clc
	adc.w	$0010
	tax
	tdc
	sep.b	$20
	dey				;キャラクタカウンタデクリ
	bpl	bg3trans

	ldx.w	$5400			;VRAM $5400から書き込む
	stx	@$2116

	ldx.w	$1801			;DMA
	stx	@$4300			;$00bankのbg3キャラクタマップを
	ldx.w	bg3scr			;VRAMに書き込む。
	stx	@$4302
	stz	@$4304
	ldx.w	$1000
	stx	@$4305

	lda.b	$01			;実行
	sta	@$420b

	tdc
	tax
	sta	@$2121
-	lda	@PALETTEbg2,x		;パレット初期設定
	sta	@$2122
	inx
	cpx.w	$0060
	bne	-

	tdc
	tax
	lda.b	$80
	sta	@$2121

-	lda	@PALETTE,x		;スプライトのパレット
	sta	@$2122
	inx
	cpx.w	$0020
	bne	-

	tdc				;矢座標初期化
	sta	!arrowx
	sta	!arrowx+1
	sta	@\$7e3000

	rep.b	$20			;M=16bit

-	jsr	rand			;乱数いろいろいじって
	lda	!randtmp
	and.w	$00ff
	cmp.w	$00d8
	bpl	-
	sep.b	$20			;矢の初期表示位置決定
	sta	!arrowy
	sta	@\$7e3001
	stz	!arrowy+1

	lda.b	$84			;矢のスプライト座標をそこに移動
	sta	@\$7e3002
	lda.b	$20
	sta	@\$7e3003

	rep.b	$20
	tdc			;a=x=y=0
	sep.b	$20
	tax
	txy
	phb
	lda.b	$7e		;DBR = $7e
	pha
	plb

-	lda.b	$04		;H-DMA４ライン毎に
	sta	@$2000,y	;データー。
	iny
	tdc			;a=0
	sta	@$2000,y	;まず$2121にぜろ書き込まなきゃ。
	iny
	sta	@$2000,y	;4byte転送だから、こう。
	iny
	lda	@\HDPAL,x	;パレットデエタア読み込み。
	sta	@$2000,y	;入れて。
	inx
	iny
	lda	@\HDPAL,x	;パレットデエタア上位。
	sta	@$2000,y	;入れて
	inx
	iny
	cpx.w	HDPALE-HDPAL	;終わった？
	bne	-		;まだ

	dex			;カウンタデクって
	dex

-	lda.b	$04		;また4lineずつ。今度はxをデクっていく。
	sta	@$2000,y
	iny
	tdc
	sta	@$2000,y
	iny
	sta	@$2000,y
	iny
	lda	@\HDPAL,x
	sta	@$2000,y
	iny
	dex
	lda	@\HDPAL,x
	sta	@$2000,y
	iny
	dex
	bpl	-		;終わり。

	plb			;DBR = $00

	ldx.w	$2103		;H-DMA指定
	stx	@$4370		;$7e2000から毎回パレットデーターを書いて
	ldx.w	$2000
	stx	@$4372
	lda.b	$7e
	sta	@$4374

	lda.b	$91		;IRQ(Hのみ),NMI and PAD read ＯＫ
	sta	@$4200

	stz	@$4207		;Hcounter
	stz	@$4208		;Vcounter

	cli			;IRQよろしい。

	lda.b	$80		;H-DMA作動
	sta	@$420c

	jsr	fadein		;フェードイン

main:
	jsr	v_blank		;もちろんVBlankは待つべき

	lda	!pad		;マウスの左ボタンは押されたか？
	bit.b	$40
	beq	main		;押されてないね

	jsr	v_blank		;押されたなら1inter待って

	lda	!mouserx	;そこのマウス増分を使う！
	bit.b	$7f		;増分が両方とも無かったらだめだね
	beq	main

	lda	!mousery
	bit.b	$7f
	bne	main2
	lda.b	$00
	sta	!mousery
main2:				;あとは増分を変換
	stz	!arrowxadd+1	;符号ビットはそのままで、符号ビットがついてる
	lda	!mouserx	;場合は、下位7bitを２の補数にする(Y増分のみ)。
	bpl	arnext
	lda.b	$00		;Xの増分は、符号ビットが立っていたら0にする。
arnext:
	lsr	a		;ちょっと弱める(1/2)
	sta	!arrowxadd
	sep.b	$20

	stz	!arrowyadd+1
	lda	!mousery
	bpl	arnext2
	and.b	$7f
	rep.b	$20
	dec	a
	sta	!tmp
	lda.w	$ffff
	sec
	sbc	!tmp
	lsr	a
	ora.w	$8000
	bra	arnext4
arnext2:
	lsr	a			;ちょっと弱める(1/2)
arnext4:
	sta	!arrowyadd

arrowmove:				;矢動くね

	rep.b	$20			;M=16bit

	lda	!arrowy			;増分を足す
	clc
	adc	!arrowyadd
	sta	!arrowy

	lda	!arrowx			;こっちも
	clc
	adc	!arrowxadd
	sta	!arrowx

	lda	!vcount			;VBlank２回ごとにy増分は+1
	bit.w	$0001
	bne	arhyo
	inc	!arrowyadd
arhyo:
	lda	!arrowx			;矢が刺さったかどうか
	clc
	adc.w	$0028
	bit.w	$0100
	beq	arrowend2		;刺さってません～
resj:
	lda	!arrowy			;矢が画面外に出ているかどうか
	bit.w	$ff00
	bne	resj2			;出ていませ～ん
	and.w	$00ff			;刺さったスプライト表示！
	tax
	sep.b	$20
	lda.b	$d8
	sta	@\$7e3000
	lda	!arrowy
	sta	@\$7e3001
	lda	@ataritable+4,x		;さあ、当った部分の点数やいかに！？
	bra	resj3
resj2:
	tdc				;スプライトを表示したらアカン
	sep.b	$20
	lda.b	$e8
	sta	@\$7e3001
	lda.b	$00			;点数はナシ
resj3:
	jsr	v_blank			;VBlank待って
	ldx.w	$5020			;点数表示
	stx	@$2116
	sta	!tmp			;点数テーブルは3byteだから3倍と
	asl	a
	clc
	adc	!tmp
	tay
	lda.b	$03
	sta	!tmp
-	lda	@pointtable,y		;この点数テーブルはニセ１０進？
	tax
	lda	@sutable,x		;点数テーブルの数字を文字に変換
	sta	@$2118			;表示
	lda.b	$08
	sta	@$2119
	iny
	dec	!tmp
	bne	-

-	jsr	v_blank			;マウスの左ボタン待ち
	lda	!pad
	bit.b	$40
	beq	-

	jsr	fadeout			;フェードアウト

	lda.b	$01			;No NMI and IRQ
	sta	@$4200
	sei				;No IRQ
	stz	@$420c			;No H-DMA
	jmp	restart			;もっかい
arrowend2:
	lda	!arrowy			;矢が
	bit.w	$8000			;画面の上に出たら
	bne	arrowend3		;まあしゃあない、表示はしないけど
	cmp.w	$00e8			;でも画面の下に出たら...
	bpl	resj			;ゆるさん、０点じゃ

	lda.w	$0000			;普通の矢表示
	sep.b	$20

	lda	!arrowx			;RAMに書き込む
	sta	@\$7e3000
	lda	!arrowy
	sta	@\$7e3001

	bra	arrowend4
arrowend3:
	sep.b	$20			;矢は表示出来ません（画面の上）
	lda.b	$e8
	sta	@\$7e3000
	sta	@\$7e3001
arrowend4:

	jsr	v_blank			;VBlank待って
	jmp	arrowmove		;矢を動かそうよ

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

;read mouse!

mouseread:

	pha
	phx

	ldx.w	$0008
-	lda	@$4017
	lsr	a
	rol	!mousery
	dex
	bne	-

	lda	!mousery
	clc
	adc	!randtmp+1
	sta	!randtmp+1

	ldx.w	$0008
-	lda	@$4017
	lsr	a
	rol	!mouserx
	dex
	bne	-

	lda	!mouserx
	clc
	adc	!randtmp
	sta	!randtmp

	plx
	pla

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

rgbtosfpal:		;M=1の時呼び出せ。Accを壊す。
	lda	!green
	and.b	$07
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	ora	!red
	sta	!tmp
	lda	!green
	and.b	$18
	lsr	a
	lsr	a
	lsr	a
	sta	!tmp+1
	lda	!blue
	asl	a
	asl	a
	ora	!tmp+1
	sta	!tmp+1

	rts

fadein:		;dr=$xx00,Mflag=1,DBR=$00
	tdc
-	jsr	v_blank
	sta	@$2100
	inc	a
	cmp.b	$0f
	bne	-

	rts

fadeout:

	lda.b	$0f
-	jsr	v_blank
	sta	@$2100
	dec	a
	bpl	-

	lda.b	$8f
	sta	@$2100

	rts

Irq:
	sep.b	$20
	pha
	lda	@$4211
	inc	!hcount
	pla
	rti

Nmi:
	rep.b	$30
	phd
	phb
	pha
	phx
	phy
	lda.w	$0000
	tcd
	sep.b	$20
	pha
	plb
	sta	@$4210
	sta	!hcount

	ldx.w	$0000
	stx	@$2102

	ldx.w	$0400
	stx	@$4300
	ldx	!spritea
	stx	@$4302
	lda	!spriteb
	sta	@$4304
	ldx.w	$0220
	stx	@$4305

	lda.b	$01
	sta	@$420b

	rep.b	$20
	lda	@$421a
	pha
	eor	!pado
	and	@$421a
	sta	!pad
	pla
	sta	!pado
	sec				;必ず１たしちゃうもんねー！
	adc	!randtmp
	sta	!randtmp

	inc	!vcount

	sep.b	$20
	jsr	mouseread
	rep.b	$20

	ply
	plx
	pla
	plb
	pld
	rti

PALETTE:	bin sfcpal.pal
PALETTEbg2:	bin	dartsbg2.pal
HDPAL:
	bin	hdmapal1.bin
HDPALE:
sutable:	db	$24,$26,$28,$2a,$2c,$2e,$44,$46,$48,$4a,$00
ataritable:	bin	atari.bin
pointtable:	bin	pointtab.bin

dartsban:	bin	dartsban.scr
bg3scr:		bin	dartskag.scr

	org	$00ffc0
	db	'DARTs by TSP!        '
	org	$00ffea
	dw	Nmi
	org	$00ffee
	dw	Irq
	org	$00fffc
	dw	Reset

	org	$18000
dartsg:
	bin	dartsgrp.bin
dartsgend:
