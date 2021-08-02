#-------------------- MEMORY Mapped I/O -----------------------
#define PORT_LEDG[7-0] 0x800 - LSB byte (Output Mode)
#define PORT_LEDR[7-0] 0x804 - LSB byte (Output Mode)
#define PORT_HEX0[7-0] 0x808 - LSB byte (Output Mode)
#define PORT_HEX1[7-0] 0x80C - LSB byte (Output Mode)
#define PORT_HEX2[7-0] 0x810 - LSB byte (Output Mode)
#define PORT_HEX3[7-0] 0x814 - LSB byte (Output Mode)
#--------------------------------------------------------------
.data

Array:      .word   3, 1, 6, 6, 0, 8, 8, 1, 9,
newArray:   .space  9 
N :         .word   0xB71B00 
     .text
main:   sw   $0,0x800 # write to PORT_LEDG[7-0]
	sw   $0,0x804 # write to PORT_LEDR[7-0]
	sw   $0,0x808 # write to PORT_HEX0[7-0]
	sw   $0,0x80C # write to PORT_HEX1[7-0]
	sw   $0,0x810 # write to PORT_HEX2[7-0]
	sw   $0,0x814 # write to PORT_HEX3[7-0] 
	lw   $t7,N
	   addi   $a0, $0,0x00             	# sets the base address of the array to $a0
	   addi   $a1, $0,0x24
	   addi $t2 ,$0,8
	   jal  sort
Next:      addi $t4,$0,0
	   addi   $a1,$0,0x24
avi:	   lw  $s1,0($a1) 
	   sw   $s1,0x808
 	   sw    $s1,0x80c
 	   sw  	$s1,0x810
 	   sw	$s1,0x814
	   addi $t1,$0,0
	
delay:	   addi $t1,$t1,1            # $t1=$t1+1
	   slt  $t5,$t1,$t7         #if $t1<N than $t2=1
	   beq  $t5,$zero,endDelay   #if $t1>=N then go to Loop label
	   j    delay                  #delay 
endDelay:  addi $t4,$t4,1
	   addi $a1,$a1,4
	   bne  $t4,$t2,avi
	   addi $t4,$t4,0
	   addi   $a1,$0,0x24
	   j    avi
	   
	   
sort:	   addi $t3, $0,0
loop:      lw   $t0, 0($a0)           	# sets $t0 to the current element in array
           lw   $t1, 4($a0)       	 # sets $t1 to the next element in array
           blt  $t1, $t0, swap      	# if the following value is greater, swap them
           addi $a0, $a0, 4     	# advance the array to start at the next location from last time
           addi $t3,$t3,1
           beq  $t3,$t2,sof
           j   loop                 	 

swap:      sw   $t0, 4($a0)         	
           sw   $t1, 0($a0)       	 
           addi   $a0, $0,0x00             	 # resets the value of $a0 back to zero so we can start from beginning of array
           addi $t3,$0,0
           j   loop                 	 # jump back to the loop so we can go through and find next swap

sof:       addi $t6,$0,0
	   addi   $a0,$0,0x00
	   addi $t2,$t2,1
copy:  	   lw   $t5,0($a0)
	   sw   $t5,0($a1)
	   addi $a0,$a0,4
	   addi $a1,$a1,4
	   addi $t6,$t6,1
	   bne  $t6,$t2,copy
	    j   Next	


