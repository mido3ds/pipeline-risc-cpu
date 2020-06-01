# all numbers in hex format
# we always start by reset signal
#this is a commented line
.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10
#you should ignore empty lines

.ORG 2  #this is the interrupt address
100

.ORG 10
inc R1
inc R1
NOT R1
Dec R1
END