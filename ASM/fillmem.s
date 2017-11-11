let r1 red
letl r0 0
leth r0 176
boucle:
	snif r0 neq 0
	jump 0
	wmem r1 r0
	add r0 r0 1
	jump boucle