.data
str1: .asciiz "Input A = "
str2: .asciiz "Input B = "
.text

main:

### read the arguments into f2 and f4 registers and store the inputed values in s0,s1 and s2,s3 registers

li $v0,4
la $a0,str1
syscall

li $v0,7
syscall
mov.d $f2,$f0

li $v0,4
la $a0,str2
syscall

li $v0,7
syscall
mov.d $f4,$f0

mfc1 $s0,$f2
mfc1 $s1,$f3

mfc1 $s2,$f4
mfc1 $s3,$f5


### take the sings, exponents and mantissas of our numbers and store them in t and s registers. add the hidden bits

andi $t7, $s1, 0x80000000 # sign of number A
andi $t8, $s3, 0x80000000 # sign of number B
andi $s4, $s1, 0x7FF00000 # exponent of number A
andi $s5, $s3, 0x7FF00000 # exponent of number B
andi $s1, $s1, 0xFFFFF # first part of mantissa of number A
andi $s3, $s3, 0xFFFFF # first part of mantissa of number B
ori $s1, $s1, 0x100000
ori $s3, $s3, 0x100000

# check exponents. operations on matissas
bgtu $s4, $s5, expA_is_greater
move $s6, $s5
beq $s4, $s5, subtract

# operations on mantissa A

subu $s7, $s5, $s4 # (expB) - (expA)
srl $s7, $s7, 20 # shift right 20-th times $s7
srlv $s0, $s0, $s7 # shift right $s0
li $t0, 32
subu $t0, $t0, $s7 # $t0 - $s7
sllv $t1, $s1, $t0 # shift left $s1
or $s0, $s0, $t1 # adding shifted mantyssa of A into $s0
srlv $s1, $s1, $s7 # shift right $s1
b subtract


# operations on mantissa B
expA_is_greater:
move $s6, $s4
subu $s7, $s4, $s5 # (expA) - (expB)
srl $s7, $s7, 20 # shift right 20-th times $s7
srlv $s2, $s2, $s7 # shift right $s2
li $t0, 32
subu $t0, $t0, $s7 # $t0 - $s7
sllv $t1, $s3, $t0 # shift left $s3
or $s2, $s2, $t1 # adding shifted mantyssa of A into $s2
srlv $s3, $s3, $s7 # shift right $s3



### add mantissas
subtract:
beq $t7, $t8, same_signs
bltu $s1, $s3, B_bigger_pos

# A is greater
bgeu $s0, $s2, uf #check underflow
add $s3, $s3, 1

uf: 
sub $s0, $s0, $s2 # mant(A) - mant(B)
sub $s1, $s1, $s3 # mant(A) - mant(B)

# set the sign if A is greater
bne $t7, $zero, negative_if_A_greater
li $t9, 0 # result positive
b normalize_equal_signs_check

negative_if_A_greater:
li $t9, 0x80000000 # result negative
b normalize_equal_signs_check

# B is greater
B_bigger_pos:
bgeu $s2, $s0, of #check underflow
add $s1, $s1, 1

of: 
subu $s0, $s2, $s0 # mant(B) - mant(A)
subu $s1, $s3, $s1 # mant(B) - mant(A)

# set the sign if B is greater  signs_if_B_greater:
bne $t7, $zero, negative_if_B_greater
li $t9, 0x80000000 # result negative
b normalize_equal_signs_check

negative_if_B_greater:
li $t9, 0 # result positive
b normalize_equal_signs_check

# A and B are equal
same_signs:
addu $s7, $s0, $s2
bgt $s2, $s7, over #check overflow
bgeu $s7, $s0, next5
over:
add $s3, $s3, 1

next5: # mant(A) + mant(B)

addu $s1, $s1, $s3 # mant(A) + mant(B)
move $s0, $s7
b normalize_notequal_signs_check

### normalize the result

normalize_equal_signs_check:
or $t2, $s1, $s0
beqz $t2, zero
srl $t0, $s1, 20 # shift right 20-th times $s1
bgtu $t0, $zero,output_create # branch if(t0 > 0)

normalize_equal_signs:
sll $s1, $s1,1
andi $t1, $s0, 0x80000000
srl $t1, $t1, 31
sll $s0, $s0,1
or $s1, $s1, $t1
subiu $s6, $s6,0x100000 # Substruct bit from output exponent
srl $t0, $s1, 20
beqz $t0, normalize_equal_signs # branch if(t0 = 0)

output_create:
xori $s1, $s1, 0x100000 # remove leading bit from output mantissa
or $s1, $s1, $s6 # adding exponent and second part of mantisa
or $s1, $s1, $t9 # adding proper sign
b finish



normalize_notequal_signs_check:
andi $t0, $s1, 0xFFE00000 # Put the logical AND of register $s1 and 0xFFE00000 into $t0
beqz $t0,output_create # Branch to the lable if(t0 = 0)

normalize_notequal_signs:
sll $t1, $s1,31 # shift left $s1 31-times and put result into $t1
srl $s1, $s1, 1 # shift right $s1 1-time and put result into $s1
srl $s0, $s0, 1 # shift right $s0 1-time and put result into $s0
or $s0, $s0, $t1 # Put the logical OR of register $s0 and $t1 into $s0
addu $s6, $s6,0x100000 # Add bit to output exponent 
b normalize_notequal_signs_check

zero:
move $s0, $zero
move $s1, $zero

finish:
mtc1 $s0, $f12
mtc1 $s1, $f13
li $v0, 3
syscall

li $v0,10
syscall