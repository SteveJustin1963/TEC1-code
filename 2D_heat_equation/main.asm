;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _puts
	.globl _printf
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_apu_data	=	0x0040
_apu_cmd	=	0x0041
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;main.c:65: static uint32_t ieee_to_apu(float f) {
;	---------------------------------
; Function ieee_to_apu
; ---------------------------------
_ieee_to_apu:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	ld	c, l
	ld	b, h
;main.c:68: x.f = f;
	ld	hl, #0
	add	hl, sp
	ld	(hl), e
	inc	hl
	ld	(hl), d
	inc	hl
	ld	(hl), c
	inc	hl
	ld	(hl), b
;main.c:69: exp = (x.u >> 23) & 0xFF;
	ld	hl, #0
	add	hl, sp
	push	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	pop	hl
	ld	a, #0x07
00116$:
	srl	b
	rr	c
	dec	a
	jr	NZ, 00116$
	ld	a,c
;main.c:70: if (exp != 0 && exp != 0xFF)
	or	a, a
	jr	Z, 00102$
	inc	c
	jr	Z, 00102$
;main.c:71: x.u += (1UL << 23);    /* +1 to exponent field */
	push	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	pop	hl
	ld	a, e
	add	a, #0x80
	ld	e, a
	ld	a, d
	adc	a, #0x00
	ld	(hl), c
	inc	hl
	ld	(hl), b
	inc	hl
	ld	(hl), e
	inc	hl
	ld	(hl), a
	dec	hl
	dec	hl
	dec	hl
00102$:
;main.c:72: return x.u;
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
;main.c:73: }
	ld	sp, ix
	pop	ix
	ret
;main.c:75: static float apu_to_ieee(uint32_t raw) {
;	---------------------------------
; Function apu_to_ieee
; ---------------------------------
_apu_to_ieee:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	ld	c, l
	ld	b, h
;main.c:78: x.u = raw;
	ld	hl, #0
	add	hl, sp
	ld	(hl), e
	inc	hl
	ld	(hl), d
	inc	hl
	ld	(hl), c
	inc	hl
	ld	(hl), b
	dec	hl
	dec	hl
	dec	hl
;main.c:79: exp = (x.u >> 23) & 0xFF;
	push	hl
	ld	a, (hl)
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	a, (hl)
	pop	hl
	ld	a, #0x07
00116$:
	srl	b
	rr	c
	dec	a
	jr	NZ, 00116$
	ld	a,c
;main.c:80: if (exp != 0 && exp != 0xFF)
	or	a, a
	jr	Z, 00102$
	inc	c
	jr	Z, 00102$
;main.c:81: x.u -= (1UL << 23);    /* -1 from exponent field */
	push	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	pop	hl
	ld	a,e
	add	a,#0x80
	ld	e, a
	ld	a, d
	adc	a, #0xff
	ld	(hl), c
	inc	hl
	ld	(hl), b
	inc	hl
	ld	(hl), e
	inc	hl
	ld	(hl), a
00102$:
;main.c:82: return x.f;
	ld	hl, #0
	add	hl, sp
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
;main.c:83: }
	ld	sp, ix
	pop	ix
	ret
;main.c:88: static void apu_wait(void) {
;	---------------------------------
; Function apu_wait
; ---------------------------------
_apu_wait:
;main.c:89: while (apu_cmd & APU_BUSY)
00101$:
	in	a, (_apu_cmd)
	rlca
	jr	C, 00101$
;main.c:91: }
	ret
;main.c:93: static void apu_push(float f) {
;	---------------------------------
; Function apu_push
; ---------------------------------
_apu_push:
;main.c:94: uint32_t raw = ieee_to_apu(f);
	call	_ieee_to_apu
;main.c:95: apu_data = (uint8_t)(raw >> 24);
	ld	a, h
	out	(_apu_data), a
;main.c:96: apu_data = (uint8_t)(raw >> 16);
	ld	a, l
	out	(_apu_data), a
;main.c:97: apu_data = (uint8_t)(raw >>  8);
	ld	a, d
	out	(_apu_data), a
;main.c:98: apu_data = (uint8_t)(raw      );
	ld	a, e
	out	(_apu_data), a
;main.c:99: }
	ret
