# Kyle Wetherald
# 3755237
# ktw9@pitt.edu

.data

init_x:		.word	32
init_y:		.word	32
init_color:	.word	1


.text
#RANDOM POISITION

#INIT
# get the system time
li	$v0, 30
syscall

# set the seed and the id
move	$a1, $a0	# seed
li	$a0, 1		# id
li	$v0, 40
syscall

li	$a0, 64
jal getrandomnumber

move 	$s0, $v0
jal getrandomnumber
move	$s1, $v0

move	$a0, $s0
move	$a1, $s1
li	$a2, 3
jal	setLED

	# init red LED
	lw	$a0, init_x
	lw	$a1, init_y
	lw	$a2, init_color
	jal	setLED
	
_poll:
	# check for a key press
	la	$t0,0xffff0000	# status register address	
	lw	$t0,0($t0)	# read status register
	andi	$t0,$t0,1		# check for key press
	bne	$t0,$0,_keypress
	move	$s2,$a0
	move	$s3,$a1
	move	$a0,$s0
	move	$a1,$s1
	jal	_getLED
	beq	$v0, 0, _exit
	move	$a0,$s2
	move	$a1,$s3
	j	_poll

_keypress:
	# handle a keypress to change snake direction
	la	$t0,0xffff0004	# keypress register
	lw	$t0,0($t0)	# read keypress register

	# clear current star
	li	$a2, 0
	jal 	setLED

	# center key
	subi	$t1, $t0, 66				# center key?
	beq	$t1, $0, center_pressed		# 

	# left key
	subi	$t1, $t0, 226				# left key?
	beq	$t1, $0, left_pressed		# 

	# right key
	subi	$t1, $t0, 227				# right key?
	beq	$t1, $0, right_pressed		# 

	# up key
	subi	$t1, $t0, 224				# up key?
	beq	$t1, $0, up_pressed			# 

	# down key
	subi	$t1, $t0, 225				# down key?
	beq	$t1, $0, down_pressed		# 

	j	_poll

right_pressed:
	addi	$a0, $a0, 1
	bge	$a0, 64, RIGHT_SIDE
	j	move_done
	RIGHT_SIDE:
	li	$a0, 0
	j	move_done

left_pressed:
	subi	$a0, $a0, 1
	# if a0<0, a0=127
	blt	$a0, $zero, LEFT_SIDE
	j	move_done
	LEFT_SIDE:
	li	$a0, 63
	j	move_done

up_pressed:
	subi	$a1, $a1, 1
	blt	$a1, $zero, DOWN_SIDE
	j	move_done
	DOWN_SIDE:
	li	$a1, 63
	j	move_done

down_pressed:
	addi	$a1, $a1, 1
	bge	$a1, 64, UP_SIDE
	j	move_done
	UP_SIDE:
	li	$a1, 0
	j	move_done

center_pressed:
	j	_exit

move_done:
	# place code
	lw	$a2, init_color
	jal	setLED
		
j	_poll

_exit:
	li	$v0, 10
	syscall

setLED:
	subi	$sp, $sp, 20
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)
	sw	$t3, 12($sp)
	sw	$ra, 16($sp)

	jal	_setLED

	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	lw	$t2, 8($sp)
	lw	$t3, 12($sp)
	lw	$ra, 16($sp)
	addi	$sp, $sp, 20
	
	jr	$ra


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
	
	
	#  int _getLED(int x, int y)
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
	
# takes a0 - upper bound 
# returns v0 as the random number 
getrandomnumber:
# pre
subi	$sp, $sp, 8
sw	$s0, 0($sp)
sw	$ra, 4($sp)

# 
move	$s0, $a0	# upper bound

li	$a0, 1		# id
move	$a1, $s0	# upper bound
li	$v0, 42
syscall
# a0 has the random number
move	$v0, $a0

# post
lw	$s0, 0($sp)
lw	$ra, 4($sp)
addi	$sp, $sp, 8

jr	$ra
