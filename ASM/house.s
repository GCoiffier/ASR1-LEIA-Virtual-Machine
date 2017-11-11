let r0 black
call clear_screen

;herbe
let r1 0
let r2 15
let r3 159
let r4 1
let r0 green
call fill

;maison
let r1 20
let r2 50
let r3 70
let r4 16
let r0 grey
call fill

;toit
let r0 red
let r1 20
let r2 50
let r3 70
let r4 50
call draw
let r1 21
let r2 51
let r3 69
let r4 51
call draw
let r1 22
let r2 52
let r3 68
let r4 52
call draw
let r1 23
let r2 53
let r3 67
let r4 53
call draw
let r1 24
let r2 54
let r3 66
let r4 54
call draw
let r1 25
let r2 55
let r3 65
let r4 55
call draw
let r1 26
let r2 56
let r3 64
let r4 56
call draw
let r1 27
let r2 57
let r3 63
let r4 57
call draw
let r1 28
let r2 58
let r3 62
let r4 58
call draw
let r1 29
let r2 59
let r3 61
let r4 59
call draw
let r1 30
let r2 60
let r3 60
let r4 60
call draw
let r1 31
let r2 54
let r3 59
let r4 54
call draw
let r1 32
let r2 55
let r3 58
let r4 55
call draw
let r1 33
let r2 56
let r3 57
let r4 56
call draw
let r1 34
let r2 57
let r3 56
let r4 57
call draw
let r1 35
let r2 58
let r3 55
let r4 58
call draw

;porte
let r1 30
let r2 28
let r3 35
let r4 16
let r0 black
call fill

;fenetre1
let r1 28
let r2 45
let r3 40
let r4 37
let r0 blue
call fill

;fenetre2
let r1 44
let r2 30
let r3 64
let r4 24
let r0 blue
call fill
let r0 white
let r1 44
let r2 30
let r3 64
let r4 24
call draw
let r1 44
let r2 24
let r3 64
let r4 30
call draw

;fenetre3
let r1 48
let r2 45
let r3 60
let r4 37
let r0 blue
call fill

;cheminee
let r0 grey
let r1 50
let r2 65
let r3 56
let r4 55
call fill

;fumee
let r0 white
let r1 53
let r2 67
call plot
let r1 52
add r2 r2 4
call plot
let r1 51
add r2 r2 4
call plot
let r1 54
add r2 r2 4
call plot
let r1 55
add r2 r2 4
call plot
let r1 53
add r2 r2 4
call plot
let r1 51
add r2 r2 4
call plot
let r1 55
add r2 r2 4
call plot
let r1 52
add r2 r2 4
call plot
let r1 54
add r2 r2 4
call plot
let r1 53
add r2 r2 4
call plot
let r1 51
add r2 r2 4
call plot
let r1 52
add r2 r2 4
call plot


;chemin
let r0 brown
let r1 30
let r2 15
let r3 33
let r4 1
call draw
let r1 31
let r2 15
let r3 34
let r4 1
call draw
let r1 32
let r2 15
let r3 35
let r4 1
call draw
let r1 33
let r2 15
let r3 36
let r4 1
call draw
let r1 34
let r2 15
let r3 37
let r4 1
call draw
let r1 35
let r2 15
let r3 38
let r4 1
call draw

;tronc
let r1 110
let r2 70
let r3 120
let r4 16
let r0 brown
call fill


;feuilles
let r0 green2
let r1 100
let r2 80
let r3 130
let r4 70
call fill
let r1 105
let r2 90
let r3 125
let r4 80
call fill
let r1 110
let r2 100
let r3 120
let r4 90
call fill


jump 0
.include graphics.s