;main.c:101: static float apu_pop(void) {
;	---------------------------------
; Function apu_pop
; ---------------------------------
_apu_pop:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;main.c:103: raw  = (uint32_t)apu_data << 24;
	in	a, (_apu_data)
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	ld	de, #0x0000
	ld	l, #0x00
;	spillPairReg hl
;	spillPairReg hl
;main.c:104: raw |= (uint32_t)apu_data << 16;
	in	a, (_apu_data)
	ld	-4 (ix), a
	xor	a, a
	ld	-3 (ix), a
	ld	-2 (ix), a
	ld	-1 (ix), a
	ld	b, #0x10
00105$:
	sla	-4 (ix)
	rl	-3 (ix)
	rl	-2 (ix)
	rl	-1 (ix)
	djnz	00105$
	ld	a, e
	or	a, -4 (ix)
	ld	e, a
	ld	a, d
	or	a, -3 (ix)
	ld	d, a
	ld	a, l
	or	a, -2 (ix)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, h
	or	a, -1 (ix)
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
;main.c:105: raw |= (uint32_t)apu_data <<  8;
	in	a, (_apu_data)
	ld	-4 (ix), a
	xor	a, a
	ld	-3 (ix), a
	ld	-2 (ix), a
	ld	-1 (ix), a
	ld	b, #0x08
00107$:
	sla	-4 (ix)
	rl	-3 (ix)
	rl	-2 (ix)
	rl	-1 (ix)
	djnz	00107$
	ld	a, e
	or	a, -4 (ix)
	ld	e, a
	ld	a, d
	or	a, -3 (ix)
	ld	d, a
	ld	a, l
	or	a, -2 (ix)
	ld	c, a
	ld	a, h
	or	a, -1 (ix)
	ld	b, a
;main.c:106: raw |= (uint32_t)apu_data;
	in	a, (_apu_data)
	push	iy
	ex	(sp), hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	pop	iy
	ld	hl, #0x0000
	or	a, e
	ld	e, a
	push	iy
	ld	a, -5 (ix)
	pop	iy
	or	a, d
	ld	d, a
	ld	a, l
	or	a, c
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, h
	or	a, b
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
;main.c:107: return apu_to_ieee(raw);
	call	_apu_to_ieee
;main.c:108: }
	ld	sp, ix
	pop	ix
	ret
;main.c:110: static void apu_exec(uint8_t cmd) {
;	---------------------------------
; Function apu_exec
; ---------------------------------
_apu_exec:
	out	(_apu_cmd), a
;main.c:112: apu_wait();
;main.c:113: }
	jp	_apu_wait
;main.c:118: static float apu_sinf(float x)           { apu_push(x); apu_exec(APU_SIN); return apu_pop(); }
;	---------------------------------
; Function apu_sinf
; ---------------------------------
_apu_sinf:
	call	_apu_push
	ld	a, #0x11
	call	_apu_exec
	jp	_apu_pop
;main.c:119: static float apu_expf(float x)           { apu_push(x); apu_exec(APU_EXP); return apu_pop(); }
;	---------------------------------
; Function apu_expf
; ---------------------------------
_apu_expf:
	call	_apu_push
	ld	a, #0x19
	call	_apu_exec
	jp	_apu_pop
;main.c:120: static float apu_mulf(float a, float b)  { apu_push(a); apu_push(b); apu_exec(APU_SMUL); return apu_pop(); }
;	---------------------------------
; Function apu_mulf
; ---------------------------------
_apu_mulf:
	call	_apu_push
	pop	hl
	pop	de
	push	de
	push	hl
;	spillPairReg hl
;	spillPairReg hl
	ld	hl, #0x4
	add	hl, sp
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	call	_apu_push
	ld	a, #0x03
	call	_apu_exec
	call	_apu_pop
	pop	bc
	pop	af
	pop	af
	push	bc
	ret
;main.c:121: static float apu_divf(float a, float b)  { apu_push(a); apu_push(b); apu_exec(APU_SDIV); return apu_pop(); }
;	---------------------------------
; Function apu_divf
; ---------------------------------
_apu_divf:
	call	_apu_push
	pop	hl
	pop	de
	push	de
	push	hl
;	spillPairReg hl
;	spillPairReg hl
	ld	hl, #0x4
	add	hl, sp
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	call	_apu_push
	ld	a, #0x04
	call	_apu_exec
	call	_apu_pop
	pop	bc
	pop	af
	pop	af
	push	bc
	ret
;main.c:122: static float apu_addf(float a, float b)  { apu_push(a); apu_push(b); apu_exec(APU_SADD); return apu_pop(); }
;	---------------------------------
; Function apu_addf
; ---------------------------------
_apu_addf:
	call	_apu_push
	pop	hl
	pop	de
	push	de
	push	hl
