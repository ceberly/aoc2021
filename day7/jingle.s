.global jingle

// A Go-like slice that can (only) be appended to.
//typedef struct {
//  uint16_t *a;
//  size_t len;
//  size_t capacity;
//} Uint16Array;

// Input->a is assumed to have been sorted by heap_sort in algos.s
jingle:
  ldr x1, [x0], #8 // start of packed uint16_t
  ldr x2, [x0] // item count

  // compute the median
  mov x3, x2, lsr #1 // always need the floored middle element
  ldrh w0, [x1, x3, lsl #1] // 16 bit numbers

  and x4, x2, #1 // x mod 2
  cbnz x4, cost // if the number of inputs is odd, we are done.

  // even number of inputs, take the average of the middle 2.
  // the second middle is in w0 already, need the first.
  // The reason its the second already there and not the first is like so:
  // odd number of inputs: i: 0 1 2 3 4   5 // 2 == 2 which is the *third* 
  // element, which is the one we want.
  // even number of inputs: i: 0 1 2 3    4 // 2 == 3 which is the *third*
  // element, and we also need the *second*.

  add x3, x1, x3, lsl #1
  ldrh w3, [x3, #-2]

  add w0, w0, w3 // average the elements.
  mov w0, w0, lsr #1

  // median value is in w0 at this point.
  // subtract that from each position to find the cost, and sum that.
  mov w4, #0
  add x2, x1, x2, lsl #1 // end of input
cost:
  ldrh w3, [x1], #2 
  // subtract, take absolute value, add to w4...
  subs w3, w0, w3
  csneg w3, w3, w3, hi
  add w4, w4, w3
  
  cmp x1, x2
  bne cost

  mov w0, w4

  ret
