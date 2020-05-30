.ORG 0
10

.ORG 10
inc r0
inc r1
inc r0
std r0,4
ldd r1,4
inc r1
inc r2   # ignored
inc r3   # done twice ! so stalling done after one cycle not before !
inc r4
END