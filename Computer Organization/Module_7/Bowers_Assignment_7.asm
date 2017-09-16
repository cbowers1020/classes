.data
	promptInput: 	.asciiz "\nInput Roman Numerals in either upper or lower case: "
	promptOutput:	.asciiz "\nThe Roman Numeral you entered was: "
	promptDec:	.asciiz "\nThe decimal value of Roman Numeral entered is: "
	promptCont:	.asciiz "\nTo enter another Roman Numeral enter '1'. Enter '0' to quit program: "
	programEnd:	.asciiz "\n\nProgram has ended\n\n"
	inputError:	.asciiz "\nInvalid character found\n"
	
	# Input manipulators
	numInput:	.space 32
	cont:		.word 2
	bitIter:	.word 0
	sum:		.word 0	
	
	# Lookup table
	rNumerals:	.asciiz "IVXLCDMivxlcdm"
	aNumbers:	.byte 	1, 5, 10, 50, 100, 500, 1000, 1, 5, 10, 50, 100, 500, 1000


### MAIN PROGRAM ###
.text
.globl main
main:
	# Grab text from user
	li $a0, 0
	li $v0, 4
	la $a0, promptInput
	syscall
	
	# Load input
	li $a0, 0
	la $a0, numInput	# buffer
	la $a1, numInput	# length
	li $v0, 8 
	syscall
	
	# Store register
	sw $ra, 0($sp)	
	addi $sp, $sp, -4
	
	# call char processing subroutine
	jal procInput

	# restore register pointer
	lw $ra, 0($sp)		
	addi $sp, $sp, 4
	
	# Display results
	# original input
	li $a0, 0
	li $v0, 4
	la $a0, promptOutput
	syscall
	
	# User entered string
	li $a0, 0
	li $v0, 4
	la $a0, numInput
	syscall
	
	# Decimal equivalent
	li $a0, 0
	li $v0, 4
	la $a0, promptDec
	syscall
	
	# Output the actual decimal equivalent
	li $a0, 0
	li $v0, 1
	lw $a0, sum
	syscall
	
	# Determine to end or continue
	li $a0, 0
	la $a0, promptCont
	li $v0, 4
	syscall
	
	# Grab user input to end or enter another RN
	li $v0, 5
	syscall
	
	# Save input
	sw $v0, cont
	lw $t0, cont
	
	bne $t0, 1, end 	# if user enters not 1, exit
	
	move $s0, $0		# reset relvant registers
	sw $0, sum
	sw $0, bitIter
	
	j main 			# rerun
	

### ProcInput Subroutine ###	
# Translate RN input into decimal
procInput:
	
	# Zero out relevant registers for numerical certainty
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $a0, 0
	
	# Load register $t0 with space for numInput
	la $t0, numInput	# Load input string
	la $t1, rNumerals 	# Load rNumerals lookup table	
	li $a0, 0
	
	# Loop through input to convert characters
loop1:
	lb $t2, ($t0) 		# Get leftmost byte of input

	beq $t2, 0, return	# If we have a zero, we've encountered end of input, return
	beq $t2, 1, return	# If we have one, we've encountered EOL, return
	
	
	# Loop through rNumerals to get matching input to rNumeral
loop2:	
	lb $t3, ($t1)		# Load 1st byte of rNumerals
	
	beq $t2, $t3, getArab   # Found match, convert to Arabic numeral 
	
	addi $t1, $t1, 1		# Move to next byte in rNumerals	
	j loop2		# Iterate loop
	
	# Get arabic value for rNumeral
getArab: 
	li $t5, 0
	li $t4, 0
	la $t5, rNumerals 	# Address of rNumerals
	la $t4, aNumbers	# Address of aNumbers
	
	sub $t6, $t1, $t5	# Get index of rNumeral value that matches input byte
	add $t4, $t4, $t6	
	lbu $t7, ($t4)		# $t7 is decimal value of $t4 roman numeral
	blt $t7, 232, pTrans	# Greatest value for signed val is 232, val needs updated
	
trans1:
	seq $a1, $t7, 244 	# If the char == D, $a1 = 1, else $a1 = 0
	beq $a1, 1, trans2	# If D, go to trans2 no need to test if d
	mul $t7, $t7, $0	# Zero out $t7 to give new, accurate value
	addi $t7, $t7, 1000	# Set $t7 equal to 1000
	
	j pTrans		# jump to post trans 
	
trans2: 
	mul $t7, $t7, $0	# Zero out $t7
	addi $t7, $t7, 500	# Char == D/d, set equal to 500
	j pTrans
	
pTrans:
	sw $ra, 4($sp)		# Store calc sub addr in stack
	addi $sp, $sp, -4	# move pointer for one item
	
	
	jal calc		# jump to subroutine calc.
	
	
	addi $sp, $sp, 4	# reset calc stack pointer
	lw $ra, 4($sp)		# restore 
	
	la $t1, rNumerals	# reset $t1 pointer to beginning of rNumerals
	addi $t0, $t0, 1	# Move to next character in input string
	j loop1 		# iterate again
	
return:
	sw $s0, sum		# store sum
	addi $sp, $sp, 4	# restore register
	lw $ra, 0($sp)		# load main calling addr
	jr $ra			# return to main
	
	
## Need to compare current val with previous val to know
## what math to do. If XI, sum = sum + I. If IX, sum = sum + 
## If sting len = 1, then sum = single decimal
calc:
	lw $s0, sum		# Load sum
	beqz $s0, one		# Base case
	
	lw $t8, bitIter		# Load n-1 val
	sw $t7, bitIter		# update bitIter to current n val
	
	la $t1, rNumerals	# Reset pointer to beginning of rNumerals
	bge $t8, $t7, addition	# If n - 1 >= n, then sum = sum + n
	blt $t8, $t7, subtract	# If n - 1 < n, then sum = sum + (n - 2*(n-1))
	
addition:
	add $s0, $s0, $t7	# add current val to sum
	sw $s0, sum		# store updated sum in sum
	jr $ra			# jump to next iteration, loop1
	
subtract:
	mul $t8, $t8, 2		# multiply (n-1) by 2
	sub $t7, $t7, $t8	# subtract 2*(n-1)n from n
	add $s0, $s0, $t7	# add (n - 2*(n-1)) to sum
	sw $s0, sum		# store updated sum in sum
	jr $ra			# jump to next iteration, loop1
	
## Base case, add decimal to sum and iterate again
one:
	add $s0, $s0, $t7	# add first decimal to sum	
	sw $s0, sum		# store $s0 in sum to maintain total
	sw $t7, bitIter		# store value n for n+1 calc
	jr $ra			# return to loop1


### PROGRAM END ###
end:
	li $v0, 4		# prompt end message
	la $a0, programEnd
	syscall
	
	# End program:
	li $v0, 10
	syscall
		
				
