;�_�[�c ����F�swinkle �rtars' �oalette �I

	org	$008000

arrowx:		ds	2		;��X�v���C�gX���W
arrowy:		ds	2		;            Y
arrowxadd:	ds	2		;��X�v���C�gX���W����
arrowyadd:	ds	2		;            Y
mousex:		ds	1		;�}�E�XX��������(�ŏ��bit�͕���)
mousey:		ds	1		;      Y
mouserx:	ds	1		;�}�E�X�v�Z�p
mousery:	ds	1		;     �V
mouserx2:	ds	1		;     �V
mousery2:	ds	1		;     �V
randtmp:	ds	2		;����
pad:		ds	2		;�p�b�h�i2p�j
pado:		ds	2		;�P�O�̃p�b�h�i2p�j
tmp:		ds	10		;�e���|����
spriteb:	ds	1		;�X�v���C�g���W���i�[���Ă���o���N
spritea:	ds	2		;                            �A�h���X
vcount:		ds	2		;VBlank�̉�
hcount:		ds	1		;HBlank�̉�(VBlank�P�񂲂Ƃ�clear)
red:		ds	1		;rgb�ϊ����[�`���p
green:		ds	1		;      �V
blue:		ds	1		;      �V

Reset:

	sei				;IRQ�֎~
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

	ldx.w	4567			;���������l
	stx	!randtmp

restart:

	include	init.asm		;������

	lda.b	$11			;�\����bg1�ƃX�v���C�g
	sta	@$212c
	lda.b	$04			;bg3���d�˂�B
	sta	@$212d
	lda.b	$02			;�d�˂�i�����Ɂj��B
	sta	@$2130
	lda.b	$81			;bg1�ɏd�˂�B
	sta	@$2131
	lda.b	$03			;�X�v���C�g��$6000(VRAM)����
	sta	@$2101
	lda.b	$11			;mode1��bg1��16x16
	sta	@$2105
	lda.b	$50			;$5000(VRAM)����bg1�L�����N�^�}�b�v
	sta	@$2107
	lda.b	$54			;$5400(VRAM)����bg3�L�����N�^�}�b�v
	sta	@$2109
	lda.b	$66			;$6000(VRAM)����bg1,2�L�����N�^�f�[�^�[
	sta	@$210b
	lda.b	$44			;$4000(VRAM)����bg3�L�����N�^�f�[�^�[
	sta	@$210c

	lda.b	$e8			;�X�v���C�g��\�����O�ɂƂ肠����...
	ldx.w	$01ff
-	sta	@\$7e3000,x
	dex
	bpl	-

	ldx.w	$001f			;�X�v���C�g�T�C�Y�͍ŏ�
	tdc
-	sta	@\$7e3200,x
	dex
	bpl	-

	lda.b	$7e			;$7e3000����X�v���C�g�̍��W�f�[�^�[
	sta	!spriteb
	ldx.w	$3000
	stx	!spritea

	lda.b	$80			;$2119�ɏ�������ŏ��߂ăC���N�������g
	sta	@$2115

	ldx.w	$6000			;VRAM $6000�ɏ������ݏ���
	stx	@$2116

	ldx.w	$1801			;DMA
	stx	@$4300			;$01bank�̃O���t�B�b�N�f�[�^�[��
	ldx.w	dartsg			;VRAM�ɓ]������ˁB
	stx	@$4302
	lda.b	$01
	sta	@$4304
	ldx.w	dartsgend-dartsg
	stx	@$4305

	lda.b	$01			;���s
	sta	@$420b

	ldx.w	$5000			;���x��VRAM $5000�ɏ������ޏ���
	stx	@$2116

	ldx.w	$1801			;DMA
	stx	@$4300			;$01bank�̃L�����N�^�}�b�v�f�[�^�[��
	ldx.w	dartsban		;VRAM�ɓ]�������
	stx	@$4302
	stz	@$4304
	ldx.w	$0400
	stx	@$4305

	lda.b	$01			;���s
	sta	@$420b

	ldx.w	$4000			;VRAM $4000�ɏ������݂��B
	stx	@$2116

	ldy.w	$0008			;�W�L�����N�^������
	tdc				;Acc=0
	tax				;X=0
bg3trans:				;16�F�O���t�B�b�N��4�F�ɗ��Ƃ������B
	lda.b	$07			;8line��
	sta	!tmp			;�J�E���^�[�ݒ�
-	lda	@\dartsg+$2000,x	;�ϊ�����VRAM�ɏ�������
	sta	@$2118
	lda	@\dartsg+$2001,x
	sta	@$2119
	inx
	inx
	dec	!tmp			;�J�E���^�f�N��
	bpl	-
	rep.b	$20			;M=16bit
	txa				;X��$10�𑫂�
	clc
	adc.w	$0010
	tax
	tdc
	sep.b	$20
	dey				;�L�����N�^�J�E���^�f�N��
	bpl	bg3trans

	ldx.w	$5400			;VRAM $5400���珑������
	stx	@$2116

	ldx.w	$1801			;DMA
	stx	@$4300			;$00bank��bg3�L�����N�^�}�b�v��
	ldx.w	bg3scr			;VRAM�ɏ������ށB
	stx	@$4302
	stz	@$4304
	ldx.w	$1000
	stx	@$4305

	lda.b	$01			;���s
	sta	@$420b

	tdc
	tax
	sta	@$2121
-	lda	@PALETTEbg2,x		;�p���b�g�����ݒ�
	sta	@$2122
	inx
	cpx.w	$0060
	bne	-

	tdc
	tax
	lda.b	$80
	sta	@$2121

-	lda	@PALETTE,x		;�X�v���C�g�̃p���b�g
	sta	@$2122
	inx
	cpx.w	$0020
	bne	-

	tdc				;����W������
	sta	!arrowx
	sta	!arrowx+1
	sta	@\$7e3000

	rep.b	$20			;M=16bit

-	jsr	rand			;�������낢�낢������
	lda	!randtmp
	and.w	$00ff
	cmp.w	$00d8
	bpl	-
	sep.b	$20			;��̏����\���ʒu����
	sta	!arrowy
	sta	@\$7e3001
	stz	!arrowy+1

	lda.b	$84			;��̃X�v���C�g���W�������Ɉړ�
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

-	lda.b	$04		;H-DMA�S���C������
	sta	@$2000,y	;�f�[�^�[�B
	iny
	tdc			;a=0
	sta	@$2000,y	;�܂�$2121�ɂ��돑�����܂Ȃ���B
	iny
	sta	@$2000,y	;4byte�]��������A�����B
	iny
	lda	@\HDPAL,x	;�p���b�g�f�G�^�A�ǂݍ��݁B
	sta	@$2000,y	;����āB
	inx
	iny
	lda	@\HDPAL,x	;�p���b�g�f�G�^�A��ʁB
	sta	@$2000,y	;�����
	inx
	iny
	cpx.w	HDPALE-HDPAL	;�I������H
	bne	-		;�܂�

	dex			;�J�E���^�f�N����
	dex

-	lda.b	$04		;�܂�4line���B���x��x���f�N���Ă����B
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
	bpl	-		;�I���B

	plb			;DBR = $00

	ldx.w	$2103		;H-DMA�w��
	stx	@$4370		;$7e2000���疈��p���b�g�f�[�^�[��������
	ldx.w	$2000
	stx	@$4372
	lda.b	$7e
	sta	@$4374

	lda.b	$91		;IRQ(H�̂�),NMI and PAD read �n�j
	sta	@$4200

	stz	@$4207		;Hcounter
	stz	@$4208		;Vcounter

	cli			;IRQ��낵���B

	lda.b	$80		;H-DMA�쓮
	sta	@$420c

	jsr	fadein		;�t�F�[�h�C��

main:
	jsr	v_blank		;�������VBlank�͑҂ׂ�

	lda	!pad		;�}�E�X�̍��{�^���͉����ꂽ���H
	bit.b	$40
	beq	main		;������ĂȂ���

	jsr	v_blank		;�����ꂽ�Ȃ�1inter�҂���

	lda	!mouserx	;�����̃}�E�X�������g���I
	bit.b	$7f		;�����������Ƃ����������炾�߂���
	beq	main

	lda	!mousery
	bit.b	$7f
	bne	main2
	lda.b	$00
	sta	!mousery
main2:				;���Ƃ͑�����ϊ�
	stz	!arrowxadd+1	;�����r�b�g�͂��̂܂܂ŁA�����r�b�g�����Ă�
	lda	!mouserx	;�ꍇ�́A����7bit���Q�̕␔�ɂ���(Y�����̂�)�B
	bpl	arnext
	lda.b	$00		;X�̑����́A�����r�b�g�������Ă�����0�ɂ���B
arnext:
	lsr	a		;������Ǝ�߂�(1/2)
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
	lsr	a			;������Ǝ�߂�(1/2)
arnext4:
	sta	!arrowyadd

arrowmove:				;�����

	rep.b	$20			;M=16bit

	lda	!arrowy			;�����𑫂�
	clc
	adc	!arrowyadd
	sta	!arrowy

	lda	!arrowx			;��������
	clc
	adc	!arrowxadd
	sta	!arrowx

	lda	!vcount			;VBlank�Q�񂲂Ƃ�y������+1
	bit.w	$0001
	bne	arhyo
	inc	!arrowyadd
arhyo:
	lda	!arrowx			;��h���������ǂ���
	clc
	adc.w	$0028
	bit.w	$0100
	beq	arrowend2		;�h�����Ă܂���`
resj:
	lda	!arrowy			;���ʊO�ɏo�Ă��邩�ǂ���
	bit.w	$ff00
	bne	resj2			;�o�Ă��܂��`��
	and.w	$00ff			;�h�������X�v���C�g�\���I
	tax
	sep.b	$20
	lda.b	$d8
	sta	@\$7e3000
	lda	!arrowy
	sta	@\$7e3001
	lda	@ataritable+4,x		;�����A�����������̓_���₢���ɁI�H
	bra	resj3
resj2:
	tdc				;�X�v���C�g��\��������A�J��
	sep.b	$20
	lda.b	$e8
	sta	@\$7e3001
	lda.b	$00			;�_���̓i�V
resj3:
	jsr	v_blank			;VBlank�҂���
	ldx.w	$5020			;�_���\��
	stx	@$2116
	sta	!tmp			;�_���e�[�u����3byte������3�{��
	asl	a
	clc
	adc	!tmp
	tay
	lda.b	$03
	sta	!tmp
-	lda	@pointtable,y		;���̓_���e�[�u���̓j�Z�P�O�i�H
	tax
	lda	@sutable,x		;�_���e�[�u���̐����𕶎��ɕϊ�
	sta	@$2118			;�\��
	lda.b	$08
	sta	@$2119
	iny
	dec	!tmp
	bne	-

-	jsr	v_blank			;�}�E�X�̍��{�^���҂�
	lda	!pad
	bit.b	$40
	beq	-

	jsr	fadeout			;�t�F�[�h�A�E�g

	lda.b	$01			;No NMI and IRQ
	sta	@$4200
	sei				;No IRQ
	stz	@$420c			;No H-DMA
	jmp	restart			;��������
arrowend2:
	lda	!arrowy			;�
	bit.w	$8000			;��ʂ̏�ɏo����
	bne	arrowend3		;�܂����Ⴀ�Ȃ��A�\���͂��Ȃ�����
	cmp.w	$00e8			;�ł���ʂ̉��ɏo����...
	bpl	resj			;��邳��A�O�_����

	lda.w	$0000			;���ʂ̖�\��
	sep.b	$20

	lda	!arrowx			;RAM�ɏ�������
	sta	@\$7e3000
	lda	!arrowy
	sta	@\$7e3001

	bra	arrowend4
arrowend3:
	sep.b	$20			;��͕\���o���܂���i��ʂ̏�j
	lda.b	$e8
	sta	@\$7e3000
	sta	@\$7e3001
arrowend4:

	jsr	v_blank			;VBlank�҂���
	jmp	arrowmove		;��𓮂�������

v_blank:

	php
	sep.b	$20
	pha

-	lda	@\$004212		;V_blank���
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

	ldx.w	$0017			;23�{
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

rgbtosfpal:		;M=1�̎��Ăяo���BAcc���󂷁B
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
	sec				;�K���P�������Ⴄ����ˁ[�I
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