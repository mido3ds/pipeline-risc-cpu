.ORG 2
LDM R5,100
nop
CALL R5
out r5
END
.org 50
in r7
ret

.org 100
inc r0
inc r1
ldm r4, 50
call r4
ret