;	spillPairReg hl
;	spillPairReg hl
	ld	hl, #0x4
	add	hl, sp
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	call	_apu_push
	ld	a, #0x01
	call	_apu_exec
	call	_apu_pop
	pop	bc
	pop	af
	pop	af
	push	bc
	ret
;main.c:127: static float get_Bmn(int m, int n, float u0) {
;	---------------------------------
; Function get_Bmn
; ---------------------------------
_get_Bmn:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	c, e
	ld	b, d
;main.c:128: if (m % 2 == 0 || n % 2 == 0) return 0.0f;
	push	hl
	push	bc
	ld	de, #0x0002
	call	__modsint
	pop	bc
	pop	hl
	ld	a, d
	or	a, e
	jr	Z, 00101$
	push	hl
	push	bc
	ld	de, #0x0002
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	__modsint
	pop	bc
	pop	hl
	ld	a, d
	or	a, e
	jr	NZ, 00102$
00101$:
	ld	de, #0x0000
	ld	hl, #0x0000
	jr	00104$
00102$:
;main.c:130: return apu_divf(16.0f * u0, (float)(m * n) * PI * PI);
	ld	e, c
	ld	d, b
	call	__mulint
	ex	de, hl
	call	___sint2fs
	push	hl
	push	de
	ld	de, #0xe9e6
	ld	hl, #0x411d
	call	___fsmul
	push	hl
	pop	iy
	push	de
	push	iy
	ld	l, 6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, 4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	de, #0x0000
	ld	hl, #0x4180
	call	___fsmul
	pop	iy
	pop	bc
	push	iy
	push	bc
	call	_apu_divf
00104$:
;main.c:131: }
	pop	ix
	ret
