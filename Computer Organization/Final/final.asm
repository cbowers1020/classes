.text   
.globl main
main:
	addi $t0, $t0, -100
	li $a0, 0
	li $v0, 4
	lw $a0, ($t0)
	syscall
	
	sll $t0, $t0, 1
	srl $t0, $t0, 1
	
	li $a0, 0
	li $v0, 4
	lw $a0, ($t0)
	syscall
	