.data
	promptL:       .asciiz "\nEnter the large pool size: "
	promptS:       .asciiz "\nEnter the small pool size: " 
	lPool:         .asciiz "\n\nThe size of large pool: "
	sPool:         .asciiz "\n\nThe size of small pool: "
	selectLPrompt: .asciiz "Enter number of selections from large pool: "
	selectSPrompt: .asciiz "Enter number of selections from small pool: "
	responseL:     .asciiz "\nNumber of selections from large pool: "
	responseS:     .asciiz "\nNumber of selections from small pool: "
	finalOdds:     .asciiz "\n\nThe odds of winning the lottery are 1 in "
	concl:         .asciiz "\n\nThe program has finished"
.text	
.globl main
main:

	# $t0 = large pool size
	# $t1 = large pool select size
	# $t2 = small pool size
	# $t3 = small pool select size

	# Enter the large pool size
	li $v0, 4
	la $a0, promptL
	syscall
	li $v0, 5
	syscall
	addi $t0, $v0, 0
	
	# Enter the selection size from large pool
	li $v0, 4
	la $a0, selectLPrompt
	syscall
	li $v0, 5
	syscall
	addi $t1, $v0, 0
	
	#Enter the small pool size
	li $v0, 4
	la $a0, promptS
	syscall
	li $v0, 5
	syscall
	addi $t2, $v0, 0
	
	# Enter the small pool selection size
	li $v0, 4
	la $a0, selectSPrompt
	syscall
	li $v0, 5
	syscall
	addi $t3, $v0, 0
	
	# Print out info
	# Large pool value
	li $v0, 4
	la $a0, lPool 
	syscall
	li $v0, 1
	addi $a0, $t0, 0
	syscall
	# Large pool selection
	li $v0, 4
	la $a0, responseL
	syscall
	li $v0, 1
	addi $a0, $t1, 0
	syscall
	# Small pool value
	li $v0, 4
	la $a0, sPool
	syscall
	li $v0, 1
	addi $a0, $t2, 0
	syscall
	# Small pool selection size
	li $v0, 4
	la $a0, responseS
	syscall
	li $v0, 1
	addi $a0, $t3, 0
	syscall
	
	# Calculate n choose k for large pool
	add $a0, $t0, $zero   # Place large pool size in arg 0
	add $a1, $t1, $zero   # Place large pool select size in arg 1
	# Call subroutine to calculate number space
	jal comb
	
	add $t0, $v0, $zero   # Place large pool return value in $t0
	
	# calculate n choose k for small pool
	add $a0, $t2, $zero   # Place small pool size in arg 0
	add $a1, $t3, $zero   # Place small pool select size in arg 1
	# Call subroutine to caclulate number space
	jal comb
	
	add $t1, $v0, $zero   # Place small pool return value in $t1
	
	# Calculate total number space
	mul $t5, $t0, $t1   # Combine number space of small pool and large pool
	
	# Print out odds
	li $v0, 4
	la $a0, finalOdds
	syscall
	li $v0, 1
	move $a0, $t5
	syscall
	
	# Print conclusory message
	li $v0, 4
	la $a0, concl
	syscall
	
	# Exit program
	li $v0, 10
	syscall

## subroutine
# int comb (int pool, int select)
# {
#    int comb = pool;
#    n = 1
#    
#    while( n < select)
#    {
#      if (select > 1) {
#         n++
#         pool--;
#         comb = comb * pool;
#         comb = comb / n 
#      }
#     else {
#        break;
#     }
#    }
#    
#    return comb;
# }

# calculate n choose k for pool and selection size, this will be the number space
comb:
	addi $sp, $sp, -12  # adjust stack to make room for 3 items
	sw $t1, 8($sp)      # save register $t1 for use 
	sw $t0, 4($sp)      # save register $t0 for use 
	sw $s0, 0($sp)      # save register $s0 for use 
	
	add $s0, $a0, 0    # initialize return value to pool
	li $t1, 1           # set n = 1
	
loop:   bge $t1, $a1, exit  # n >= select calculation has finished
	beq $a1, 1, exit    # select = 1, so comb = pool
	addi $t1, $t1, 1    # increment n value
	addi $a0, $a0, -1   # decrement pool value
	mul $s0, $s0, $a0   # Calculate multiply part of combination
	div $s0, $s0, $t1   # divide comb by n
	j loop
 
exit:	add $v0, $s0, $zero # to return comb to main
	lw $s0, 0($sp)	    # restore register $s0 for caller
	lw $t0, 4($sp)      # restore register $t0 for caller
	lw $t1, 8($sp)      # restore register $t1 for caller
	addi $sp, $sp, 12   # adjust stack to delete 3 items
	jr $ra




