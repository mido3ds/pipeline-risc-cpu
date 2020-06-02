# all numbers in hex format
# we always start by reset signal
#this is a commented line
.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10
#you should ignore empty lines

.ORG 2  #this is the interrupt address
100

.ORG 10
in R2        #R2=0CDAFE19 add 0CDAFE19 in R2
in R3        #R3=FFFF
in R4        #R4=F320
#NOP from assembler
LDM R1,F5    #R1=F5

#NOP from assembler
NOP 			#added for load
PUSH R1      #SP=7FC, M[7FE, 7FF] = F5

NOP
NOP
#NOP from assembler
PUSH R2      #SP=7FA,M[7FC, 7FD]=0CDAFE19

NOP
NOP
NOP				#added by ev
POP R1       #SP=7FC,R1=0CDAFE19

NOP
NOP
NOP				#added by ev
POP R2       #SP=7FE,R2=F5


#NOP from assembler
#NOP from assembler
STD R2,200   #M[200, 201]=F5


#NOP from assembler
#NOP from assembler
STD R1,202   #M[202, 203]=0CDAFE19

#NOP from assembler
LDD R3,202   #R3=0CDAFE19

#NOP from assembler
LDD R4,200   #R4=F5
END
