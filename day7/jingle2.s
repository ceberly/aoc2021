.global jingle2

// A Go-like slice that can (only) be appended to.
//typedef struct {
//  uint16_t *a;
//  size_t len;
//  size_t capacity;
//} Uint16Array;

// Input->a is assumed to have been sorted by heap_sort in algos.s
jingle2:
  ldr x1, [x0], #8 // start of packed uint16_t
  ldr x2, [x0] // item count

  add x5, x1, x2, lsl #1 // end of input
  mov w4, #0

sum:
  ldrh w3, [x1], #2 
  add w4, w4, w3
  
  cmp x1, x5
  bne sum

  // result of division and remainder.
  udiv x3, x4, x2

  ldr x1, [x0, #-8] // reset to start of input.
  // x3 has the average value
  // x5 has the end of input marker still
  // x4 has accumulated cost
  mov w4, #0

new_cost:
  ldrh w0, [x1], #2 

  subs w0, w3, w0
  csneg w0, w0, w0, hi
  
  // the cost function is the sum of the first n integers,
  // where n is the distance, stored in w0.
  // One of the few math facts that i know is 0 + 1 + 2 + 3 ... + n
  // = n(n+1) / 2
  add w2, w0, #1 
  mul w0, w0, w2
  mov w0, w0, lsr #1

  add w4, w4, w0
  
  cmp x1, x5
  bne new_cost

  mov x0, x4

  ret
