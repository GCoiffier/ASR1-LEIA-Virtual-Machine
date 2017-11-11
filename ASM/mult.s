.align16
mult:
	and r3 r1 1
	snif r3 eq 0
	add r2 r2 r0
	lsl r0 r0 1
	lsr r1 r1 1
	snif r1 neq 0
	return
	jump mult
