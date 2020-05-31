.org 2
ldm r4,20
inc r3
call r4
END


.org 20
inc r4
inc r3
ldm r5,50
call r5
ret

.org 50
in r7
inc r7
inc r7
ret