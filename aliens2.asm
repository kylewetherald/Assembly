# SPACE INVADERS
# by Kyle Wetherald
# ktw9@pitt.edu

.data

queue:		.space 416
game_over:	.asciiz "Game over.\nNumber of Aliens hit: "

.text
# main variables:
# $s0 = astronaut x
# #s1 = start time
# $s2 = time step
# $s3 = hit counter
# $s4 = old tail
# $s6 = queue head
# $s7 = queue tail
main:
	jal _init
	li	$v0, 30			# service 30 gets system time.
	syscall
	move	$s1, $a0
	move	$s2, $s1

_poll:
	# check for a key press
	la	$t0,0xffff0000		# status register address	
	lw	$t0,0($t0)		# read status register
	andi	$t0,$t0,1		# check for key press
	bne	$t0,$0,_keypress
	
	#if(time - time step >=100)
	li	$v0, 30			# service 30 gets system time.
	syscall
	sub	$t0, $a0, $s2
	blt	$t0, 100, _poll_end
	move	$s2, $a0		# time stem = current time
	move	$s4, $s7		#old tail = tail
event_loop:
	# do
	beq	$s6, $s7, _poll_end
	jal	pop
	move	$t7, $v0
	srl	$t9, $t7, 16		# store direction
	andi	$t9, $t9, 0x0000000f
	srl	$t8, $t7, 20		# store shrapnel distance
	andi	$t8, $t8, 0x0000000f
	andi	$a1, $t7, 0x000000ff	# set y
	andi	$a0, $t7, 0x0000ff00	# set x
	srl	$a0, $a0, 8
	li	$a2, 0x0		# set color
	jal	_setLED


   _n:
	bne	$t9, 0, _ne
	addi	$a1, $a1, -1		# y--
	blt	$a1, $0, event_loop_end #if y<0, don't push onto queue
	jal	_getLED
	beq	$v0, 3, alien_hit
	li	$a2, 0x1		# set color
	jal	_setLED
	andi	$t7, $t7, 0xffffff00	#else: update y coord.
	or	$t7, $t7, $a1
	move	$a0, $t7
	jal	push
	j	event_loop_end
   _ne:
   	bne	$t9, 1, _e
   	addi	$a1, $a1, -1		# y--
   	blt	$a1, $0, event_loop_end # if y<0, don't push onto queue
   	addi	$a0, $a0, 1		# x++
   	beq	$a0, 64, event_loop_end # if x=64, don't push onto queue
   	addi	$t8, $t8, -1		# shrapnel--
   	blt	$t8, $0, event_loop_end # if shrapnel<0, don't push onto queue
   	jal	_getLED
	beq	$v0, 3, alien_hit
   	li	$a2, 0x1		# set color
   	jal	_setLED
	andi	$t7, $t7, 0xff0f0000
	or	$t7, $t7, $a1		# update y coord
	sll	$a0, $a0, 8
	or	$t7, $t7, $a0		# update x coord.
	sll	$t8, $t8, 20	
	or	$t7, $t7, $t8		# update shrapnel
	move	$a0, $t7
	jal	push
   	j	event_loop_end
   _e:
   	bne	$t9, 2, _se
   	addi	$a0, $a0, 1		# x++
   	beq	$a0, 64, event_loop_end # if x=64, don't push onto queue
   	addi	$t8, $t8, -1		# shrapnel--
   	blt	$t8, $0, event_loop_end # if shrapnel<0, don't push onto queue
   	jal	_getLED
	beq	$v0, 3, alien_hit
   	li	$a2, 0x1		# set color
   	jal	_setLED
   	andi	$t7, $t7, 0xff0f00ff
   	sll	$a0, $a0, 8
	or	$t7, $t7, $a0		# update x coord.
	sll	$t8, $t8, 20	
	or	$t7, $t7, $t8		# update shrapnel
	move	$a0, $t7
	jal	push
   	j	event_loop_end
   _se:
   	bne	$t9, 3, _s
   	addi	$a1, $a1, 1		# y++
   	beq	$a1, 63, event_loop_end # if y=63, don't push onto queue
   	addi	$a0, $a0, 1		# x++
   	beq	$a0, 64, event_loop_end # if x=64, don't push onto queue
   	addi	$t8, $t8, -1		# shrapnel--
   	blt	$t8, $0, event_loop_end # if shrapnel<0, don't push onto queue
   	jal	_getLED
	beq	$v0, 3, alien_hit
   	li	$a2, 0x1		# set color
   	jal	_setLED
   	andi	$t7, $t7, 0xff0f0000
	or	$t7, $t7, $a1		# update y coord
	sll	$a0, $a0, 8
	or	$t7, $t7, $a0		# update x coord.
	sll	$t8, $t8, 20	
	or	$t7, $t7, $t8		# update shrapnel
	move	$a0, $t7
	jal	push
   	j	event_loop_end
   _s:
   	bne	$t9, 4, _sw
   	addi	$a1, $a1, 1		# y++
   	beq	$a1, 63, event_loop_end # if y=63, don't push onto queue
   	addi	$t8, $t8, -1		# shrapnel--
   	blt	$t8, $0, event_loop_end # if shrapnel<0, don't push onto queue
   	jal	_getLED
	beq	$v0, 3, alien_hit
   	li	$a2, 0x1		# set color
   	jal	_setLED
   	andi	$t7, $t7, 0xff0fff00
	or	$t7, $t7, $a1		# update y coord
	sll	$t8, $t8, 20	
	or	$t7, $t7, $t8		# update shrapnel
	move	$a0, $t7
	jal	push
   	j	event_loop_end
   _sw:
   	bne	$t9, 5, _w
   	addi	$a1, $a1, 1	# y++
   	beq	$a1, 63, event_loop_end # if y=63, don't push onto queue
   	addi	$a0, $a0, -1		# x--
   	blt	$a0, $0, event_loop_end # if x<0, don't push onto queue
   	addi	$t8, $t8, -1		# shrapnel--
   	blt	$t8, $0, event_loop_end # if shrapnel<0, don't push onto queue
   	jal	_getLED
	beq	$v0, 3, alien_hit
   	li	$a2, 0x1		# set color
   	jal	_setLED
   	andi	$t7, $t7, 0xff0f0000
	or	$t7, $t7, $a1		# update y coord
	sll	$a0, $a0, 8
	or	$t7, $t7, $a0		# update x coord.
	sll	$t8, $t8, 20	
	or	$t7, $t7, $t8		# update shrapnel
	move	$a0, $t7
	jal	push
   	j	event_loop_end
   _w:
   	bne	$t9, 6, _nw
   	addi	$a0, $a0, -1		# x--
   	blt	$a0, $0, event_loop_end # if x<0, don't push onto queue
   	addi	$t8, $t8, -1		# shrapnel--
   	blt	$t8, $0, event_loop_end # if shrapnel<0, don't push onto queue
   	jal	_getLED
	beq	$v0, 3, alien_hit
   	li	$a2, 0x1		# set color
   	jal	_setLED
   	andi	$t7, $t7, 0xff0f00ff
   	sll	$a0, $a0, 8
	or	$t7, $t7, $a0		# update x coord.
	sll	$t8, $t8, 20	
	or	$t7, $t7, $t8		# update shrapnel
	move	$a0, $t7
	jal	push
   	j	event_loop_end
   _nw:
   	bne	$t9, 7, _sn
   	addi	$a1, $a1, -1		# y--
   	blt	$a1, $0, event_loop_end # if y<0, don't push onto queue
   	addi	$a0, $a0, -1		# x--
   	blt	$a0, $0, event_loop_end # if x<0, don't push onto queue
   	addi	$t8, $t8, -1		# shrapnel--
   	blt	$t8, $0, event_loop_end # if shrapnel<0, don't push onto queue
   	jal	_getLED
	beq	$v0, 3, alien_hit
   	li	$a2, 0x1		# set color
   	jal	_setLED
   	andi	$t7, $t7, 0xff0f0000
	or	$t7, $t7, $a1		# update y coord
	sll	$a0, $a0, 8
	or	$t7, $t7, $a0		# update x coord.
	sll	$t8, $t8, 20	
	or	$t7, $t7, $t8		# update shrapnel
	move	$a0, $t7
	jal	push
   	j	event_loop_end
   _sn:
   	addi	$a1, $a1, -1		# y--
	blt	$a1, $0, event_loop_end #if y<0, don't push onto queue
	addi	$t8, $t8, -1		# shrapnel--
   	blt	$t8, $0, event_loop_end # if shrapnel<0, don't push onto queue
   	jal	_getLED
	beq	$v0, 3, alien_hit
   	li	$a2, 0x1		# set color
   	jal	_setLED
	andi	$t7, $t7, 0xff0fff00	#else: update y coord.
	or	$t7, $t7, $a1
	sll	$t8, $t8, 20	
	or	$t7, $t7, $t8		# update shrapnel
	move	$a0, $t7
	jal	push
	j	event_loop_end
	