;main.c:133: static float solve_2d_heat(float x, float y, float t,
;	---------------------------------
; Function solve_2d_heat
; ---------------------------------
_solve_2d_heat:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-126
	add	iy, sp
	ld	sp, iy
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-4 (ix), l
	ld	-3 (ix), h
;main.c:135: float u = 0.0f;
	xor	a, a
	ld	-38 (ix), a
	ld	-37 (ix), a
	ld	-36 (ix), a
	ld	-35 (ix), a
;main.c:145: for (m = 1; m <= MODES; m++)
	ld	bc, #0x0001
00108$:
;main.c:146: sin_mx[m] = apu_sinf(apu_divf((float)m * PI * x, L));
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	add	hl, hl
	ex	de,hl
	push	de
	ld	hl, #2
	add	hl, sp
	add	hl, de
	pop	de
	ld	-2 (ix), l
	ld	-1 (ix), h
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	___sint2fs
	push	hl
	push	de
	ld	de, #0x0fdb
	ld	hl, #0x4049
	call	___fsmul
	push	hl
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	call	___fsmul
	push	hl
	ld	l, 14 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 15 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, 12 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 13 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	call	_apu_divf
	call	_apu_sinf
	ld	-10 (ix), e
	ld	-9 (ix), d
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	hl, #118
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;main.c:145: for (m = 1; m <= MODES; m++)
	inc	bc
	ld	a, #0x0a
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jp	PO, 00166$
	xor	a, #0x80
00166$:
	jp	P, 00108$
;main.c:147: for (n = 1; n <= MODES; n++)
	ld	bc, #0x0001
00110$:
;main.c:148: sin_ny[n] = apu_sinf(apu_divf((float)n * PI * y, W));
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	add	hl, hl
	ex	de,hl
	push	de
	ld	hl, #46
	add	hl, sp
	add	hl, de
	pop	de
	ld	-2 (ix), l
	ld	-1 (ix), h
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	___sint2fs
	push	hl
	push	de
	ld	de, #0x0fdb
	ld	hl, #0x4049
	call	___fsmul
	push	hl
	ld	l, 6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, 4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	call	___fsmul
	push	hl
	ld	l, 18 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 19 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, 16 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 17 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	call	_apu_divf
	call	_apu_sinf
	ld	-10 (ix), e
	ld	-9 (ix), d
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	hl, #118
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;main.c:147: for (n = 1; n <= MODES; n++)
	inc	bc
	ld	a, #0x0a
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jp	PO, 00167$
	xor	a, #0x80
00167$:
	jp	P, 00110$
;main.c:150: for (m = 1; m <= MODES; m++) {
	ld	l, 14 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 15 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, 12 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 13 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	e, 12 (ix)
	ld	d, 13 (ix)
	ld	l, 14 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 15 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsmul
	ld	-34 (ix), e
	ld	-33 (ix), d
	ld	-32 (ix), l
	ld	-31 (ix), h
	ld	l, 18 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 19 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, 16 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 17 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	e, 16 (ix)
	ld	d, 17 (ix)
	ld	l, 18 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 19 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsmul
	ld	-30 (ix), e
	ld	-29 (ix), d
	ld	-28 (ix), l
	ld	-27 (ix), h
	ld	a, 23 (ix)
	xor	a,#0x80
	ld	-23 (ix), a
	ld	a, 20 (ix)
	ld	-26 (ix), a
	ld	a, 21 (ix)
	ld	-25 (ix), a
	ld	a, 22 (ix)
	ld	-24 (ix), a
	ld	bc, #0x0001
;main.c:151: for (n = 1; n <= MODES; n++) {
00122$:
	push	bc
	ld	e, c
	ld	d, b
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	__mulint
	ld	-22 (ix), e
	ld	-21 (ix), d
	pop	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	add	hl, hl
	ex	de,hl
	push	de
	ld	hl, #2
	add	hl, sp
	add	hl, de
	pop	de
	ld	-20 (ix), l
	ld	-19 (ix), h
	ld	-2 (ix), #0x01
	ld	-1 (ix), #0
00112$:
;main.c:154: b_mn = get_Bmn(m, n, u0);
	push	bc
	ld	l, 26 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 27 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, 24 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 25 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_get_Bmn
	pop	af
	pop	af
	ld	-10 (ix), e
	ld	-9 (ix), d
	ld	-8 (ix), l
	ld	-7 (ix), h
	pop	bc
	ld	a, -10 (ix)
	ld	-18 (ix), a
	ld	a, -9 (ix)
	ld	-17 (ix), a
	ld	a, -8 (ix)
	ld	-16 (ix), a
	ld	a, -7 (ix)
	ld	-15 (ix), a
;main.c:155: if (b_mn == 0.0f) continue;     /* odd/even shortcut */
	ld	a, -7 (ix)
	res	7, a
	or	a, -8 (ix)
	or	a, -9 (ix)
	or	a, -10 (ix)
	jp	Z, 00105$
;main.c:159: (float)(m * m) / (L * L) +
	push	bc
	ld	l, -22 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -21 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___sint2fs
	push	hl
	ld	l, -32 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -31 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, -34 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -33 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
;main.c:160: (float)(n * n) / (W * W)
	call	___fsdiv
	ld	-10 (ix), e
	ld	-9 (ix), d
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	__mulint
	ex	de, hl
	call	___sint2fs
	push	hl
	ld	l, -28 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -27 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, -30 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -29 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	call	___fsdiv
	push	hl
	push	de
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsadd
	push	hl
	push	de
	ld	de, #0xe9e6
	ld	hl, #0x411d
	call	___fsmul
	pop	bc
	ld	-10 (ix), e
	ld	-9 (ix), d
	ld	-8 (ix), l
	ld	-7 (ix), h
;main.c:164: spatial = apu_mulf(sin_mx[m], sin_ny[n]);
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	add	hl, hl
	ex	de,hl
	ld	hl, #44
	add	hl, sp
	add	hl, de
	push	bc
	ex	de, hl
	ld	hl, #114
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	ld	l, -20 (ix)
	ld	h, -19 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
;	spillPairReg hl
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	push	bc
	push	hl
	ld	l, -12 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -11 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, -14 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -13 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	call	_apu_mulf
	pop	bc
	ld	-14 (ix), e
	ld	-13 (ix), d
	ld	-12 (ix), l
	ld	-11 (ix), h
;main.c:167: decay = apu_expf(-alpha * lambda_mn * t);
	push	bc
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, -10 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -9 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	e, -26 (ix)
	ld	d, -25 (ix)
	ld	l, -24 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -23 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsmul
	push	hl
	ld	l, 10 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 11 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, 8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 9 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	call	___fsmul
	call	_apu_expf
	pop	bc
	ld	-10 (ix), e
	ld	-9 (ix), d
	ld	-8 (ix), l
	ld	-7 (ix), h
;main.c:170: term = apu_mulf(apu_mulf(b_mn, spatial), decay);
	push	bc
	ld	l, -12 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -11 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, -14 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -13 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	e, -18 (ix)
	ld	d, -17 (ix)
	ld	l, -16 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -15 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_apu_mulf
	push	hl
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, -10 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -9 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	call	_apu_mulf
	push	hl
	push	de
	ld	e, -38 (ix)
	ld	d, -37 (ix)
	ld	l, -36 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -35 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_apu_addf
	pop	bc
	ld	-38 (ix), e
	ld	-37 (ix), d
	ld	-36 (ix), l
	ld	-35 (ix), h
00105$:
;main.c:151: for (n = 1; n <= MODES; n++) {
	inc	-2 (ix)
	jr	NZ, 00168$
	inc	-1 (ix)
00168$:
	ld	a, #0x0a
	cp	a, -2 (ix)
	ld	a, #0x00
	sbc	a, -1 (ix)
	jp	PO, 00169$
	xor	a, #0x80
00169$:
	jp	P, 00112$
;main.c:150: for (m = 1; m <= MODES; m++) {
	inc	bc
	ld	a, #0x0a
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jp	PO, 00170$
	xor	a, #0x80
00170$:
	jp	P, 00122$
;main.c:174: return u;
	ld	e, -38 (ix)
	ld	d, -37 (ix)
	ld	l, -36 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -35 (ix)
;	spillPairReg hl
;	spillPairReg hl
;main.c:175: }
	ld	sp, ix
	pop	ix
	pop	bc
	pop	af
	pop	af
	pop	af
	pop	af
	pop	af
	pop	af
	pop	af
	pop	af
	pop	af
	pop	af
	pop	af
	pop	af
	push	bc
	ret
;main.c:180: int main(void) {
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;main.c:187: printf("Temperature distribution at t = %.1f:\n", t);
	ld	hl, #0x40a0
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	hl, #___str_0
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
;main.c:188: printf("X\tY\tTemp\n");
	ld	hl, #___str_2
	call	_puts
;main.c:190: for (x = 0.2f; x <= 0.8f; x += 0.3f) {
	ld	bc, #0xcccd
	ld	de, #0x3e4c
00105$:
;main.c:191: for (y = 0.2f; y <= 0.8f; y += 0.3f) {
	ld	-4 (ix), #0xcd
	ld	-3 (ix), #0xcc
	ld	-2 (ix), #0x4c
	ld	-1 (ix), #0x3e
00103$:
;main.c:192: temp = solve_2d_heat(x, y, t, L, W, alpha, initial_temp);
	push	bc
	push	de
	ld	hl, #0x42c8
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	hl, #0x3c23
	push	hl
	ld	hl, #0xd70a
	push	hl
	ld	hl, #0x3f80
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	hl, #0x3f80
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	hl, #0x40a0
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	de, hl
	push	de
	ld	e, c
	ld	d, b
	call	_solve_2d_heat
	push	de
	pop	iy
	pop	de
	pop	bc
;main.c:193: printf("%.2f\t%.2f\t%.4f\n", x, y, temp);
	push	bc
	push	de
	push	hl
	push	iy
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	push	de
	push	bc
	ld	hl, #___str_3
	push	hl
	call	_printf
	ld	hl, #14
	add	hl, sp
	ld	sp, hl
	ld	hl, #0x3e99
	push	hl
	ld	hl, #0x999a
	push	hl
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsadd
	push	de
	pop	iy
	pop	de
	pop	bc
	inc	sp
	inc	sp
	push	iy
	ld	-2 (ix), l
	ld	-1 (ix), h
	push	bc
	push	de
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	de, #0xcccd
	ld	hl, #0x3f4c
	call	___fslt
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	pop	de
	pop	bc
	bit	0, l
	jp	Z, 00103$
;main.c:190: for (x = 0.2f; x <= 0.8f; x += 0.3f) {
	ld	hl, #0x3e99
	push	hl
	ld	hl, #0x999a
	ex	de, hl
	push	de
	ld	e, c
	ld	d, b
	call	___fsadd
	ld	c, e
	ld	b, d
	push	bc
	ex	de, hl
	push	de
	push	de
	push	bc
	ld	de, #0xcccd
	ld	hl, #0x3f4c
	call	___fslt
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	pop	de
	pop	bc
	bit	0, l
	jp	Z, 00105$
;main.c:197: return 0;
	ld	de, #0x0000
;main.c:198: }
	ld	sp, ix
	pop	ix
	ret
___str_0:
	.ascii "Temperature distribution at t = %.1f:"
	.db 0x0a
	.db 0x00
___str_2:
	.ascii "X"
	.db 0x09
	.ascii "Y"
	.db 0x09
	.ascii "Temp"
	.db 0x00
___str_3:
	.ascii "%.2f"
	.db 0x09
	.ascii "%.2f"
	.db 0x09
	.ascii "%.4f"
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
