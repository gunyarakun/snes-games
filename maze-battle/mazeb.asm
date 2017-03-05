
;メイズバトル 制作：ＴＳＰ！

;迷路格納方法

;アドレス：7e8000+(y*0x100)+x

;	0=何もない,1=通ったあと1p,2=通ったあと2p
;	3=キャラクタ1p,4=キャラクタ2p,5=壁

;アドレス：7e2000から

;	VRAM$0000（bg1のタイルデーター）と一緒。テンポラリ。

int
res = reset
nmi = nmi
end

mazesize = 105			;迷路全体のサイズ
yokohaba = 93			;　　本体のサイズ
amari    = 6			;　　の余り=(mazesize-yokohaba)/2
winx     = $0280		;　　ウィンドウのVRAM位置

dr1p     = $0500		;1pのDR
dr2p     = $0600		;2pのDR
randamize = $0700		;乱数用
rwflag   = $0800		;画面更新フラグ
tmp      = $0900		;テンポラリ
maswin   = $0750		;勝利フラグ(1p,2p共)
key      = <$00			;パッド
xrot     = <$02			;x座標(y座標と一緒に16bit読み込まれる場合アリ）
yrot     = <$03			;y座標
color    = <$04			;キャラクタカラー
wflag    = <$05			;勝利フラグ
wins     = <$06			;勝ち数1の位
;wins2   = <$07			;勝ち数10の位

	org	$8000
reset:
	sei
	clc
	xce			;65816へ。
	rep	#$30		;m = 16bit,x = 16bit
	lda.w	#$2100
	tcd			;dr = $2100
	lda.w	#$04ff
	tcs			;sp = $04ff
	sep	#$20		;m = 8bit

	stz	$420b		;dma stop.

	lda	#$8f		;強制ブランキング？
	sta	$2100
	lda	#$01		;キー入力オン
	sta	$4200

	lda	#$80		;VRAMの書き方
	sta	<$15

	jsr	flash_sfc	;$7e,$7fbank clear(BIOS data clear).

	ldx.w	#$1000		;VRAM = $1000
	stx	<$16

	lda	#$01		;DMA trans.
	sta	$4300
	lda	#$18
	sta	$4301
	ldx.w	#FONT		;FONTから
	stx	$4302
	stz	$4304
	ldx.w	#FONTTAIL-FONT
	stx	$4305

	lda	#$01
	sta	$420b		;転送！

	ldx.w	#TILETAIL-TILE-$1
-	lda	TILE,x		;TILEを
	sta	$7e1f80+winx,x	;$7e2000からに
	dex			;転送。
	bpl	-

	stz	<$21		;パレット初期化
	ldx.w	#$0000
-	lda	PALETTE,x	;パレット書き込み
	sta	<$22
	lda	PALETTE+1,x
	sta	<$22
	inx
	inx
	cpx.w	#PALETAIL-PALETTE
	bne	-

	lda	#$01
	sta	<$05		;mode 1.
	stz	<$07		;tile = $0000
	sta	<$0b		;font = $1000
	sta	<$2c		;bg1 only.

	lda	#$0c
	sta	dr1p+wins	;勝利数ゼロ(文字コードは12)
	sta	dr1p+wins+$1
	sta	dr2p+wins	;2pも
	sta	dr2p+wins+$1

syokika:

	jsr	make_maze	;迷路づくり。

	lda	#amari
	sta	dr1p+xrot	;1p x=6 y=99
	sta	dr2p+yrot
	lda	#yokohaba+amari-1
	sta	dr1p+yrot	;2p x=99 y=6
	sta	dr2p+xrot

	stz	dr1p+wflag	;勝利フラグ下げ
	stz	dr2p+wflag

	stz	maswin		;勝利フラグ(1p,2p共)下げ

	lda	#$01
	sta	dr1p+color	;カラーデーター設定
	inc
	sta	dr2p+color
	inc
	sta	$7ee206		;主人公キャラ書き込み(RAM)
	inc
	sta	$7e8662		;2pも

	jsr	hyouji		;画面表示

	lda	#$0f		;画面表示
	sta	$2100

	lda	#$81		;nmi and pad read on.
	sta	$4200

main:

	stz	rwflag		;画面表示フラグオフ

	ldx.w	#dr1p		;dr = dr1p
	phx
	pld

	jsr	ido		;移動
	ldx	xrot		;x座標+y座標を読み込み
	lda	color		;カラーデーター+2（主人公キャラ）を
	inc
	inc
	sta	$7e8000,x	;書き込む。

	lda	wflag		;勝利フラグ
	bne	main_1p2	;折り返してるならジャンプ。
	cpx.w	#$0662		;折り返し地点？
	bne	main_2p		;違う。
	inc	wflag		;折り返しフラグ。
	bra	main_2p
main_1p2:
	cpx.w	#$6206		;ゴール（スタート）地点？
	bne	main_2p		;違う。
	inc	maswin		;勝利フラグ(1p,2p共)をインくる。

main_2p:
	ldx.w	#dr2p		;dr = 2p
	phx
	pld

	jsr	ido
	ldx	xrot
	lda	color
	inc
	inc
	sta	$7e8000,x

	lda	wflag
	bne	main_2p2
	cpx.w	#$6206
	bne	main_hyo
	inc	wflag
	bra	main_hyo
main_2p2:
	cpx.w	#$0662
	bne	main_hyo
	inc	maswin
	inc	maswin

main_hyo:

	lda	rwflag		;画面表示フラグ
	beq	main		;表示しません。
	jsr	hyouji		;表示。

	lda	maswin		;勝負あり？
	beq	main		;なし。
	dec
	beq	win1p		;1pだけ
	dec
	beq	win2p		;2pだけ
	bra	draw		;引き分け。

win1p:
	inc	dr1p+wins	;1p勝利数の1の位inc
	lda	dr1p+wins	;それが
	cmp	#10+12		;10になったら(12=文字コードで処理してる。)
	bne	win1p_2		;10じゃないっす。
	inc	dr1p+wins+$1	;1p勝利数の10の位inc
	lda	#$0c		;文字コード(数字の0)
	sta	dr1p+wins	;1の位は0
	lda	dr1p+wins+$1	;それが
	cmp	#10+12		;10になったら
	bne	win1p_2		;10じゃないっす。
	lda	#$0c		;文字コード(数字の0)
	sta	dr1p+wins+1	;1p勝利数init
	sta	dr2p+wins	;2p勝利数init
	sta	dr2p+wins+1	;2p勝利数init
win1p_2:
	jsr	winshyo		;勝ち数表示
	bra	re_sta		;再スタートへの準備
win2p:
	inc	dr2p+wins
	lda	dr2p+wins
	cmp	#10+12
	bne	win2p_2
	inc	dr2p+wins+$1
	lda	#$0c
	sta	dr2p+wins
	lda	dr2p+wins+$1
	cmp	#10+12
	bne	win2p_2
	lda	#$0c
	sta	dr1p+wins
	sta	dr1p+wins+1
	sta	dr2p+wins+1
win2p_2:
	jsr	winshyo
	bra	re_sta
draw:

re_sta:
	lda	dr1p+key+$1	;1pと
	ora	dr2p+key+$1	;2pのkeyの上位をorして
	bit	#$10		;どっちかのスタートボタンがおされていたら
	beq	re_sta		;おされてないよ。

	lda	#$8f		;強制ブランキング？
	sta	$2100
	lda	#$01		;nmi off
	sta	$4200

	jmp	syokika		;初期化へgo!

winshyo:

-	lda	$4212		;v_blank取りぃ
	bpl	-
	lda	$4212		;タイミング？？？？？？？？

	ldx.w	#$0104		;VRAM $0104(1p勝ち数)
	stx	$2116
	lda	dr1p+wins+$1	;10の位から
	sta	$2118
	sta	$7e2208
	lda	#$0c
	sta	$2119
	sta	$7e2209
	lda	dr1p+wins	;1の位
	sta	$2118
	sta	$7e220a
	lda	#$0c
	sta	$2119
	sta	$7e220b
	ldx.w	#$0113		;VRAM $0113(2p勝ち数)
	stx	$2116
	lda	dr2p+wins+$1
	sta	$2118
	sta	$7e2226
	lda	#$0c
	sta	$2119
	sta	$7e2227
	lda	dr2p+wins
	sta	$2118
	sta	$7e2228
	lda	#$0c
	sta	$2119
	sta	$7e2229

	rts

ido:

	ldx	xrot		;座標を得て(16bit)
	lda	color		;カラー番号（通ったあと）を得て
	sta	$7e8000,x	;書き込め

	lda	key+1		;key上位
	and	#$0f		;上下左右だけ
	sta	tmp
	lda	key
	bit	#$80
	beq	ido2
	lda	#$01
	ora	tmp
	sta	tmp
	lda	key
ido2:	bit	#$40
	beq	ido3
	lda	#$08
	ora	tmp
	sta	tmp
ido3:
	lda	key+1
	bit	#$80
	beq	ido4
	lda	#$04
	ora	tmp
	sta	tmp
	lda	key+1
ido4:
	bit	#$40
	beq	ido5
	lda	#$02
	ora	tmp
	sta	tmp
ido5:

	lda	tmp
	cmp	#$08		;上
	bne	sm2		;違ったら次。
	dec	yrot		;y=y-1
	jsr	zahyo		;その座標のデーターが...
	dec
	beq	sm1_2		;空白や
	dec
	beq	sm1_2		;通ったあと1pや
	dec
	beq	sm1_2		;　　　　　2pだったらO.K.
	inc	yrot		;違ったらダメー。
	rts			;おかえり！
sm1_2:
	inc	rwflag		;画面書き換えフラグ
	rts

sm2:
	cmp	#$04		;下
	bne	sm3
	inc	yrot
	jsr	zahyo
	dec
	beq	sm2_2
	dec
	beq	sm2_2
	dec
	beq	sm2_2
	dec	yrot
	rts
sm2_2:
	inc	rwflag
	rts

sm3:
	cmp	#$02		;左
	bne	sm4
	dec	xrot
	jsr	zahyo
	dec
	beq	sm3_2
	dec
	beq	sm3_2
	dec
	beq	sm3_2
	inc	xrot
	rts
sm3_2:
	inc	rwflag
	rts
sm4:
	cmp	#$01		;右
	bne	sm5
	inc	xrot
	jsr	zahyo
	dec
	beq	sm4_2
	dec
	beq	sm4_2
	dec
	beq	sm4_2
	dec	xrot
	rts
sm4_2:
	inc	rwflag
	rts
sm5:
	rts

zahyo:

	ldx	xrot		;座標(16bit)の

	lda	$7e8000,x	;所のデーターを読み込め！
	inc			;判定用。

	rts

hyouji:

	phb			;DBRとDRを保存。
	phd

	lda	#$7e		;DBR = $7e
	pha
	plb

	ldx.w	dr1p+xrot	;1p,2pともに座標を保存。
	phx
	ldx.w	dr2p+xrot
	phx

	lda	#$00		;accの上位を0にする。
	xba

	lda	#$0d		;カウンタ。(window size = 13x13)
	sta	tmp+$1

	ldx.w	#MOJITAB	;文字テーブルの先頭
	phx			;をDRに。
	pld

	ldy.w	#$0000		;y=0

hyo_jyun:

	iny			;４つ空白。
	iny
	iny
	iny

	lda	#$0d		;13回
	sta	tmp
	ldx.w	dr1p+xrot	;座標読み込み
-	lda	$79fa,x		;lda	$8000-$0606,x(window sizeの関係)
	phx			;x積んで
	tax			;x=a
	lda	<$00,x		;文字テーブル+x
	sta	$2000+winx,y	;を書き込め
	lda	<$06,x		;文字テーブル２+x
	sta	$2001+winx,y	;を書き込め
	plx			;x戻して
	inx			;1足して
	iny			;次へ
	iny
	dec	tmp		;もう終わり？
	bne	-

	iny
	iny
	iny
	iny

	lda	#$0d
	sta	tmp
	ldx.w	dr2p+xrot	;2p側
-	lda	$79fa,x
	phx
	tax
	lda	<$00,x
	sta	$2000+winx,y
	lda	<$06,x
	sta	$2001+winx,y
	plx
	inx
	iny
	iny
	dec	tmp
	bne	-

	iny
	iny
	iny
	iny

	dec	tmp+$1		;もう終わり？
	beq	hyo_dma		;終わっちゃった。

	inc	dr1p+yrot	;次の行を表示だ！
	inc	dr2p+yrot	;おっす。

	bra	hyo_jyun	;いけぇぇぇぇー。

hyo_dma:

	plx			;1p,2pの座標を戻せ！
	stx.w	dr2p+xrot
	plx
	stx.w	dr1p+xrot

	pld			;DBR,DRともに戻せ！
	plb

-	lda	$4212		;v_blank取り
	bpl	-
	lda	$4212		;タイミングゥゥゥゥ？？？？？？？

	ldx.w	#$0000		;VRAM $0000
	stx	$2116

	lda	#$01
	sta	$4300
	lda	#$18
	sta	$4301
	ldx.w	#$2000		;$7e2000から
	stx	$4302
	lda	#$7e
	sta	$4304
	ldx.w	#$0800		;$800byte
	stx	$4305
	lda	#$01		;転送！
	sta	$420b

	ldx.w	#$c000		;ウェイト（ゲームが速く進みすぎないように）。
-	dex
	bne	-

	rts

make_maze:

	phb

	lda	#$7e
	pha
	plb

	ldx.w	#$0000
	ldy.w	#amari
make_maze2:
	lda	#$05
	dc.b	$9d,$00,$80		;sta	<$8000,x
	inx
	txa
	cmp	#mazesize
	bne	make_maze2

	rep	#$20
	txa
	sep	#$20
	lda	#$00
	xba
	inc
	xba
	tax
	dey
	bne	make_maze2

	ldy.w	#(yokohaba-1)/2

maze_kihon:

-	lda	#$05
	dc.b	$9d,$00,$80			;sta	<$8000,x
	inx
	txa
	cmp	#(mazesize-yokohaba)/2
	bne	-

-	dc.b	$9e,$00,$80			;stz	<$8000,x
	inx
	txa
	cmp	#yokohaba+amari
	bne	-

-	lda	#$05
	dc.b	$9d,$00,$80			;sta	<$8000,x
	inx
	txa
	cmp	#mazesize
	bne	-

	rep	#$20
	txa
	sep	#$20
	lda	#$00
	xba
	inc
	xba
	tax
	sep	#$20

-	lda	#$05
	dc.b	$9d,$00,$80			;sta	<$8000,x
	inx
	txa
	cmp	#(mazesize-yokohaba)/2
	bne	-

-	dc.b	$9e,$00,$80			;stz	<$8000,x
	lda	#$05
	inx
	dc.b	$9d,$00,$80			;sta	<$8000,x
	inx
	txa
	cmp	#yokohaba+amari-1
	bne	-

	dc.b	$9e,$00,$80			;stz	<$8000,x
	inx

-	lda	#$05
	dc.b	$9d,$00,$80			;sta	<$8000,x
	inx
	txa
	cmp	#mazesize
	bne	-

	rep	#$20
	txa
	sep	#$20
	lda	#$00
	xba
	inc
	xba
	tax

	dey
	beq	make_kabe
	jmp	maze_kihon

make_kabe:

-	lda	#$05
	dc.b	$9d,$00,$80			;sta	<$8000,x
	inx
	txa
	cmp	#(mazesize-yokohaba)/2
	bne	-

-	dc.b	$9e,$00,$80			;stz	<$8000,x
	inx
	txa
	cmp	#yokohaba+amari
	bne	-

-	lda	#$05
	dc.b	$9d,$00,$80			;sta	<$8000,x
	inx
	txa
	cmp	#mazesize
	bne	-

	rep	#$20
	txa
	sep	#$20
	lda	#$00
	xba
	inc
	xba
	tax

	ldy.w	#(mazesize-yokohaba)/2
make_maze3:
	lda	#$05
	dc.b	$9d,$00,$80			;sta	<$8000,x
	inx
	txa
	cmp	#mazesize
	bne	make_maze3

	rep	#$20
	txa
	sep	#$20
	lda	#$00
	xba
	inc
	xba
	tax
	dey
	bne	make_maze3

	ldx.w	#$0700+amari
	ldy.w	#(yokohaba-1)/2
rndkabe:
	jsr	rand
	lda	randamize+1
	and	#$03
	beq	kabe1
	dec
	beq	kabe2
	dec
	beq	kabe3
	bra	kabe4
kabe1:
	phx
	rep	#$20
	txa
	sep	#$20
	xba
	dec
	xba
	tax
	dc.b	$bd,$01,$80
	beq	kabe1_2
	plx
	bra	rndkabe
kabe1_2:
	lda	#$05
	dc.b	$9d,$01,$80			;sta	<$8001,x
	plx
	bra	kabeend
kabe2:
	dc.b	$bd,$00,$80
	beq	kabe2_2
	bra	rndkabe
kabe2_2:
	lda	#$05
	dc.b	$9d,$00,$80			;sta	<$8000,x
	bra	kabeend
kabe3:
	phx
	rep	#$20
	txa
	sep	#$20
	xba
	inc
	xba
	tax
	dc.b	$bd,$01,$80
	beq	kabe3_2
	plx
	bra	rndkabe
kabe3_2:
	lda	#$05
	dc.b	$9d,$01,$80			;sta	<$8001,x
	plx
	bra	kabeend
kabe4:
	dc.b	$bd,$02,$80
	beq	kabe4_2
	bra	rndkabe
kabe4_2:
	lda	#$05
	dc.b	$9d,$02,$80			;sta	<$8002,x
kabeend:
	inx
	inx
	txa
	cmp	#yokohaba+amari-1
	beq	maze_end
	jmp	rndkabe

maze_end:

	dey
	beq	mazeret

	rep	#$20
	txa
	sep	#$20
	lda	#amari
	xba
	inc
	inc
	xba
	tax
	sep	#$20
	jmp	rndkabe

mazeret:

	plb
	rts

rand:

	php
	rep	#$30			;acc,index= 16bit
	pha
	phx
	phy

	lda	randamize
	sep	#$20
	xba
	rep	#$20			;反転してみたり。

	ldx.w	#$0017			;23倍
-	clc
	adc	randamize
	dex
	bne	-

	clc
	adc.w	#$0929			;2345足して
	sta	randamize

	ply
	plx
	pla
	sep	#$20
	rep	#$10
	plp
	rts

flash_sfc:

	phb
	lda	#$7e
	pha
	plb
	rep	#$20
	ldx.w	#$ffff
-	lda	$0000,x
	adc	randamize
	sta	randamize
	stz.w	$0000,x
	dex
	cpx.w	#$2000
	bne	-
	sep	#$20

	lda	#$7f
	pha
	plb
	rep	#$20
	ldx.w	#$ffff
-	lda	$0000,x
	adc	randamize
	sta	randamize
	stz.w	$0000,x
	dex
	bne	-
	sep	#$20

	plb
	rts

nmi:
	php
	phb
	phd
	rep	#$30
	pha
	phx
	phy

	sep	#$20
	lda	#$00
	pha
	plb

	lda	#$01
-	bit	$4212
	beq	-
-	bit	$4212
	bne	-			;キー読めるっ（Thanks yums and JMK）

	rep	#$30

	lda	$4218			;ただ読むのみに徹するのだ。
	sta	dr1p+key
	adc	randamize
	sta	randamize

	lda	$421a
	sta	dr2p+key
	adc	randamize
	sta	randamize

	ply
	plx
	pla
	pld
	plb
	plp

	rti

FONT:
	bin	mazeb.fon
FONTTAIL:

PALETTE:
	bin	mazeb.pal
PALETAIL:

TILE:
	bin	mazeb.til
TILETAIL:

MOJITAB:
	dc.b	$01,$02,$02,$03,$03,$04
	dc.b	$0c,$04,$08,$04,$08,$00
