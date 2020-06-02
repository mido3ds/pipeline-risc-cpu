# all numbers in hex format
# we always start by reset signal
#if you don't handle hazards add 3 NOPs
#this is a commented line
.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10
#you should ignore empty lines

.ORG 2  #this is the interrupt address
100

.ORG 10
in R1     #R1=30
in R2     #R2=50
in R3     #R3=100
in R4     #R4=300
in R6     #R6=FFFFFFFF 
in R7     #R7=FFFFFFFF   
Push R4   #sp=7FC, M[7FE, 7FF]=300
call r4
pop r7
INC R7	  # this statement shouldn't be executed,
END
 

 .org 300
 push R1
 inc r0
 pop r0
 ret