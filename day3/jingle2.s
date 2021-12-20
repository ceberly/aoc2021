.global jingle2_imp

.MACRO DO_BYTE shift
  ldrb w2, [x1], #1
  sub w2, w2, #48
  orr w4, w4, w2, lsl \shift
.ENDM

// this puzzle uses the values computed by part 1
// most frequently occurring bitset: 2663 
// least frequently occuring bitset: 1432
jingle2_imp:
  ldr x1, [x0] // pointer is 8 bytes 

  // Let's make a binary tree on the stack!
  // Treat each line like a 16bit value. We have 1000 elements so
  // we need 16 bits for the value and 16bits each for the left / right
  // child. Start the array at 1 and make 0 the null value.
  // Since we would know the values from part 1 anyway we can just
  // reserve the amount we need which is 1000 * 2 * 3 = 6000, which
  // is conveniently a multiple of 16.
  mov x11, #0x1770 // 6000
  sub sp, sp, x11

  // Insert the first element.
  // Unroll 12 bits into its actual value in w4
  eor w4, w4, w4
  DO_BYTE #11
  DO_BYTE #10
  DO_BYTE #9
  DO_BYTE #8
  DO_BYTE #7
  DO_BYTE #6
  DO_BYTE #5
  DO_BYTE #4
  DO_BYTE #3
  DO_BYTE #2
  DO_BYTE #1
  DO_BYTE #0

  mov w8, #0 // left
  mov w9, #0 // right

  mov x5, sp // point to current element

  strh w4, [x5], #2
  strh w8, [x5], #2
  strh w8, [x5], #2

  subs w3, w3, #1

// insert the rest of the elements
loop:
  DO_BYTE #11
  DO_BYTE #10
  DO_BYTE #9
  DO_BYTE #8
  DO_BYTE #7
  DO_BYTE #6
  DO_BYTE #5
  DO_BYTE #4
  DO_BYTE #3
  DO_BYTE #2
  DO_BYTE #1
  DO_BYTE #0

  // zero out new left and right values
  mov w8, #0
  mov w9, #0

  // x6 holds the address of the element we are examining
  // as we search for the right place for the new element.
  mov x6, sp
binsert:
  // load the first element
  ldrh w7, [x6], #2 // value
  cmp w7, w4
  // if located element > new element, insert left, otherwise insert right
  cset w14, lt
  
  // load either the left or right index
  lsl w14, w14, #1
  ldrh w12, [x6, x14]

  strh w8, [x5], #2
  strh w9, [x5], #2

  subs w3, w3, #1
  bne loop

  mov w0, w4
  add sp, sp, x11
  ret
