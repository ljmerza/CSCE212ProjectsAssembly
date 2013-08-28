.data
array: .space 4000 # create an array with 4000 bytes allocated
message1: .asciiz "Enter an integer: 99999 to exit \n"
message2: .asciiz "The array contains the following: \n"
next_line: .asciiz "\n"

.text
.globl main
main:

la $a1, array # load address of array into a1
li $t0, 0 # i = 0
li $t1, 99999 # special value 99999 to indicate end of sequence

loop:
la $a0, message1 # load message1 asking to enter int
li $v0, 4 # four is display_string
syscall # syscall the displaying of message1
li $v0, 5 # five is read_int
syscall # syscall of read_int
beq $v0, $t1, sort # if int is equal to 99999 then jump to sort
addi $t0, $t0, 4 # add four to i of the loop
sw $v0, ($a1) # store new int into array
addi $a1, $a1, 4 # move the array marker over by one element
j loop # jump back to beginning of loop

sort:
la $t4, array # t0 is number up to outer loop
la $t1, array # t1 is number comparing to inner loop
addi $t1, $t1, 4 # get next int of array and store in t1
la $t8, array # load array into t8
add $t8, $t0, $t8 # load end of array into t8
la $t9, array # load array into t9
add $t9, $t0, $t9 # load end of array into t9
addi $t9, $t9, -4 # load second to last element of array into t9

loops:
lw $t2, ($t4) # load first int to compare
lw $t3, ($t1) # load second int to compare
bgt  $t2, $t3, next # if first int greater than second int then jump to next
sw $t3, ($t4) # store second int into first int
sw  $t2, ($t1) # store first int into second int

next:
addi $t1, $t1, 4 # increment inner loop
blt  $t1, $t8, loops # is inner loop done
addi $t4, $t4, 4 # increment outer loop
move $t1, $t4
addi $t1, $t1, 4 # increment inner loop
blt  $t4, $t9, loops # check if outer loop done
 
printArray:
la $a1, array # load array into a1
la $a0, message2 #display message 2
li $v0, 4 # four is display string
syscall # syscall the display of message2
loop1:
blez $t0, done # if t0 equals zero go to done
li $v0, 1 # load current int into syscall
lw $a0, 0($a1) # load current int into register
syscall # syscall to display the current int
la $a0, next_line # load next line
li $v0, 4 # four is display string
syscall # syscall to move marker to next line
addi $a1, $a1, 4 # go to next int address in array
addi $t0, $t0, -4 # decrement counter by 4
j loop1
done:
j done