alien_hit:
	li	$t7, 0x0	
	or	$t7, $t7, $a1		# set y
	sll	$t0, $a0, 8
	or	$t7, $t7, $t0		# set x
	li	$a2, 1
	jal	_setLED
	
	#n
	andi	$t7, $t7, 0x0000ffff	# mask so that only x and y remain
	ori	$t7, $t7, 0x00080000	# set direction
	ori	$t7, $t7, 0x00900000	# set shrapnel
	move	$a0, $t7
	jal	push
	addi	$s3, $s3, 1
	#ne
	andi	$t7, $t7, 0xfff0ffff	# mask out direction
	ori	$t7, $t7, 0x00010000	# set direction
	move	$a0, $t7
	jal	push
	#e
	andi	$t7, $t7, 0xfff0ffff	# mask out direction
	ori	$t7, $t7, 0x00020000	# set direction
	move	$a0, $t7
	jal	push
	#se
	andi	$t7, $t7, 0xfff0ffff	# mask out direction
	ori	$t7, $t7, 0x00030000	# set direction
	move	$a0, $t7
	jal	push
	#s
	andi	$t7, $t7, 0xfff0ffff	# mask out direction
	ori	$t7, $t7, 0x00040000	# set direction
	move	$a0, $t7
	jal	push
	#sw
	andi	$t7, $t7, 0xfff0ffff	# mask out direction
	ori	$t7, $t7, 0x00050000	# set direction
	move	$a0, $t7
	jal	push
	#w
	andi	$t7, $t7, 0xfff0ffff	# mask out direction
	ori	$t7, $t7, 0x00060000	# set direction
	move	$a0, $t7
	jal	push
	#nw
	andi	$t7, $t7, 0xfff0ffff	# mask out direction
	ori	$t7, $t7, 0x00070000	# set direction
	move	$a0, $t7
	jal	push
	
	
