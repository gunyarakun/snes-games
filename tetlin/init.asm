INIT:
		ldx.w	$000C+1
INIT_L1:
		stz	@$2100-1,X
		dex
		bne	INIT_L1
		ldx.w	$0014-$000D+1
INIT_L2:
		stz	@$210D-1,X
		stz	@$210D-1,X
		dex
		bne	INIT_L2
		ldx.w	$0033-$0023+1
INIT_L3:
		stz	@$2123-1,X
		dex
		bne	INIT_L3
		lda.b	$80
		sta	@$2100		;SC OFF
		sta	@$2115		;H / +1 mode
CPUINIT:
		ldx.w	$000E
CPUINIT_L1:	stz	@$4200-1,X
		dex
		bmi	CPUINIT_L1
		lda.b	$FF
		sta	@$4201
