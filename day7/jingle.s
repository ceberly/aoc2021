.global jingle

// A Go-like slice that can (only) be appended to.
//typedef struct {
//  uint16_t *a;
//  size_t len;
//  size_t capacity;
//} Uint16Array;

jingle:
  ldr x1, [x0], #8 // start of packed uint16_t
  ldr x2, [x0] // item count

  add x3, x1, x2, LSL #1 // end of input

  mov w4, #0 // sum of items. I guess it can't be more than 32bit ??

  subs xzr, x3, x1 // check for zero length
  beq fail

  // sum the elements
sum:
  ldrh w5, [x1], #2
  add w4, w4, w5
  subs xzr, x3, x1
  bne sum

  // average the elements
  udiv x4, x4, x2

  mov x0, x4
  ret

  // calculate the absolute value distance for each element
  mov w6, #0 // sum of distance
  ldr x1, [x0, #-8] // reset to start of elements.
  
dist:
  ldrh w5, [x1], #2

  // absolute value
  subs w5, w4, w5
  csneg w5, w5, w5, gt

  add w6, w6, w5

  subs xzr, x3, x1
  bne dist

  mov w0, w6
  ret

fail:
  mov w0, #-1
  ret