event_loop_end:
	# while  queue !empty //head-4 != old tail
	subi	$t0, $s6, 4
	bne	$t0, $s4, event_loop
	j _poll_end
	
	
_poll_end:
	# if less than two minutes:
	sub	$t0, $s2, $s1
	li	$t1, 120000
	blt	$t1, $t0, exit
	j	_poll
	
_keypress:
	# handle a keypress to change snake direction
	la	$t0,0xffff0004	# keypress register
	lw	$t0,0($t0)	# read keypress register


	# center key
	subi	$t1, $t0, 66			# center key?
	beq	$t1, $0, center_pressed		# 

	# left key
	subi	$t1, $t0, 226			# left key?
	beq	$t1, $0, left_pressed		# 

	# right key
	subi	$t1, $t0, 227			# right key?
	beq	$t1, $0, right_pressed		# 

	# up key
	subi	$t1, $t0, 224			# up key?
	beq	$t1, $0, up_pressed		# 

	# down key
	subi	$t1, $t0, 225			# down key?
	beq	$t1, $0, down_pressed		# 
	j	_poll

right_pressed:
	move	$a0, $s0
	li	$a1, 63
	li	$a2, 0
	jal	_setLED
	
	addi	$s0, $s0, 1
	bne	$s0, 64, _right_pressed
	li	$s0, 0
_right_pressed:
	move	$a0, $s0
	li	$a1, 63
	li	$a2, 2
	jal	_setLED
	j	_poll


left_pressed:
	move	$a0, $s0
	li	$a1, 63
	li	$a2, 0
	jal	_setLED
	
	addi	$s0, $s0, -1
	bne	$s0, -1, _left_pressed
	li	$s0, 63
_left_pressed:
	move	$a0, $s0
	li	$a1, 63
	li	$a2, 2
	jal	_setLED
	j	_poll

# low 24 bits of queue:
#       0000 0000 00000000 00000000
# shrapnel:
#	0000
# direction: 
#	N  = 0000... = 0x00000
#	NE = 0001... = 0x10000
#	E  = 0010... = 0x20000
#	SE = 0011... = 0x30000
#	S  = 0100... = 0x40000
#	SW = 0101... = 0x50000
#	W  = 0110... = 0x60000
#	NW = 0111... = 0x70000
#	SN = 1000... = 0x80000 (shrapnel north)
# x: 00000000 -   00111110
# y: 00000000 -            00111111

