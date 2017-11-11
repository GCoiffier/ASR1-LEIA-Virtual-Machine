.align16
div:
	copy r10 r0
	copy r11 r1
	copy r3 r1
	snif r1 ge r0
	letl r2 1
	mult:
		lsl r3 r3 1
		lsl r2 r2 1
		add r7 r7 1
		snif r3 le r0
		jump next
		jump mult
	next:
		copy r4 r2 ;r4 quotient haut
		copy r5 r3 ;r5 valeur haute
		lsr r2 r2 1 ;r2 quotient bas
		lsr r3 r3 1 ;r3 valeur basse
	dicho:
		sub r7 r7 1
		snif r7 neq 0
		jump fin
		add r1 r3 r5
		lsr r1 r1 1 ;r1 valeur courante
		add r0 r2 r4
		lsr r0 r0 1 ;r0 quotient courant
		snif r1 neq r10
		jump egal
		snif r1 lt r10
		jump grand
		snif r1 gt r10
		jump petit

		grand:
			copy r5 r1
			copy r4 r0
			jump dicho

		petit:
			copy r3 r1
			copy r2 r0
			jump dicho

		egal:
			copy r2 r0
			jump fin
	fin:
		copy r0 r10
		copy r1 r11
		return