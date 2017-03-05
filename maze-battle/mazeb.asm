
;���C�Y�o�g�� ����F�s�r�o�I

;���H�i�[���@

;�A�h���X�F7e8000+(y*0x100)+x

;	0=�����Ȃ�,1=�ʂ�������1p,2=�ʂ�������2p
;	3=�L�����N�^1p,4=�L�����N�^2p,5=��

;�A�h���X�F7e2000����

;	VRAM$0000�ibg1�̃^�C���f�[�^�[�j�ƈꏏ�B�e���|�����B

int
res = reset
nmi = nmi
end

mazesize = 105			;���H�S�̂̃T�C�Y
yokohaba = 93			;�@�@�{�̂̃T�C�Y
amari    = 6			;�@�@�̗]��=(mazesize-yokohaba)/2
winx     = $0280		;�@�@�E�B���h�E��VRAM�ʒu

dr1p     = $0500		;1p��DR
dr2p     = $0600		;2p��DR
randamize = $0700		;�����p
rwflag   = $0800		;��ʍX�V�t���O
tmp      = $0900		;�e���|����
maswin   = $0750		;�����t���O(1p,2p��)
key      = <$00			;�p�b�h
xrot     = <$02			;x���W(y���W�ƈꏏ��16bit�ǂݍ��܂��ꍇ�A���j
yrot     = <$03			;y���W
color    = <$04			;�L�����N�^�J���[
wflag    = <$05			;�����t���O
wins     = <$06			;������1�̈�
;wins2   = <$07			;������10�̈�

	org	$8000
reset:
	sei
	clc
	xce			;65816�ցB
	rep	#$30		;m = 16bit,x = 16bit
	lda.w	#$2100
	tcd			;dr = $2100
	lda.w	#$04ff
	tcs			;sp = $04ff
	sep	#$20		;m = 8bit

	stz	$420b		;dma stop.

	lda	#$8f		;�����u�����L���O�H
	sta	$2100
	lda	#$01		;�L�[���̓I��
	sta	$4200

	lda	#$80		;VRAM�̏�����
	sta	<$15

	jsr	flash_sfc	;$7e,$7fbank clear(BIOS data clear).

	ldx.w	#$1000		;VRAM = $1000
	stx	<$16

	lda	#$01		;DMA trans.
	sta	$4300
	lda	#$18
	sta	$4301
	ldx.w	#FONT		;FONT����
	stx	$4302
	stz	$4304
	ldx.w	#FONTTAIL-FONT
	stx	$4305

	lda	#$01
	sta	$420b		;�]���I

	ldx.w	#TILETAIL-TILE-$1
-	lda	TILE,x		;TILE��
	sta	$7e1f80+winx,x	;$7e2000�����
	dex			;�]���B
	bpl	-

	stz	<$21		;�p���b�g������
	ldx.w	#$0000
-	lda	PALETTE,x	;�p���b�g��������
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
	sta	dr1p+wins	;�������[��(�����R�[�h��12)
	sta	dr1p+wins+$1
	sta	dr2p+wins	;2p��
	sta	dr2p+wins+$1

syokika:

	jsr	make_maze	;���H�Â���B

	lda	#amari
	sta	dr1p+xrot	;1p x=6 y=99
	sta	dr2p+yrot
	lda	#yokohaba+amari-1
	sta	dr1p+yrot	;2p x=99 y=6
	sta	dr2p+xrot

	stz	dr1p+wflag	;�����t���O����
	stz	dr2p+wflag

	stz	maswin		;�����t���O(1p,2p��)����

	lda	#$01
	sta	dr1p+color	;�J���[�f�[�^�[�ݒ�
	inc
	sta	dr2p+color
	inc
	sta	$7ee206		;��l���L������������(RAM)
	inc
	sta	$7e8662		;2p��

	jsr	hyouji		;��ʕ\��

	lda	#$0f		;��ʕ\��
	sta	$2100

	lda	#$81		;nmi and pad read on.
	sta	$4200

main:

	stz	rwflag		;��ʕ\���t���O�I�t

	ldx.w	#dr1p		;dr = dr1p
	phx
	pld

	jsr	ido		;�ړ�
	ldx	xrot		;x���W+y���W��ǂݍ���
	lda	color		;�J���[�f�[�^�[+2�i��l���L�����j��
	inc
	inc
	sta	$7e8000,x	;�������ށB

	lda	wflag		;�����t���O
	bne	main_1p2	;�܂�Ԃ��Ă�Ȃ�W�����v�B
	cpx.w	#$0662		;�܂�Ԃ��n�_�H
	bne	main_2p		;�Ⴄ�B
	inc	wflag		;�܂�Ԃ��t���O�B
	bra	main_2p
main_1p2:
	cpx.w	#$6206		;�S�[���i�X�^�[�g�j�n�_�H
	bne	main_2p		;�Ⴄ�B
	inc	maswin		;�����t���O(1p,2p��)���C������B

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

	lda	rwflag		;��ʕ\���t���O
	beq	main		;�\�����܂���B
	jsr	hyouji		;�\���B

	lda	maswin		;��������H
	beq	main		;�Ȃ��B
	dec
	beq	win1p		;1p����
	dec
	beq	win2p		;2p����
	bra	draw		;���������B

win1p:
	inc	dr1p+wins	;1p��������1�̈�inc
	lda	dr1p+wins	;���ꂪ
	cmp	#10+12		;10�ɂȂ�����(12=�����R�[�h�ŏ������Ă�B)
	bne	win1p_2		;10����Ȃ������B
	inc	dr1p+wins+$1	;1p��������10�̈�inc
	lda	#$0c		;�����R�[�h(������0)
	sta	dr1p+wins	;1�̈ʂ�0
	lda	dr1p+wins+$1	;���ꂪ
	cmp	#10+12		;10�ɂȂ�����
	bne	win1p_2		;10����Ȃ������B
	lda	#$0c		;�����R�[�h(������0)
	sta	dr1p+wins+1	;1p������init
	sta	dr2p+wins	;2p������init
	sta	dr2p+wins+1	;2p������init
win1p_2:
	jsr	winshyo		;�������\��
	bra	re_sta		;�ăX�^�[�g�ւ̏���
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
	lda	dr1p+key+$1	;1p��
	ora	dr2p+key+$1	;2p��key�̏�ʂ�or����
	bit	#$10		;�ǂ������̃X�^�[�g�{�^����������Ă�����
	beq	re_sta		;������ĂȂ���B

	lda	#$8f		;�����u�����L���O�H
	sta	$2100
	lda	#$01		;nmi off
	sta	$4200

	jmp	syokika		;��������go!

winshyo:

-	lda	$4212		;v_blank��股
	bpl	-
	lda	$4212		;�^�C�~���O�H�H�H�H�H�H�H�H

	ldx.w	#$0104		;VRAM $0104(1p������)
	stx	$2116
	lda	dr1p+wins+$1	;10�̈ʂ���
	sta	$2118
	sta	$7e2208
	lda	#$0c
	sta	$2119
	sta	$7e2209
	lda	dr1p+wins	;1�̈�
	sta	$2118
	sta	$7e220a
	lda	#$0c
	sta	$2119
	sta	$7e220b
	ldx.w	#$0113		;VRAM $0113(2p������)
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

	ldx	xrot		;���W�𓾂�(16bit)
	lda	color		;�J���[�ԍ��i�ʂ������Ɓj�𓾂�
	sta	$7e8000,x	;��������

	lda	key+1		;key���
	and	#$0f		;�㉺���E����
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
	cmp	#$08		;��
	bne	sm2		;������玟�B
	dec	yrot		;y=y-1
	jsr	zahyo		;���̍��W�̃f�[�^�[��...
	dec
	beq	sm1_2		;�󔒂�
	dec
	beq	sm1_2		;�ʂ�������1p��
	dec
	beq	sm1_2		;�@�@�@�@�@2p��������O.K.
	inc	yrot		;�������_���[�B
	rts			;��������I
sm1_2:
	inc	rwflag		;��ʏ��������t���O
	rts

sm2:
	cmp	#$04		;��
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
	cmp	#$02		;��
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
	cmp	#$01		;�E
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

	ldx	xrot		;���W(16bit)��

	lda	$7e8000,x	;���̃f�[�^�[��ǂݍ��߁I
	inc			;����p�B

	rts

hyouji:

	phb			;DBR��DR��ۑ��B
	phd

	lda	#$7e		;DBR = $7e
	pha
	plb

	ldx.w	dr1p+xrot	;1p,2p�Ƃ��ɍ��W��ۑ��B
	phx
	ldx.w	dr2p+xrot
	phx

	lda	#$00		;acc�̏�ʂ�0�ɂ���B
	xba

	lda	#$0d		;�J�E���^�B(window size = 13x13)
	sta	tmp+$1

	ldx.w	#MOJITAB	;�����e�[�u���̐擪
	phx			;��DR�ɁB
	pld

	ldy.w	#$0000		;y=0

hyo_jyun:

	iny			;�S�󔒁B
	iny
	iny
	iny

	lda	#$0d		;13��
	sta	tmp
	ldx.w	dr1p+xrot	;���W�ǂݍ���
-	lda	$79fa,x		;lda	$8000-$0606,x(window size�̊֌W)
	phx			;x�ς��
	tax			;x=a
	lda	<$00,x		;�����e�[�u��+x
	sta	$2000+winx,y	;����������
	lda	<$06,x		;�����e�[�u���Q+x
	sta	$2001+winx,y	;����������
	plx			;x�߂���
	inx			;1������
	iny			;����
	iny
	dec	tmp		;�����I���H
	bne	-

	iny
	iny
	iny
	iny

	lda	#$0d
	sta	tmp
	ldx.w	dr2p+xrot	;2p��
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

	dec	tmp+$1		;�����I���H
	beq	hyo_dma		;�I�����������B

	inc	dr1p+yrot	;���̍s��\�����I
	inc	dr2p+yrot	;�������B

	bra	hyo_jyun	;�������������[�B

hyo_dma:

	plx			;1p,2p�̍��W��߂��I
	stx.w	dr2p+xrot
	plx
	stx.w	dr1p+xrot

	pld			;DBR,DR�Ƃ��ɖ߂��I
	plb

-	lda	$4212		;v_blank���
	bpl	-
	lda	$4212		;�^�C�~���O�D�D�D�D�H�H�H�H�H�H�H

	ldx.w	#$0000		;VRAM $0000
	stx	$2116

	lda	#$01
	sta	$4300
	lda	#$18
	sta	$4301
	ldx.w	#$2000		;$7e2000����
	stx	$4302
	lda	#$7e
	sta	$4304
	ldx.w	#$0800		;$800byte
	stx	$4305
	lda	#$01		;�]���I
	sta	$420b

	ldx.w	#$c000		;�E�F�C�g�i�Q�[���������i�݂����Ȃ��悤�Ɂj�B
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
	rep	#$20			;���]���Ă݂���B

	ldx.w	#$0017			;23�{
-	clc
	adc	randamize
	dex
	bne	-

	clc
	adc.w	#$0929			;2345������
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
	bne	-			;�L�[�ǂ߂���iThanks yums and JMK�j

	rep	#$30

	lda	$4218			;�����ǂނ݂̂ɓO����̂��B
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