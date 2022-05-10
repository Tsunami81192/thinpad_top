.set noreorder
.set noat
.globl __start
.section text

__start:
.text
	li  $t0,0x31111 # q = 0x31111
	ori $t1, $0, 0 #int count = 0
	ori $t2, $0, 0 #int n = 0
	ori $t3, $0, 0 #int i = 0
	ori $t4, $0, 0 #int t = 0
	ori $t5, $0, 0 #临时变量
	ori $t6, $0, 1
	
loop1:
	addiu $t3, $t3, 1	#i++
	or   $t2, $0, $t3  #n=i
	ori   $t4, $0, 0    #t=0;

loop2:
	addiu $t4, $t4, 1 #t++
	sub   $t5, $t2, $t6 #n-1
	and   $t2, $t2, $t5 #n = n & (n-1)
	bne   $t2, $0,loop2
	nop
	addu  $t1, $t1, $t4
	bne   $t3, $t0,loop1
	nop
	li $s0, 0x80400000  # s0 = 0x80400000
	sw $t1, 0($s0)
	jr $ra
	nop
