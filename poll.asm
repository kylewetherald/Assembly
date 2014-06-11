	# CS 0447 Spring 2012
	# modified to work with the 64x64 LED display simulator
	# Bruce Childers
	#
	# This program illustrates a polling loop.  It continuously reads the key status
	# memory location to check for a key press.  When the key is pressed, the key is
	# read.  The box fill color shown on the LED display simulator is changed based on the
	# key pressed. press 'center' key (b) to exit.
	#
	# To run:
	#    Use the MARS LED Display Simulator
	#    Load this program into MARS
	#    Assemble the program
	#    Under Tools, select "Keypad and LED Display Simulator"
	#    Select "Connect to MARS" in the LED Display Simulator window
	#    Select "Run" in MARS
	#    Press the arrow keys to change the color
	#    Press the center button to exit the program
	#
	.text
	li	$a0,3			# draw initial box as greeen
	jal	_drawBox
	la	$s0,0xffff0000		# status register
	
	# polling loop - just continuously read status register
_poll:	
	lw	$t1,0($s0)		# read status register
	andi	$t1,$t1,1		# check for key press
	beq	$t1,$0,_poll		# no key was pressed, so go read it again!

	# a key was pressed, so process it. exit or set box color.
	lw	$t1,4($s0)		# read the key pressed
	addi	$t0,$t1,-66		# check for middle key
	beq	$t0,$0,_exit
	addi	$a0,$t1,-224		# adjust color based on key press
	jal	_drawBox
	j	_poll
_exit:	
	li	$v0,10			# exit service
	syscall

_drawBox:
	# void _drawBox(int color)
	#   draws a box filled with a color
	#   $a0 is the color for the box
	#
	or	$t0,$0,$a0	# set initial color bits
	addi	$t1,$0,15
_drawBoxColorLoop:		# compute a word with the color values
	sll	$t0,$t0,2	
	or	$t0,$t0,$a0
	addi	$t1,$t1,-1
	bne	$t1,$0,_drawBoxColorLoop
	li	$t2,0xffff0008
	li	$t1,4
_drawBoxLoop:			# write the word in the center 64 LEDs of display
	sw	$t0,0($t2)
	sw	$t0,16($t2)
	sw	$t0,32($t2)	
	sw	$t0,48($t2)	
	addi	$t2,$t2,32
	addi	$t1,$t1,-1
	bne	$t1,$0,_drawBoxLoop
	jr	$ra
	
	
	