# direction = N
# y = 62 = 0x 3e
up_pressed:
	#direction
	move	$a0, $s0   # set x coordinate
	li	$a1, 0x003e
	li	$a2, 0x1		# set color
	jal	_setLED
	sll	$a0, $a0, 8	
	ori	$a0, 0x003e	# set y coordinate to 62
	jal	push		# push event onto queue
	j	_poll

down_pressed:
	j 	exit

center_pressed:
	j	exit

exit:
	la	$a0, game_over
	li	$v0, 4
	syscall
	move	$a0, $s3
	li	$v0, 1
	syscall
	li	$v0, 10
	syscall
	
# push(x)
# 	adds x to the queue
#
# arguments: $a0 is x
# returns: nothing
push:
	la	$t0, queue
	add	$t1, $t0, $s7	
	sw	$a0, 0($t1)	# queue[tail] = x;
	addi	$s7, $s7, 4	# tail++;
	blt	$s7, 416, exit_push	# if(tail >= 1000){ 
	li	$s7, 0		# tail = 0; }
exit_push:	
	jr	$ra		# return;

# pop()
#	removes and returns the value at the head of the queue
# arguments: none
# returns: $v0
pop:
	la	$t0, queue
	add 	$t1, $t0, $s6
	lw	$v0, 0($t1)	# $v0 = queue[head]
	addi	$s6, $s6, 4	# tail++;
	blt	$s6, 416, exit_pop	# if (head >= 1000){
	li	$s6, 0		# tail = 0; }
exit_pop:
	jr	$ra		# return;

	# void _setLED(int x, int y, int color)
	#   sets the LED at (x,y) to color
	#   color: 0=off, 1=red, 2=orange, 3=green
	#
	# arguments: $a0 is x, $a1 is y, $a2 is color
	# trashes:   $t0-$t3
	# returns:   none
	#
_setLED:
	# byte offset into display = y * 32 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008	# base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	jr	$ra

		
	# int _getLED(int x, int y)
	#  returns the value of the LED at position (x,y)
	#
	#  arguments: $a0 holds x, $a1 holds y
	#  trashes:   $t0-$t2
	#  returns:   $v0 holds the value of the LED (0, 1, 2 or 3)
	#
_getLED:
	# range checks
	bltz	$a0,_getLED_exit
	bltz	$a1,_getLED_exit
	bge	$a0,64,_getLED_exit
	bge	$a1,64,_getLED_exit
	
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits
_getLED_exit:	
	jr   $ra
	
# raind_init()
# 	initializes random number generator to system time
# arguments: none
# returns: nothing
rand_init:
	# get the system time
	li	$v0, 30
	syscall

	# set the seed and the id
	move	$a1, $a0	# seed
	li	$a0, 1		# id
	li	$v0, 40
	syscall
		
	jr $ra

# getrandomnumber(upper)
# 	generates a rancom number between 0 and upper
# arguments: $a0 is upper 
# returns: $v0 is the random number 
getrandomnumber:
	subi	$sp, $sp, 4
	sw	$ra, 0($sp)

	move	$a1, $a0	# upper bound
	li	$a0, 1		# id
	li	$v0, 42
	syscall
	# a0 has the random number
	move	$v0, $a0

	# post
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4

	jr	$ra



# void init()
#	places 64 green aliens on the board
#	places  astronaut on board
#
# arguments: none
# returns: nothing
_init:
	addi 	$sp, $sp, -16
	sw	$s1, 0($sp)
	sw	$s2, 4($sp)
	sw	$s3, 8($sp)
	sw	$ra, 12($sp)
	
	jal	rand_init
	
	add	$s3, $0, $0	#$s1 = 0;
	
_init_loop:
	li	$a0, 63
	jal 	getrandomnumber
	move	$s1, $v0
	li	$a0, 62
	jal	getrandomnumber
	move	$s2, $v0
	move	$a0, $s1
	move	$a1, $s2
	jal	_getLED
	move	$a0, $s1
	move	$a1, $s2
	beq	$v0, 3, usedLED
	li	$a2, 3
	jal	_setLED	
	addi	$s3, $s3, 1
usedLED:
	bne	$s3, 64, _init_loop
	li	$s0, 32
	move	$a0, $s0
	li	$a1, 63
	li	$a2, 2
	jal	_setLED
	
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	lw	$s3, 8($sp)
	lw	$ra, 12($sp)	
	addi 	$sp, $sp, 16
	jr	$ra
	

	

	
