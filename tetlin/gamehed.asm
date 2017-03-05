	org	$e000
softreset:
-	jsr	v_blank
	lda	!pado
	bit.w	$0040
	bne	-

	sep.b	$20

	jmp	$8000

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
	inc	!blanktimer

	lda	!pad
	beq	@f
	jsr	rand
@@

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
	dw	$8000

	org	$8000
	bin	tetinits.rom
