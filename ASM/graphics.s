.align16
get_address_from_pixel: ; dans r3 -> adresse du pixel (r1,r2)
	lsl r3 r2 2
	add r3 r3 r2
	lsl r3 r3 5
	sub r3 r1 r3
	let r4 0xff60
	add r3 r3 r4
	return

.align16
clear_screen:
	let r1 0xb000
	snif r1 neq 0
	return
	wmem r0 r1
	add r1 r1 1
	jump -4

.align16
plot:
	lsl r3 r2 2
	add r3 r3 r2
	lsl r3 r3 5
	sub r3 r1 r3
	let r4 0xff60
	add r3 r3 r4
	wmem r0 r3
	return

.align16
fill: ;couleur r0, haut-gauche = (r1,r2) , bas-droite = (r3,r4)
	copy r11 r1
	copy r12 r2
	copy r13 r3
	copy r14 r4
	lsl r1 r12 2
	add r1 r1 r12
	lsl r1 r1 5
	sub r1 r11 r1
	let r2 0xff60
	add r1 r1 r2 ;r1 adresse courante
	copy r2 r11 ;r2 compteur x
	copy r6 r12 ;r6 compteur y
	sub r3 r13 r11
	let r4 159
	sub r3 r4 r3 ;end of line jump

	mark: snif r2 le r13
	jump end_of_line
	snif r6 ge r14
	return
	wmem r0 r1
	add r1 r1 1
	add r2 r2 1
	jump mark

	end_of_line: copy r2 r11 ;reset compteur x
	add r1 r1 r3 ;go to next line
	sub r6 r6 1 ;decrement the line number
	jump mark

.align16
draw: ;line between (r1,r2) and (r3,r4). Bresenham s algorithm

	copy r11 r1
	copy r12 r2
	copy r13 r3
	copy r14 r4
	let r8 0xff60 ; constant

	snif r11 gt r13 ; dx >0 ?
	jump continue1
	copy r11 r13
	copy r12 r14
	copy r14 r2
	copy r13 r1 ;start from left
	continue1:

	sub r1 r13 r11 ;r1 = dx >0
	sub r2 r14 r12 ;r2 = dy

	letl r7 0 ;which octant

	snif r2 slt 0 ; dy>0?
	jump continue2
	let r10 0xffff
	sub r2 r10 r2 ; r2 <- (-r2)
	add r7 r7 1
	continue2:

	snif r1 sgt r2 ; symetrie dx<dy
	add r7 r7 2
	
	copy r4 r11
	copy r5 r12 ;(r4,r5) = coordinates of current point

	snif r7 neq 1
	jump octant7
	snif r7 neq 2
	jump octant1
	snif r7 neq 3
	jump octant6

	octant0:
		lsl r3 r2 2
		sub r3 r3 r1
		boucle_draw0:
			lsl r6 r5 2
			add r6 r6 r5
			lsl r6 r6 5
			sub r6 r4 r6
			add r6 r6 r8  ;r6 = adress of current point (r4,r5)

			snif r4 le r13
			return
			wmem r0 r6
			snif r3 sgt 0
			jump continue_0
			snif r3 neq 0
			jump continue_0
			add r5 r5 1
			sub r3 r3 r1
			continue_0:
			add r3 r3 r2
			add r4 r4 1
			jump boucle_draw0

	octant1:
		lsl r3 r1 2
		sub r3 r3 r2
		boucle_draw1:
			lsl r6 r5 2
			add r6 r6 r5
			lsl r6 r6 5
			sub r6 r4 r6
			add r6 r6 r8  ;r6 = adress of current point

			snif r5 le r14
			return
			wmem r0 r6
			snif r3 sgt 0
			jump continue_1
			snif r3 neq 0
			jump continue_1
			add r4 r4 1
			sub r3 r3 r2
			continue_1:
			add r3 r3 r1
			add r5 r5 1
			jump boucle_draw1


	octant6:
		lsl r3 r1 2
		sub r3 r3 r2
		boucle_draw6:
			lsl r6 r5 2
			add r6 r6 r5
			lsl r6 r6 5
			sub r6 r4 r6
			add r6 r6 r8  ;r6 = adress of current point

			snif r5 ge r14
			return
			wmem r0 r6
			snif r3 sgt 0
			jump continue_6
			snif r3 neq 0
			jump continue_6
			add r4 r4 1
			sub r3 r3 r2
			continue_6:
			add r3 r3 r1
			sub r5 r5 1
			jump boucle_draw6

	octant7:
		lsl r3 r2 2
		sub r3 r3 r1
		boucle_draw7:
			lsl r6 r5 2
			add r6 r6 r5
			lsl r6 r6 5
			sub r6 r4 r6
			add r6 r6 r8  ;r6 = adress of current point (r4,r5)

			snif r4 le r13
			return
			wmem r0 r6
			snif r3 sgt 0
			jump continue_7
			snif r3 neq 0
			jump continue_7
			sub r5 r5 1
			sub r3 r3 r1
			continue_7:
			add r3 r3 r2
			add r4 r4 1
			jump boucle_draw7

