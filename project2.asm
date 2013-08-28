.data
message1: .asciiz "Enter the first integer: "
message2: .asciiz "Enter the second integer: "
message3: .asciiz "The product is: "
message4: .asciiz "\nThe quotient is: "
message5: .asciiz "\nThe remainder is: "
message6: .asciiz "\nCan't divide by zero"
message7: .asciiz "\nIntegers not in range"

.text
.globl main
main:

li $t0, 0 # i = 0
li $t1, 0 # j = 0
li $t2, 0 # quotient
li $t4, 65536 # max integer
li $t5, -1 # min integer

la $a0, message1 # load message1 asking to enter int
li $v0, 4 # four is display_string
syscall # syscall the displaying of message1
li $v0, 5 # five is read_int
syscall # syscall of read_int
addu $s0, $v0, $zero # store int #1

la $a0, message2 # load message1 asking to enter int
li $v0, 4 # four is display_string
syscall # syscall the displaying of message1
li $v0, 5 # five is read_int
syscall # syscall of read_int
addu $s1, $v0, $zero # store int #2

bnez  $s1, check2 #if int 2 not equal to zero then continue
la $a0, message6 # load message6 cant divide by zero
li $v0, 4 # four is display_string
syscall # syscall the displaying of message6
j exit # jump to exit

check2:
blt  $s1, $t5, exit # check if int #2 less than zero
blt $s0, $t5, exit # check if int #1 less than zero 
bge $s1, $t4, exit # check if int #2 greater than 65535
blt $s0, $t4, loop1 # check if int #1 greater than 65535
j exit # jump to exit

loop1:
beq  $t1, $s1, next1 # if counter = int #2 jump to next
addu $t0, $t0, $s0 # add int #1 to temp0
addiu $t1, $t1, 1 # increment counter
j loop1 # jump back to continue multiplying

next1:
la $a0, message3 # load message3 the product is
li $v0, 4 # four is display string
syscall # syscall the displaying of message3
addu $a0, $t0, $zero # load integer into arguement
li $v0, 1 # load current int into syscall
syscall # display the product

loop2:
blt $s0, $s1, next2 # if int #1
subu $s0, $s0, $s1 # subtract #2 from #1
addiu $t3, $t3, 1 # add one to quotient
j loop2 # jump back to loop2 to divide again

next2:
la $a0, message4 # load message4 the quotient is
li $v0, 4 # four is display string
syscall # syscall the displaying of message4
addu $a0, $t3, $zero # load integer into arguement
li $v0, 1 # load current int into syscall
syscall
la $a0, message5 # load message5 the remainder is
li $v0, 4 # four is display string
syscall # syscall the displaying of message5
addu $a0, $s0, $zero # load integer into arguement
li $v0, 1 # load current int into syscall
syscall

exit:
li $v0, 10 # load terminate program
syscall # Exit