.align16
putchar:
	lsl r4 r2 2
	add r4 r4 r2
	lsl r4 r4 5
	sub r4 r1 r4
	let r5 0xff60
	add r4 r4 r5 ;r4 = adresse courante
	let r5 152 ;end of line jump
	let r6 48 ;ascii code
	snif r3 neq r6 ;0
	jump n0
	add r6 r6 1
	snif r3 neq r6 ;1
	jump n1
	add r6 r6 1
	snif r3 neq r6 ;2
	jump n2
	add r6 r6 1
	snif r3 neq r6 ;3
	jump n3
	add r6 r6 1
	snif r3 neq r6 ;4
	jump n4
	add r6 r6 1
	snif r3 neq r6 ;5
	jump n5
	add r6 r6 1
	snif r3 neq r6 ;6
	jump n6
	add r6 r6 1
	snif r3 neq r6 ;7
	jump n7
	add r6 r6 1
	snif r3 neq r6 ;8
	jump n8
	add r6 r6 1
	snif r3 neq r6 ;9
	jump n9
	let r6 65
	snif r3 neq r6 ;A
	jump a
	add r6 r6 1
	snif r3 neq r6 ;B
	jump b
	add r6 r6 1
	snif r3 neq r6 ;C 
	jump c
	add r6 r6 1
	snif r3 neq r6 ;D
	jump d
	add r6 r6 1
	snif r3 neq r6 ;E
	jump e
	add r6 r6 1
	snif r3 neq r6 ;F
	jump f
	add r6 r6 1
	snif r3 neq r6 ;G
	jump g
	add r6 r6 1
	snif r3 neq r6 ;H
	jump h
	add r6 r6 1
	snif r3 neq r6 ;I
	jump i
	add r6 r6 1
	snif r3 neq r6 ;J
	jump j
	add r6 r6 1
	snif r3 neq r6 ;K
	jump k
	add r6 r6 1
	snif r3 neq r6 ;L
	jump l
	add r6 r6 1
	snif r3 neq r6 ;M
	jump m
	add r6 r6 1
	snif r3 neq r6 ;N
	jump n
	add r6 r6 1
	snif r3 neq r6 ;O
	jump o
	add r6 r6 1
	jump intermediaire

	n0:	add r4 r4 8
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		return
	n1: add r4 r4 8
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	n2: add r4 r4 8
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 5
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	n3: add r4 r4 8
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	n4: add r4 r4 8
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	n5: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	n6: add r4 r4 8
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 5
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	n7: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		return
	n8: add r4 r4 8
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		add r4 r4 4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	n9: add r4 r4 8
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		return
	 a: add r4 r4 8
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 b: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	 c: add r4 r4 8
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	 d: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	 e: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 f: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		return
	 g: add r4 r4 8
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 5
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 h: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 i: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
     j: add r4 r4 8
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	k:	add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 l: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 m: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 n: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 o: add r4 r4 8
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return

	intermediaire:
	snif r3 neq r6 ;P
	jump p
	add r6 r6 1
	snif r3 neq r6 ;Q
	jump q
	add r6 r6 1
	snif r3 neq r6 ;R
	jump r
	add r6 r6 1
	snif r3 neq r6 ;S
	jump s
	add r6 r6 1
	snif r3 neq r6 ;T
	jump t
	add r6 r6 1
	snif r3 neq r6 ;U
	jump u
	add r6 r6 1
	snif r3 neq r6 ;V
	jump v
	add r6 r6 1
	snif r3 neq r6 ;W
	jump w
	add r6 r6 1
	snif r3 neq r6 ;X
	jump x
	add r6 r6 1
	snif r3 neq r6 ;Y
	jump y
	add r6 r6 1
	snif r3 neq r6 ;Z
	jump z
	return

	 p: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		return
	 q: add r4 r4 8
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 r: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 s: add r4 r4 8
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 6
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 5
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	 t: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		return
	 u: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		return
	 v: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		return
	 w: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 x: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return
	 y: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		add r4 r4 3
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		return
	 z: add r4 r4 8
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		add r4 r4 3
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 2
		add r4 r4 r5
		add r4 r4 2
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 3
		add r4 r4 r5
		add r4 r4 1
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 4
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 5
		add r4 r4 r5
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		write r0 r4
		add r4 r4 1
		add r4 r4 r5
		return

.align16
circle:
	return